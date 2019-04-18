//
//  PeopleCollectionVC.swift
//  CoreDataNew
//
//  Created by Charlie Tuna on 2019-04-16.
//  Copyright © 2019 Charlie Tuna. All rights reserved.
//

import UIKit

class PeopleTableVC: UITableViewController {

    // MARK:- Properties

    let personDao = CoreDataManager.shared.personDao
    let reuseIdentifier = "PersonCell"
    var people = [Person]()
    private let refControl = UIRefreshControl()
    lazy var searchController = UISearchController(searchResultsController: nil)

    // MARK:- Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "PersonCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refControl

        refControl.addTarget(self, action: #selector(shouldRefresh), for: .valueChanged)

        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.isActive = true
        searchController.dimsBackgroundDuringPresentation = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fetchPeople()
    }

    // MARK:- TableView

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PersonCell

        cell.person = people[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (action, indexPath) in

            self.personDao.delete(person: self.people[indexPath.row], completion: { [weak self] (error) in
                if let error = error {
                    print(error)
                    return
                }
                self?.people.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }

        return [delete]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    // MARK:- Operations

    private func fetchPeople(predicate: NSPredicate? = nil) {
        if let people = self.personDao.fetch(predicate: predicate) {
            self.people = people
            tableView.reloadData()
            refControl.endRefreshing()
        } else {
            print("Could not get people from core data!")
        }
    }

    // MARK:- objc

    @objc func shouldRefresh() {
        fetchPeople()
    }

    // MARK:- IBAction

    @IBAction func handleAddAction(_ sender: UIBarButtonItem) {
        let controller = UIAlertController.init(title: "Add person", message: "Fill the credentials to add a person.", preferredStyle: .alert)

        ["name", "surname", "age"].forEach { (s) in
            controller.addTextField(configurationHandler: { (textField) in

                if s == "age" {
                    textField.keyboardType = .numberPad
                } else {
                    textField.keyboardType = .namePhonePad
                }

                textField.placeholder = s.capitalized
            })
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        controller.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let name = controller.textFields?[0].text else { return }
            guard let surname = controller.textFields?[1].text else { return }
            guard let ageString = controller.textFields?[2].text else { return } // FIXME: Add an error indicator for fields.
            guard let age = Int16(ageString) else { return }

            if let person = self?.personDao.add(name: name.lowercased(), surname: surname.lowercased(), age: age) {
                self?.people.append(person)
                self?.tableView.reloadData()
            }
        }))

        self.present(controller, animated: true, completion: nil)
    }
}

extension PeopleTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }

        if text.isEmpty { fetchPeople(); return }

        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate.init(format: "name CONTAINS[cd] %@", text.lowercased()),
                                                                                   NSPredicate.init(format: "surname CONTAINS[cd] %@", text.lowercased())])

        fetchPeople(predicate: compoundPredicate)
    }
}

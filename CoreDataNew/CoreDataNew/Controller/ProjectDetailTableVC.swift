//
//  ProjectDetailTableVC.swift
//  CoreDataNew
//
//  Created by Charlie Tuna on 2019-04-18.
//  Copyright © 2019 Charlie Tuna. All rights reserved.
//

import UIKit

class ProjectDetailTableVC: UITableViewController {

    // MARK:- Properties
    let personDao = CoreDataManager.shared.personDao
    let projectDao = CoreDataManager.shared.projectDao

    private let reuseIdentifier = "PersonCell"
    private let refControl = UIRefreshControl()
    private var people = [Person]()

    var project: Project? {
        didSet {
            fetchPeople(for: project!)
            setUI(for: project!)
        }
    }

    // MARK:- Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        refControl.addTarget(self, action: #selector(shouldRefresh), for: .valueChanged)

        tableView.register(UINib(nibName: "PersonCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refControl
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK:- Operations

    private func fetchPeople(for project: Project) {
        if let people = project.person {
            if let peopleArray = Array(people) as? [Person] {
                self.people = peopleArray
                tableView.reloadData()
                refControl.endRefreshing()
            } else {
                print("Couldn't cast set to array.")
            }
        } else {
            print("No people found in project.")
        }
    }

    private func setUI(for project: Project) {
        navigationItem.title = project.title
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

        let delete = UITableViewRowAction(style: .destructive, title: "Disassociate") { [unowned self] (action, indexPath) in

            self.projectDao.unRelate(self.project!, with: self.people[indexPath.row], completion: { [weak self] (error) in
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


    // MARK:- objc

    @objc func shouldRefresh() {
        guard let project = project else { return }
        fetchPeople(for: project)
    }

    // MARK:- IBAction

    @IBAction func handleAddAction(_ sender: UIBarButtonItem) {

        guard let allPeople = personDao.fetch() else { return }

        let alertController = UIAlertController.init(title: "Add person to the project", message: "Select a person to add", preferredStyle: .actionSheet)

        allPeople.filter({ !people.contains($0) }).forEach { (person) in

            let title = "\(person.name ?? "") \(person.surname ?? "")"

            alertController.addAction(UIAlertAction.init(title: title, style: .default, handler: { (action) in
                self.projectDao.relate(self.project!, with: person, completion: { (error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    self.fetchPeople(for: self.project!)
                    return
                })

            }))
        }

        alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

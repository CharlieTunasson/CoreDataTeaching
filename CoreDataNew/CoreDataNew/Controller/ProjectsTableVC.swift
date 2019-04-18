//
//  ProjectsTableVCTableViewController.swift
//  CoreDataNew
//
//  Created by Charlie Tuna on 2019-04-17.
//  Copyright © 2019 Charlie Tuna. All rights reserved.
//

import UIKit

class ProjectsTableVC: UITableViewController {

    // MARK:- Properties

    let segueIdentifier = "ShowProjectDetail"
    let reuseIdentifier = "ProjectCell"
    
    let projectDao = CoreDataManager.shared.projectDao
    var projects = [Project]()
    private let refControl = UIRefreshControl()

    // MARK:- Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ProjectCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refControl

        refControl.addTarget(self, action: #selector(shouldRefresh), for: .valueChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        fetchProjects()
    }

    // MARK:- TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProjectCell

        cell.project = projects[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (action, indexPath) in

            self.projectDao.delete(project: self.projects[indexPath.row], completion: { [weak self] (error) in
                if let error = error {
                    print(error)
                    return
                }
                self?.projects.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }

        return [delete]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIdentifier, sender: self)
    }

    // MARK:- Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == segueIdentifier,
            let destination = segue.destination as? ProjectDetailTableVC,
            let index = tableView.indexPathForSelectedRow?.row {
            destination.project = projects[index]
        }
    }

    // MARK:- Operations

    private func fetchProjects() {
        if let projects = projectDao.fetch() {
            self.projects = projects
            tableView.reloadData()
            refControl.endRefreshing()
        } else {
            print("Could not get people from core data!")
        }
    }

    // MARK:- Objc

    @objc func shouldRefresh() {
        fetchProjects()
    }

    // MARK:- IBAction

    @IBAction func handleAddAction(_ sender: UIBarButtonItem) {
        let controller = UIAlertController.init(title: "Add project", message: "Fill the credentials to add a project.", preferredStyle: .alert)

        ["title"].forEach { (s) in
            controller.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .namePhonePad
                textField.placeholder = s.capitalized
            })
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        controller.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let title = controller.textFields?[0].text else { return }

            if let project = self?.projectDao.add(title: title) {
                self?.projects.append(project)
                self?.tableView.reloadData()
            }
        }))

        self.present(controller, animated: true, completion: nil)
    }
}

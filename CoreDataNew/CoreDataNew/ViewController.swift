//
//  ViewController.swift
//  CoreDataNew
//
//  Created by Charlie Tuna on 2019-04-16.
//  Copyright © 2019 Charlie Tuna. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func createData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        if let userEntity = NSEntityDescription.entity(forEntityName: "User", in: managedContext) {
            for i in 0...5 {
                let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
                user.setValue("name\(i)", forKey: "name")
                user.setValue("surname\(i)", forKey: "surname")
                user.setValue(i, forKey: "age")
            }

            do {
                try managedContext.save()
            } catch let error as NSError {
                print(error)
            }
        }
    }

    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<User>(entityName: "User")

//        fetchRequest.fetchLimit = 1
//        fetchRequest.predicate = NSPredicate(format: "name = %@", "name3")
//        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "age", ascending: true)]

        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "name") as! String)
                print(data.value(forKey: "surname") as! String)
                print(data.value(forKey: "age") as! Int16)
            }
        } catch let error as NSError {
            print(error)
        }
    }

    func updateData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        fetchRequest.predicate = NSPredicate(format: "name = %@", "name3")
        fetchRequest.fetchLimit = 1

        do {
            let objects = try managedContext.fetch(fetchRequest)

            let user = objects.first as! NSManagedObject

            user.setValue("New Name", forKey: "name")

            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }

    func deleteData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        fetchRequest.predicate = NSPredicate(format: "name = %@", "name0")
        fetchRequest.fetchLimit = 1

        do {
            let objects = try managedContext.fetch(fetchRequest)
            let user = objects.first as! NSManagedObject
            managedContext.delete(user)

            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }

    func printData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        do {
            let objects = try managedContext.fetch(fetchRequest)

            for object in objects as! [NSManagedObject] {
                print("name: \(object.value(forKey: "name")!) surname: \(object.value(forKey: "surname")!) age: \(object.value(forKey: "age")!)")
            }
        } catch {
            print(error)
        }
    }

    @IBAction func handleSave(_ sender: UIButton) {
        createData()
    }

    @IBAction func handleFetch(_ sender: UIButton) {
        fetchData()
    }

    @IBAction func handleDelete(_ sender: UIButton) {
        deleteData()
    }

    @IBAction func handlePrint(_ sender: UIButton) {
        printData()
    }
}


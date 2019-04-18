//
//  ProjectDao.swift
//  CoreDataNew
//
//  Created by Charlie Tuna on 2019-04-17.
//  Copyright © 2019 Charlie Tuna. All rights reserved.
//

import CoreData

class ProjectDao {

    func add(title: String) -> Project? {

        let context = CoreDataManager.shared.context!

        let project = Project(context: context)

        project.setValue(title, forKey: "title")

        do {
            try context.save()
            return project
        } catch {
            print(error)
            return nil
        }
    }

    func fetch(predicate: NSPredicate? = nil) -> [Project]? {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")

        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }

        var projects = [Project]()

        do {
            let result = try CoreDataManager.shared.context!.fetch(fetchRequest)

            for object in result as! [NSManagedObject] {
                let project = object as! Project
                projects.append(project)
            }
            return projects

        } catch {
            print(error)
            return nil
        }
    }

    func delete(project: Project, completion: @escaping(Error?)->()) {

        let context = CoreDataManager.shared.context!

        context.delete(project)

        do {
            try context.save()
            completion(nil)
            return
        } catch {
            completion(error)
            return
        }
    }

    func relate(_ project: Project, with person: Person, completion: @escaping(Error?)->()) {

        project.addToPerson(person)

        do {
            try CoreDataManager.shared.context.save()
            completion(nil)
            return
        } catch {
            completion(error)
            return
        }
    }

    func relate(_ project: Project, with people: NSSet, completion: @escaping(Error?)->()) {

        project.addToPerson(people)

        do {
            try CoreDataManager.shared.context.save()
            completion(nil)
            return
        } catch {
            completion(error)
            return
        }
    }

    func unRelate(_ project: Project, with person: Person, completion: @escaping(Error?)->()) {

        project.removeFromPerson(person)

        do {
            try CoreDataManager.shared.context.save()
            completion(nil)
            return
        } catch {
            completion(error)
            return
        }
    }

    func unRelate(_ project: Project, with people: NSSet, completion: @escaping(Error?)->()) {

        project.removeFromPerson(people)

        do {
            try CoreDataManager.shared.context.save()
            completion(nil)
            return
        } catch {
            completion(error)
            return
        }
    }
}

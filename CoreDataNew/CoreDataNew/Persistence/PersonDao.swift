//
//  UserDao.swift
//  CoreDataNew
//
//  Created by Charlie Tuna on 2019-04-16.
//  Copyright © 2019 Charlie Tuna. All rights reserved.
//

import CoreData
import UIKit

class PersonDao {

    func add(name: String, surname: String, age: Int16, mobile: String? = nil, home: String? = nil) -> Person? {

        let context = CoreDataManager.shared.context!

        let person = Person(context: context)

        person.setValue(name, forKey: "name")
        person.setValue(surname, forKey: "surname")
        person.setValue(age, forKey: "age")

        let phone = Phone(context: context)

        if let mobile = mobile { phone.setValue("mobile", forKey: mobile) }
        if let home = home { phone.setValue("home", forKey: home) }

        do {
            try context.save()
            return person
        } catch {
            print(error)
            return nil
        }
    }

    func fetch(predicate: NSPredicate? = nil) -> [Person]? {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")

        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }

        var people = [Person]()

        do {
            let result = try CoreDataManager.shared.context!.fetch(fetchRequest)

            for object in result as! [NSManagedObject] {
                let person = object as! Person
                people.append(person)
            }
            return people

        } catch {
            print(error)
            return nil
        }
    }

    func delete(person: Person, completion: @escaping(Error?)->()) {

        let context = CoreDataManager.shared.context!

        context.delete(person)

        do {
            try context.save()
            completion(nil)
            return
        } catch {
            completion(error)
            return
        }
    }
}

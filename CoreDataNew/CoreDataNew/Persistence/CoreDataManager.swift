//
//  CoreDataManager.swift
//  CoreDataNew
//
//  Created by Charlie Tuna on 2019-04-16.
//  Copyright © 2019 Charlie Tuna. All rights reserved.
//

import CoreData
import UIKit

class CoreDataManager {

    static let shared = CoreDataManager()
    let personDao = PersonDao()
    let projectDao = ProjectDao()

    let context: NSManagedObjectContext!

    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        context = appDelegate.persistentContainer.viewContext
    }
}

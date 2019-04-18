//
//  PersonCell.swift
//  CoreDataNew
//
//  Created by Charlie Tuna on 2019-04-16.
//  Copyright © 2019 Charlie Tuna. All rights reserved.
//

import UIKit

class PersonCell: UITableViewCell {

    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet weak var labelAge: UILabel!

    var person: Person? {
        didSet {
            setUI(for: person!)
        }
    }

    func setUI(for person: Person) {
        labelFullName.text = "\(person.name?.capitalized ?? "") \(person.surname?.capitalized ?? "")"
        labelAge.text = "\(person.age)"
    }
}

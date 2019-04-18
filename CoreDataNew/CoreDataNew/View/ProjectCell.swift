//
//  ProjectCell.swift
//  CoreDataNew
//
//  Created by Charlie Tuna on 2019-04-18.
//  Copyright © 2019 Charlie Tuna. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!

    var project: Project? {
        didSet {
            setUI(for: project!)
        }
    }

    private func setUI(for project: Project) {
        labelTitle.text = project.title
    }
    
}

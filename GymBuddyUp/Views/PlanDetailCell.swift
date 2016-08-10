//
//  PlanDetailCell.swift
//  GymBuddyUp
//
//  Created by you wu on 7/30/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanDetailCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var exercises = [Exercise]()

    var plan: Plan! {
        didSet {
            nameLabel.text = plan.name
            desLabel.text = plan.description
            levelLabel.text = "Level: " + plan.difficulty!.description
            if let ex = plan.exercises {
                exercises = ex
            }else {
                print("No exercises available")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UITableViewDataSource, UITableViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        tableView.delegate = dataSourceDelegate
        tableView.dataSource = dataSourceDelegate
        tableView.tag = row
        tableView.reloadData()
    }

    
}



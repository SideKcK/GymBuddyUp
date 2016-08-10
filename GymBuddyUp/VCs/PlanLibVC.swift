//
//  PlanLibVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanLibVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var cats: [MidCat]?
    var selectedCat: MidCat?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        Library.getMidCategory({ (content, error) in
            self.cats = content
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPlanLibDetail" {
            if let detailVC = segue.destinationViewController as? PlanDetailVC,
                plans = (sender as? [Plan]) {
                
                print(selectedCat?.name)
                detailVC.title = selectedCat?.name
                detailVC.plans = plans
            }
        }
    }
    

}

extension PlanLibVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cats = cats {
            return cats.count
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! LibraryCatCell
        guard let cat = cats?[indexPath.row].name else {
            return cell
        }
        cell.nameLabel.text = cat.uppercaseString
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("============ \(cats?[indexPath.row].name)")
        if let cat = cats?[indexPath.row] {
            selectedCat = cat
        }
        guard let midid = selectedCat?.id else {
            print("error")
            return
        }
        
        Library.getPlansByMidId(midid, completion: { (plans, error) in
            if error == nil {
                self.performSegueWithIdentifier("toPlanLibDetail", sender: plans)
            }else {
                print(error)
            }
        })
    
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
}
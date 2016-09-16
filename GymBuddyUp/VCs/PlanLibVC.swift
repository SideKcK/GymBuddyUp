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
    var from: UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: self.view.frame, andColors: [ColorScheme.p1Tint, ColorScheme.s5Bg])
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
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPlanLibDetailSegue" {
            if let detailVC = segue.destinationViewController as? PlanLibDetailVC,
                plans = (sender as? [Plan]) {
                
                detailVC.title = selectedCat?.name
                detailVC.plans = plans
                detailVC.from = from
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
                self.performSegueWithIdentifier("toPlanLibDetailSegue", sender: plans)
            }else {
                print(error)
            }
        })
    
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
}
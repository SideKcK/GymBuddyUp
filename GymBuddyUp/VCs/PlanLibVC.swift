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
    var cats: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        // TODO: 吴悠：这是读取library里数据的方法，API 返回的是完整的dictionary数据，
        // 你要用的时候做一个mapping 读你想要的数据，比如NAME, ID等等。
        Library.getTopCategory({ (content, error) in
            self.cats = content?.flatMap({ ($0["name"] as? String)})
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
            if let detailVC = segue.destinationViewController as? PlanDetailVC {
                detailVC.plans = Library.getPlans(sender as! Int)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath)
        cell.textLabel?.text = cats?[indexPath.row]
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("toPlanLibDetail", sender: indexPath.row)
    
    }
}
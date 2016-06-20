//
//  TestViewController.swift
//  GymBuddyUp
//
//  Created by you wu on 6/15/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class TestViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var places = [String]()
    var locationManager: CLLocationManager!
    let apiServerKey = "AIzaSyAAjJ_0Il1pS99Rz6UcczVt6yiuiuxQdqc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, name : String) {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiServerKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        urlString += "&name=\(name)"
        Alamofire.request(.GET, NSURL(string: urlString)!)
            .responseJSON { response in
                if let JSON = response.result.value as? NSDictionary {
                    if let places = JSON["results"] as? [NSDictionary] {
                        for i in places {
                            if let address = i["vicinity"] as? String {
                                if let name = i["name"] as? String {
                                self.places.append(name+" @ "+address)
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
        }
    
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension TestViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            fetchPlacesNearCoordinate(location.coordinate, radius: 5000, name: "gym")
        }

    }
}

extension TestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return places.count

    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placeCell", forIndexPath: indexPath)
        cell.textLabel?.text = places[indexPath.row]
        
        return cell
    }

}

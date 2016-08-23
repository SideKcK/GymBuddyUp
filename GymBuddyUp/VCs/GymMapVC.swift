//
//  GymMapVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class GymMapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var userLocation : CLLocation?
    var gym = Gym()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //get current user location
        
        mapView.delegate = self
        
        guard let gymLocation = gym.location else {
            return
        }
        self.title = gym.name
        var lat = 0.0
        var lgn = 0.0
        if let location = userLocation {
            lat = abs(location.coordinate.latitude - gymLocation.coordinate.latitude)
            lgn = abs(location.coordinate.longitude - gymLocation.coordinate.longitude)
        }
            let region = MKCoordinateRegion(center: gymLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 2 * lat + 0.01, longitudeDelta: 2 * lgn + 0.01))
            mapView.setRegion(region, animated: true)
        
        addAnnotationAtCoordinate(gymLocation.coordinate)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = gym.name
        annotation.subtitle = gym.address
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
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

extension GymMapVC : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKPointAnnotation) {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        annotationView.pinTintColor = ColorScheme.buttonTint
        annotationView.canShowCallout = true
        return annotationView
        }
        return nil
    }
}
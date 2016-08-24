//
//  GoogleAPI.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import GooglePlaces

let apiServerKey = "AIzaSyAAjJ_0Il1pS99Rz6UcczVt6yiuiuxQdqc"

class GoogleAPI {
    var apiKey: String!
    
    class var sharedInstance : GoogleAPI {
        struct Static {
            static var token : dispatch_once_t = 0
            static var instance : GoogleAPI? = nil
        }
        
        dispatch_once(&Static.token) {
            Static.instance = GoogleAPI(consumerKey: apiServerKey)
        }
        return Static.instance!
    }

    init(consumerKey: String!) {
        self.apiKey = consumerKey
    }

    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, name : String, completion: ([Gym]!, NSError!) -> Void) ->() {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiServerKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        urlString += "&name=\(name)"
        Alamofire.request(.GET, NSURL(string: urlString)!)
            .responseJSON { response in switch response.result {
            case .Success(let JSON):
                if let places = JSON["results"] as? [NSDictionary] {
                    completion(Gym.gymsWithArray(places), nil)
                }
                
            case .Failure(let error):
                completion(nil, error)
                print("Request failed with error: \(error)")
                }
        }
        
    }
    
    func getGymById(placesId: String, completion: (gym: Gym?, error: NSError?) -> Void ) {
        GMSPlacesClient.sharedClient().lookUpPlaceID(placesId, callback: { (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                completion(gym: nil, error: error)
                return
            }
            
            if let place = place {
                completion(gym: Gym(place: place), error: nil)
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place placeID \(place.placeID)")
                print("Place attributions \(place.attributions)")
            } else {
                print("No place details for \(placesId)")
                completion(gym: Gym(), error: nil)
            }
        })
    }
}
//
//  ServerAPI.swift
//  GymBuddyUp
//
//  Created by you wu on 5/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Alamofire
import CryptoSwift

let appid = "10001"
let secret = "123456"
let serverURL = "http://148.74.20.89:8106"

class ServerAPI {
    
    class var sharedInstance: ServerAPI {
        struct Static {
            static let instance = ServerAPI()
        }
        return Static.instance
    }
    
    func userSignUp(username: String!, email: String!, password: String!, completion: (user: User?, error: NSError?) -> ()) {
        
        //calculate MD5 sign
        let pwhash = password.md5().md5()
        var params: [String: AnyObject] = ["username": username, "email": email, "password": pwhash, "lng": 0, "lat": 0]
        generateQueryParams(&params)
        Alamofire.request(.POST, NSURL(string: serverURL+"/user/reg")!, parameters: params)
            .responseJSON { response in
                if let JSON = response.result.value as? NSDictionary {
                    if let code = JSON["code"] as? Int {
                        if code == 1 {
                            User.currentUser = User(response: JSON["data"] as! NSDictionary)
                            completion(user: User.currentUser, error: nil)
                        }
                    }
                }
                //TBD
                completion(user: nil, error: response.result.error)
        }
    }

    func userLogin(username: String!, password: String!, completion: ( error: NSError?) -> ()) {
        let pwhash = password.md5().md5()
        var params: [String: AnyObject] = ["username": username, "password": pwhash, "lng": 0, "lat": 0]
        generateQueryParams(&params)
        Alamofire.request(.POST, NSURL(string: serverURL+"/user/login")!, parameters: params)
            .responseJSON { response in
                if let JSON = response.result.value as? NSDictionary {
                    if let code = JSON["code"] as? Int {
                        if code == 1 {
                            User.currentUser = User(userID: "", token: JSON["data"] as! String)
                            completion(error: nil)
                        }
                    }
                }
                //TBD
                completion(error: response.result.error)
        }
    }
    
    func parseResponseCode
    
    func generateQueryParams(inout params: [String: AnyObject]) {
        //get t in long form
        let t = Int(NSDate().timeIntervalSince1970)
        params["appid"] = appid
        params["t"] = t
        //sort dict
        let sortedKeys = params.keys.sort()
        //get config string
        var parameterArray = [String]()
        for key in sortedKeys {
            parameterArray.append("\(key)=\(params[key]!)")
        }
        let config = parameterArray.joinWithSeparator("&")
        //calculate sign
        let hash = (config+secret).md5()
        //append sign to params dic
        params["sign"] = hash
    }

}
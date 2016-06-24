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
let serverURL = "http://108.59.82.159:8106"

class ServerAPI {
    
    struct Error {
        var code: Int!
        var message: String!
    }
    
    class var sharedInstance: ServerAPI {
        struct Static {
            static let instance = ServerAPI()
        }
        return Static.instance
    }
    
    func userSignUp(username: String!, email: String!, password: String!, completion: (user: User?, error: Error?) -> ()) {
        
        //calculate MD5 sign
        let pwhash = password.md5().md5()
        var params: [String: AnyObject] = ["username": username, "email": email, "password": pwhash]
        generateQueryParams(&params)
        print(params)
        Alamofire.request(.GET, NSURL(string: serverURL+"/user/reg")!, parameters: params)
            .responseJSON { response in
                print(response)
                if let JSON = response.result.value as? NSDictionary {
                    if let code = JSON["rcode"] as? Int {
                        if code == 1 {
                            User.currentUser = User(response: JSON["data"] as! NSDictionary)
                            completion(user: User.currentUser, error: nil)
                        }else {
                            completion(user: nil, error: Error(code: abs(code), message: JSON["message"] as! String))
                        }
                    }
                }
                completion(user: nil, error: Error(code: 0, message: "Network Error"))
        }
    }

    func userLogin(username: String!, password: String!, completion: ( error: Error?) -> ()) {
        let pwhash = password.md5().md5()
        var params: [String: AnyObject] = ["username": username, "password": pwhash]
        generateQueryParams(&params)
        Alamofire.request(.GET, NSURL(string: serverURL+"/user/login")!, parameters: params)
            .responseJSON { response in
                print(response)
                if let JSON = response.result.value as? NSDictionary {
                    if let code = JSON["rcode"] as? Int {
                        if code == 1 {
                            User.currentUser = User(userID: "", token: JSON["data"] as! String)
                            completion(error: nil)
                        }else {
                            completion(error: Error(code: abs(code), message: JSON["message"] as! String))
                        }
                    }
                }
                completion(error: Error(code: 0, message: "Network Error"))
        }
    }
    
    //func parseResponseCode
    
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
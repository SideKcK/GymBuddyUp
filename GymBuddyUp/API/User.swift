//
//  User.swift
//  GymBuddyUp
//
//  Created by you wu on 7/11/16.
//  Copyright © 2016 Wei Wang. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FBSDKLoginKit

// callbacks
typealias UserAuthCallback = (user:User?, error: NSError?) -> Void

struct UserInfo {
    
    enum Gender:Int {
        case Female = 0
        case Male = 1
        case Unspecified = 2
    }
    
    enum Goal: Int {
        case KeepFit = 1
        case LoseWeight = 0
        case BuildMuscle = 3
        case HaveFun = 2
        
        var description: String {
            switch self {
            case KeepFit:
                return "Keep Fit"
            case LoseWeight:
                return "Lose Weight"
            case BuildMuscle:
                return "Build Muscle"
            case HaveFun:
                return "Have Fun"
            }
        }
    }
    
    var userId: String!
    var photoURL: NSURL?
    var screenName: String?
    var gender:Gender
    var goals: [Goal]?
}


class User {
    
    enum Gender:Int {
        case Female = 0
        case Male = 1
        case Unspecified = 2
    }
    
    enum Goal: Int {
        case KeepFit = 1
        case LoseWeight = 0
        case BuildMuscle = 3
        case HaveFun = 2
        
        var description: String {
            switch self {
            case KeepFit:
                return "Keep Fit"
            case LoseWeight:
                return "Lose Weight"
            case BuildMuscle:
                return "Build Muscle"
            case HaveFun:
                return "Have Fun"
            }
        }
    }
    
    enum AuthProvider {
        case Facebook
        case Email
        case Anonymous
    }
    
    
    private let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("users")
    private let storageRef = FIRStorage.storage().reference().child("user")
    private let userLocationRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_location")
    
    var userId: String!
    var photoURL: NSURL?
    var email: String?
    var screenName: String?
    
    private var firUser: FIRUser?
    private var userRef: FIRDatabaseReference?
    
    var gender: Gender?
    var cachedPhoto:UIImage?
    
    var workoutNum: Int?
    var starNum: Int?
    var likeNum: Int?
    var dislikeNum: Int?
    var buddyNum: Int?
    
    var goal: Goal?
    var goals = [Goal]()
    var gym: String?
    var googleGymObj: Gym?
    var description: String?
    var userlocation: CLLocation?
    
    // some info for cell cache
    var canBeFriend = true
    
    
    /*var description: String? {
        get {
            
            return self.userRef?.valueForKey("description") as? String
        }
    }*/
    
    var distance: Double?
    var sameInterestNum: Int?
    var interestList: NSDictionary?
    
    
    static var currentUser: User?
    
    init(){
    }
    
    init (user: FIRUser) {
        // FIRUser properties
        self.firUser = user;
        self.userId = user.uid
        self.email = user.email
        self.screenName = user.displayName
        self.photoURL = user.photoURL
        
        self.userRef = ref.child(user.uid)
        
        // custom properties
        self.workoutNum = 0
        self.starNum = 0
        self.dislikeNum = 0
        self.buddyNum = 0
        self.goal = .KeepFit
        self.gym = "Not Specified"
        self.goals = []
        // TODO: figure out best logic for photo caching.
        if (self.photoURL != nil) {
            updateProfilePicture(self.photoURL) { error in }
        }
        
        userBecameActive()
    }
    
    
    init (snapshot: FIRDataSnapshot) {
        self.userId = snapshot.key
        if let _screenName = snapshot.value!["screen_name"] as? String {
            self.screenName = _screenName
        }
        
        if let _goals = snapshot.value!["goal"] as? [Int] {
            for key in _goals{
                self.goals.append(Goal(rawValue: key)!)
                print(String(key))
            }
            
        }
        
        if let _photoURL = snapshot.value!["profile_image_url"] as? String {
            self.photoURL = NSURL(string: _photoURL)
        }
        
        if let _gym = snapshot.value?["gym"] as? String {
            GoogleAPI.sharedInstance.getGymById(_gym) { (gym, error) in
                if error == nil {
                    if let fetchedGym = gym {
                        self.gym = fetchedGym.name
                        self.googleGymObj = fetchedGym
                    }
                } else {
                    print(error)
                }
            }
        }
        self.userRef = ref.child(self.userId)
    }
    
    class func signInWithEmail(email: String, password: String, completion: UserAuthCallback) {
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (firebaseUser, error) in
            if error != nil {
                completion(user: nil, error: error)
            }
            else {
                User.currentUser = User(user: firebaseUser!)
                User.currentUser?.syncWithLastestUserInfo()
                completion(user: User.currentUser, error: nil)
            }
        })
    }
    
    class func signInAsAnonymous (completion: UserAuthCallback)
    {
        FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (firebaseUser, error) in
            if error != nil {
                completion(user: nil, error: error)
            }
            else {
                User.currentUser = User(user: firebaseUser!)
                User.currentUser?.syncWithLastestUserInfo()
                completion(user: User.currentUser, error: nil)
            }
        })
    }
    
    class func signUpWithEmail(email: String, password: String, completion: UserAuthCallback) {
        print("reach here in signUpWithEmail")
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (firebaseUser, error) in
            if error != nil {
                completion(user: nil, error: error)
            } else {
                if let user = firebaseUser {
                    User.currentUser = User(user: user)
                    completion(user: User.currentUser, error: nil)
                }

            }
        })
    }
    
    class func signInWithFacebook (fromViewController: UIViewController!, completion: UserAuthCallback) {
        let loginManager = FBSDKLoginManager()
        let facebookReadPermissions = ["public_profile", "email", "user_friends"]
        loginManager.logInWithReadPermissions(facebookReadPermissions, fromViewController: fromViewController) { (result, error) in
            if error != nil {
                completion(user: nil, error: error)
                
            } else if(result.isCancelled) {
                print("FBLogin cancelled")
            } else {
                // [START headless_facebook_auth]
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                // [END headless_facebook_auth]
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (firebaseUser, error) in
                    
                    if error != nil {
                        completion(user: nil, error: error)
                    }
                    else {

                        User.currentUser = User(user: firebaseUser!)
                        completion(user: User.currentUser, error: nil)
                    }})
            }
        }
    }
    
    func syncWithLastestUserInfo() {
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info")
        ref.child(userId).observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
            if let _screenName = snapshot.value?["screen_name"] as? String {
                self.screenName = _screenName
                print(_screenName)
            }
            if let _goals = snapshot.value?["goal"] as? [Int] {
                self.goals = []
                for key in _goals{
                    self.goals.append(Goal(rawValue: key)!)
                    //print(String(key))
                }
            }
            
            if let _gym = snapshot.value?["gym"] as? String {
                GoogleAPI.sharedInstance.getGymById(_gym) { (gym, error) in
                    if error == nil {
                        if let fetchedGym = gym {
                            self.gym = fetchedGym.name
                            self.googleGymObj = fetchedGym
                        }
                    } else {
                        print(error)
                    }
                }
            }
            
            if let _photoURL = snapshot.value?["profile_image_url"] as? String {
                self.photoURL = NSURL(string: _photoURL)
            }
            
        }
    }
    
    func getMyFriendList(successfulHandler: ([User])->()) {
       let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_friend/\(self.userId)")
        ref.observeSingleEventOfType(.Value) { (snapshot :FIRDataSnapshot) in
            if !snapshot.exists() {
                return
            }

            let postDict = snapshot.value as! [String : AnyObject]
            var userIds = [String]()
            for (key, value) in postDict {
                if let dict = value as? [String : AnyObject] {
                    if let isFriend = dict["is_friend"] as? Int where isFriend == 1 {
                        userIds.append(key)
                    }
                }
            }
            User.getUserArrayFromIdList(userIds, successHandler: { (users: [User]) in
                successfulHandler(users)
            })
        }
    }
    
    class func getUserArrayFromIdList (userIds: [String], successHandler: ([User])->()) {
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info")
        let gcdGetUserGroup = dispatch_group_create()
        var ret = [User]()
        for userId in userIds {
            dispatch_group_enter(gcdGetUserGroup)
            ref.child(userId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let user = User(snapshot: snapshot)
                UserCache.sharedInstance.cache[user.userId] = user
                ret.append(user)
                dispatch_group_leave(gcdGetUserGroup)
            }) { (error) in
                print(error.localizedDescription)
                dispatch_group_leave(gcdGetUserGroup)
            }
        }
        
        dispatch_group_notify(gcdGetUserGroup, dispatch_get_main_queue(), {
            successHandler(ret)
        })
    }
    
    class func getUserById (userId: String, successHandler: (User)->()) {
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info")
        let gcdGetUserGroup = dispatch_group_create()
        var ret = User()
        
        dispatch_group_enter(gcdGetUserGroup)
        ref.child(userId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            ret = User(snapshot: snapshot)
            dispatch_group_leave(gcdGetUserGroup)
        }) { (error) in
            print(error.localizedDescription)
            dispatch_group_leave(gcdGetUserGroup)
        }
        
        
        dispatch_group_notify(gcdGetUserGroup, dispatch_get_main_queue(), {
            successHandler(ret)
        })
    }
    
    class func hasAuthenticatedUser () -> Bool {
        if (FIRAuth.auth()?.currentUser != nil) {
            if (User.currentUser == nil){
                self.currentUser = User(user: (FIRAuth.auth()?.currentUser)!)
            }
            return true
        }
        else {
            return false
        }
    }
    
    func updateFCMToken(token: String?) {
        if token != nil {
            userRef!.child("FCM_token").setValue(token)
        }
    }
    
    func userBecameActive () -> Void {
        updateFCMToken(FIRInstanceID.instanceID().token())
        userRef!.child("last_login").setValue(FIRServerValue.timestamp()) { (error
            , ref) in
            if (error != nil){
                print (error)
            }
        }
        //let currentLocation = LocationCache.sharedInstance.currentLocation
        
        let currentLocation = CLLocation(latitude: 30.563, longitude: -96.311)
        
        updateLastSeenLocation(currentLocation){ (err) in
            //            print(err)
        }

    }
    

    // TODO
    func updateLastSeenLocation(location: CLLocation, completion: (NSError?) -> Void) {
        // to be implemented
        
        let geofire = GeoFire(firebaseRef: userLocationRef)
        geofire.setLocation(location, forKey: self.userId) { (error) in
            if error != nil {
                print(error)
            }
            User.currentUser?.userlocation = location
            completion(error)
        }
    }
    
    func updateProfilePicture(photo: UIImage, errorHandler: (NSError?)->Void) {
        self.cachedPhoto = photo.imageScaledToSize(CGSizeMake(500, 500))
        // Create a reference to the file you want to upload
        let pngImageData = UIImagePNGRepresentation(self.cachedPhoto!)
        let filePath = self.userId + "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000)).png"
        let photoRef = storageRef.child(filePath)
        // Upload the file to the path "images/rivers.jpg"
        photoRef.putData(pngImageData!, metadata: nil) { metaData, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
                Log.info("updateProfilePhotoError: \(error!.localizedDescription)")
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                if let fetchedMetaData = metaData {
                    self.photoURL = fetchedMetaData.downloadURL()
                    let urlString = self.photoURL?.URLString
                    self.updateProfile("profile_image_url", value: urlString)
                }
                
            }
        }
    }

    func updateProfilePicture(photoURL: NSURL?, errorHandler: (NSError?)->Void) {
        if photoURL != nil {
            let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
            changeRequest?.photoURL = photoURL!
            changeRequest?.commitChangesWithCompletion({ (error) in
                if error != nil {
                    errorHandler(error)
                }
                else {
                    self.updateProfile("profile_image_url", value: photoURL)
                }
            })
        }
    }
    
    /*func updateProfile(attr: AnyObject?, value: AnyObject?) {
        print(self.userId)
        if let attrName = attr as? String, valueStr = value as? String {
            let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
            let attrRef = ref.child("\(attrName)")
            attrRef.setValue(valueStr)
            Log.info("Done setting attribute")
        }else if let attrName = attr as? String, valueStr = value as? Int{
            let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
            let attrRef = ref.child("\(attrName)")
            attrRef.setValue(valueStr)
            Log.info("Done setting attribute")
        }else if let attrName = attr as? String, valueStr = value as? Set<Int>{
            let valueArray = Array(valueStr)
            let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
            let attrRef = ref.child("\(attrName)")
            attrRef.setValue(valueArray)
            Log.info("Done setting attribute")
        }
        Log.info("no problem til here")
    }*/

    
    func updateProfile(attr: AnyObject?, value: AnyObject?) {
        
        let attrName = attr as! String
        switch attrName {
        case "profile_image_url":
            Log.info("profile_image_url update Attribute")
            if let valueStr = value as? String {
                self.photoURL = NSURL(string: valueStr)
                let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
                let attrRef = ref.child("\(attrName)")
                attrRef.setValue(valueStr)
                Log.info("profile_image_url updated Attribute Successfully")
            }
            break
        case "screen_name":
            let valueStr = value as? String
            self.screenName = valueStr
            let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
            let attrRef = ref.child("\(attrName)")
            attrRef.setValue(valueStr)
            
        case "goal":
            if let valueStr = value as? Set<Int> {
                let valueArray = Array(valueStr)
                self.goals = []
                for key in valueArray {
                    self.goals.append(Goal(rawValue: key)!)
                }
                for element in self.goals {
                    print(String(element))
                }
                let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
                let attrRef = ref.child("\(attrName)")
                attrRef.setValue(valueArray)
                Log.info("Done setting attribute")
            }
        case "gender":
            let valueStr = value as? Int
            self.gender = Gender(rawValue: valueStr!)
            let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
            let attrRef = ref.child("\(attrName)")
            attrRef.setValue(valueStr)
        case "description":
            let valueStr = value as? String
            self.description = valueStr
            let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
            let attrRef = ref.child("\(attrName)")
            attrRef.setValue(valueStr)
        case "gym":
            let valueStr = value as? String
            self.gym = valueStr
            let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
            let attrRef = ref.child("\(attrName)")
            attrRef.setValue(valueStr)
        default:
            Log.info("no attr matches")
        }
        
        Log.info("no problem til here")
    }
    
    func update() {
        
    }
    
//    class func resetPassword(email:String, completion: ()->Void ) -> Void {
//        let auth = email
//    }
//    
//    func updatePassword(oldPassword: String, newPassword: String, errorHandler: (NSError?) -> Void) -> Void {
//        let email = firUser?.email
//        if email == nil {
//            return errorHandler()
//        }
//        
//        let oldCredential = FIREmailPasswordAuthProvider.credentialWithEmail(email!, password: oldPassword)
//        firUser?.reauthenticateWithCredential(oldCredential, completion: { (error) in
//            if error != nil {
//                errorHandler(error)
//            }
//            else {
//                self.firUser?.updatePassword(newPassword, completion: { (error) in
//                    errorHandler(error)
//                })
//            }
//        })
//    }
    
    func getTokenForcingRefresh(completion: (token:String?, error:NSError?) -> Void) {
        firUser?.getTokenForcingRefresh(true) {idToken, error in
            completion(token: idToken, error: error)
        }
    }
    
    
    func signOut(completion: (NSError?)->()) {
        do {
            try FIRAuth.auth()?.signOut()
            completion(nil)
        }
        catch let error as NSError {
            completion(error)
        }
        
        User.currentUser = nil
    }
}

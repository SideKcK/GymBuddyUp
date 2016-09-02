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
    private let storageRef = FIRStorage.storage().reference()
    
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
    var gym: String? //to WW: or change it to CLLocationCoordinates if thats better for backend
    var description: String? {
        get {
            
            return self.userRef?.valueForKey("description") as? String
        }
    }
    
    var distance: Double?
    var sameInterestNum: Int?
    var interestList: NSDictionary?
    
    
    static var currentUser: User?
    
    init (user: FIRUser) {
        // FIRUser properties
        self.firUser = user;
        self.userId = user.uid
        self.email = user.email
        self.screenName = user.displayName
        self.photoURL = user.photoURL
        
        self.userRef = ref.child(user.uid)
        
        // custom properties
        self.workoutNum = 50
        self.starNum = 21
        self.dislikeNum = 10
        self.buddyNum = 20
        self.goal = .KeepFit
        self.gym = "Life Fitness"
        
        // TODO: figure out bast logic for photo caching.
        if (self.photoURL != nil) {
            updateProfilePicture(self.photoURL) { error in }
        }
        
        userBecameActive()
    }
    
    
    init (snapshot: FIRDataSnapshot) {
        self.userId = snapshot.key
        if let _screenName = snapshot.value!["screenName"] as? String {
            self.screenName = _screenName
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
        let facebookReadPermissions = ["public_profile", "email"]
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
    
    func getMyFriendList(successfulHandler: ([User])->()) {
       let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_friend/\(self.userId)")
        ref.observeSingleEventOfType(.Value) { (snapshot :FIRDataSnapshot) in
            let postDict = snapshot.value as! [String : AnyObject]
            var userIds = [String]()
            for (key, _) in postDict {
                userIds.append(key)
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
                ret.append(User(snapshot: snapshot))
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
    }
    

    // TODO
    func updateLastSeenLocation(location: CLLocation) {
        // to be implemented
    }
    
    func updateProfilePicture(photo: UIImage!, errorHandler: (NSError?)->Void) {
        self.cachedPhoto = photo.imageScaledToSize(CGSizeMake(500, 500))
        // Create a reference to the file you want to upload
        let pngImageData = UIImagePNGRepresentation(self.cachedPhoto!)
        let filePath = self.userId + "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000)).png"
        let photoRef = storageRef.child(filePath)
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = photoRef.putData(pngImageData!, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                self.photoURL = metadata!.downloadURL()
                let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                changeRequest?.photoURL = self.photoURL!
                changeRequest?.commitChangesWithCompletion({ (error) in
                    if error != nil {
                        errorHandler(error)
                    }
                })
            }
        }
    }
    
    func cacheUserPhoto(url: NSURL)
    {
        let data = NSData(contentsOfURL: url)
        self.cachedPhoto = UIImage(data: data!)?.imageScaledToSize(CGSizeMake(500, 500))
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
                    self.cacheUserPhoto(photoURL!)
                }
            })
        }
    }
    
    func updateProfile(attr: AnyObject?, value: AnyObject?) {
        if let attrName = attr as? String, valueStr = value as? String {
            let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_info").child("\(self.userId)")
            let attrRef = ref.child("\(attrName)")
            attrRef.setValue(valueStr)
            Log.info("Done setting attribute")
        }
        Log.info("no problem til here")
    }
    
    func update() {
        
    }
    
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

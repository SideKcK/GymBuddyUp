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
    
    var userId: String!
    var photoURL: NSURL?
    var email: String?
    var screenName: String?
    
    private var firUser: FIRUser?
    
    var gender: Gender?
    
    var authProvider: AuthProvider
    
    var workoutNum: Int?
    var starNum: Int?
    var likeNum: Int?
    var dislikeNum: Int?
    var buddyNum: Int?
    
    
    var goal: Goal?
    var gym: String? //to WW: or change it to CLLocationCoordinates if thats better for backend
    var description: String?
    
    var distance: Double?
    var sameInterestNum: Int?
    var interestList: NSDictionary?
    
    static var currentUser: User?
    
    init (user: FIRUser) {
        // FIRUser properties
        self.firUser = user
        self.userId = user.uid
        self.email = user.email
        self.screenName = user.displayName
        self.photoURL = user.photoURL
        
        self.authProvider = AuthProvider.Email
        
        // custom properties
        self.workoutNum = 100
        self.starNum = 21
        self.dislikeNum = 10
        self.buddyNum = 19
        self.goal = .KeepFit
        self.gym = "Life Fitness"
        self.description = "Test description"
        
    }
    
    
    class func signUpWithEmail(email: String, password: String, completion: UserAuthCallback) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (firebaseUser, error) in
            if error != nil {
                completion(user: nil, error: error)
            }
            else
                // sign up succeeded. Create and cache current user.
            {
                User.currentUser = User(user: firebaseUser!)
                completion(user: User.currentUser, error: nil)
                // TODO: move this to cloud.
                firebaseUser?.sendEmailVerificationWithCompletion(nil)
            }
        })
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
    
    func signOut() {
    }
    
    
    // TODO
    func updateLastSeenLocation(location: CLLocation) {
        // to be implemented
    }
    
    func updateProfilePicture(photo: UIImage!) {
        // to be implemented
    }
    
    func updateProfile(attr: AnyObject?, value: AnyObject?) {
        
    }
    
    func setDisplayName(name: String?) {
        self.screenName = name
        if let changeRequest = FIRAuth.auth()?.currentUser!.profileChangeRequest() {
            changeRequest.displayName = name
            changeRequest.commitChangesWithCompletion { error in
                if let error = error {
                    // An error happened.
                    print(error)
                } else {
                    // Profile updated.
                    print("User display name updated")
                }
            }
        }
    }
}

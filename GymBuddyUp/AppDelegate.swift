//
//  AppDelegate.swift
//  GymBuddyUp
//
//  Created by you wu on 5/10/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyDThFYIwTlrRah2NGdbqh6bnWOl_leUb1s")
        
        // Firebase Initialization
        
        // Register for remote notifications
        // TODO: wwang: this only works for ios 8 and above. A fallback should be considered if to deploy to ios 8 is planned.
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        
        FIRApp.configure()
        
        if User.hasAuthenticatedUser() {
            userDidLogin()
        }
        else {
            userDidLogout()
        }

        // Add observer for InstanceID token refresh callback.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                                         name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        // Facebook app Initialization
        let fbInitSucceeded = FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return fbInitSucceeded
    }
    
    func userDidLogin() {
        print("=========== User logged in! UID \(User.currentUser?.userId)")
        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainSB.instantiateInitialViewController()
        window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        User.currentUser?.sessionInitiated()

        User.currentUser?.sendFriendRequest("Noh5cGUfhbSSTnS2IDApRmqcSs82", completion: { (error) in
            print("err", error)
        })
    }
    
    func userDidLogout() {
        print("=========== User logged out!")
        User.currentUser = nil
        let signSB = UIStoryboard(name: "SignupLogin", bundle: nil)
        let vc = signSB.instantiateInitialViewController()
        window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }

    // [START receive_message]
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // display the userInfo
        if let notification = userInfo["aps"] as? NSDictionary,
            let alert = notification["alert"] as? String {
            let alertCtrl = UIAlertController(title: "Message Received", message: alert as String, preferredStyle: UIAlertControllerStyle.Alert)
            alertCtrl.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // Find the presented VC...
            var presentedVC = self.window?.rootViewController
            while (presentedVC!.presentedViewController != nil)  {
                presentedVC = presentedVC!.presentedViewController
            }
            presentedVC!.presentViewController(alertCtrl, animated: true, completion: nil)
            
            // call the completion handler
            // -- pass in NoData, since no new data was fetched from the server.
            completionHandler(UIBackgroundFetchResult.NoData)
        }
        
        // Print message ID.
        //print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }
    // [END receive_message]
    
    // [START refresh_token]
    func tokenRefreshNotification(notification: NSNotification) {
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("refreshed token: ", refreshedToken);
        if User.hasAuthenticatedUser() {
            User.currentUser!.updateFCMToken(refreshedToken);
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]

    // [START connect_to_fcm]
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]

    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFcm()
        // clear badge number
        application.applicationIconBadgeNumber = 0;
        // activate facebook app for tracking
        FBSDKAppEvents.activateApp()
        // Update User data
        User.currentUser?.sessionInitiated()
    }
    
    
    // [START disconnect_from_fcm]
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    // [END disconnect_from_fcm]
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}


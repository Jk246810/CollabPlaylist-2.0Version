//
//  AppDelegate.swift
//  CollaborativePlaylist2
//
//  Created by Brian on 7/12/17.
//  Copyright © 2017 jamee. All rights reserved.
//

import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        configureIntitialRootViewController(for: window)
        
        let auth = SPTAuth.defaultInstance()
        auth?.clientID = Constants.clientID
        auth?.requestedScopes = [SPTAuthStreamingScope, SPTAuthUserLibraryReadScope, SPTAuthUserReadPrivateScope, SPTAuthUserLibraryModifyScope]
        auth?.redirectURL = Constants.redirectURL
        auth?.sessionUserDefaultsKey = Constants.sessionUserDefaultsKey
        


        return true
    }

    
       
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // 2- check if app can handle redirect URL
        let auth = SPTAuth.defaultInstance()
        if (auth?.canHandle(auth?.redirectURL))! {
            auth?.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                if (error != nil) {
                    print("error");
                } else {
                    let userDefaults = UserDefaults.standard
                    let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                    userDefaults.set(sessionData, forKey: "SpotifySession")
                    userDefaults.synchronize()
                    auth?.session = session
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "sessionUpdated"), object: self)
            })
            return true
        }
        
        return false
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    


}

extension AppDelegate {
    func configureIntitialRootViewController(for window: UIWindow?) {
        //let defaults = UserDefaults.standard
        let initialViewController:UIViewController
        
        // skip the login flow if the currentuser has been set, firuser has been set
        if Auth.auth().currentUser != nil {
            
            initialViewController = UIStoryboard.initialViewController(for: .main)
            
        } else {
            initialViewController = UIStoryboard.initialViewController(for: .login)
        }
        
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }
}







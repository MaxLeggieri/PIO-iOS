//
//  AppDelegate.swift
//  PioAlert
//
//  Created by LiveLife on 03/06/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import GGLCore
import CoreLocation
import Braintree
import UserNotifications
//import GooglePlaces

let PIO_NETWORK_UUID = "7ADF3A88-FCCF-4C68-B9E0-F12143E3FCDB"

struct Color {
    
    //[UIColor colorWithRed:0.024 green:0.165 blue:0.471 alpha:1.00]
    
    // [UIColor colorWithRed:1.000 green:0.875 blue:0.000 alpha:1.00]
    
    
    //[UIColor colorWithRed:0.080 green:0.115 blue:0.147 alpha:1.00]
    
    static let primary = UIColor(red: 0.024, green: 0.165, blue: 0.471, alpha: 1)
    static let superDark = UIColor(red: 0.0, green: 0.0, blue: 0.080, alpha: 1)
    static let primaryDark = UIColor(red: 0.080, green: 0.115, blue: 0.147, alpha: 1)
    static let accent = UIColor(red: 1.000, green: 0.875, blue: 0.000, alpha: 1)
    static let facebook = UIColor(red: 26/255, green: 102/255, blue: 177/255, alpha: 1)
}

struct Login {
    static let None = 0
    static let FacebookLogged = 1
    static let GoogleLogged = 2
}

protocol NotificationDelegate {
    func notificationReceived(ids: [String])
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            
            
            
            WebApi.sharedInstance.sendGoogleUserData(user)
            
            PioUser.sharedUser.setUserName(user.profile.givenName)
            PioUser.sharedUser.setuserImagePath(user.profile.imageURL(withDimension: 40).absoluteString)
            
            print("logged in with Google")
            
            
        } else {
            WebApi.sharedInstance.isLogged = false
            print("\(error.localizedDescription)")
        }
    }


    var window: UIWindow?
    
    var gotNotification = false
    var notificationData:[AnyHashable: Any]?
    //var masterViewController:MasterViewController?
    
    
    
    var appIsInBackgroundOrKilled = false
    
    
    var notificationDelegate:NotificationDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        GIDSignIn.sharedInstance().delegate = self
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            print("Notification open from tray...")
            gotNotification = true
            notificationData = notification
            let idsString = notificationData!["idad"] as! String
            notificationIDs = idsString.components(separatedBy: ",")
            
            
        }
        
        
        if (launchOptions?[UIApplicationLaunchOptionsKey.location] as? [AnyHashable: Any]) != nil {
            
            PioLocationManager.sharedManager.locationManager.requestAlwaysAuthorization()
            
            
        }
        
        
        BTAppSwitch.setReturnURLScheme("com.livelife.PioAlert.payments")
        
        //GMSPlacesClient.provideAPIKey("AIzaSyBTq8Z4oTTLiC211VgP-ZZ9LbIDvfdc4rY")
        
        return true
    }
    
    
    
    /*
 
 
        PUSH NOTIFICATIONS
 
 
    */
    
    
    var registeredForNotifications = false
    func registerForNotifications() {
        
        
        if registeredForNotifications {
            return
        }
        
        
        
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                
                guard granted else { return }
                self.getNotificationSettings()
            }
        } else {
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(pushNotificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                UIApplication.shared.registerForRemoteNotifications()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    var currentToken:String!
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        
        if tokenString != currentToken {
        
            print("didRegisterForRemoteNotificationsWithDeviceToken:", tokenString)
        
            WebApi.sharedInstance.notificationToken = tokenString
            WebApi.sharedInstance.canReceiveNotifications = true
            UserDefaults.standard.set(true, forKey: "canReceiveNotifications")
            UserDefaults.standard.synchronize()
        
            WebApi.sharedInstance.tokenHandler()
            currentToken = tokenString
            registeredForNotifications = true
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print(error)
        WebApi.sharedInstance.canReceiveNotifications = false
        UserDefaults.standard.set(true, forKey: "canReceiveNotifications")
        UserDefaults.standard.set(true, forKey: "refusedNotifications")
        UserDefaults.standard.synchronize()
        
        WebApi.sharedInstance.deviceToken = "user_refused"
        WebApi.sharedInstance.tokenHandler()
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        
        
        gotNotification = true
        notificationData = userInfo
        let idsString = notificationData!["idad"] as! String
        notificationIDs = idsString.components(separatedBy: ",")
        
        if notificationDelegate != nil {
            notificationDelegate?.notificationReceived(ids: notificationIDs)
        }
        print("didReceiveRemoteNotification... \(notificationIDs.count)")
        
        /*
        if((self.masterViewController?.isViewLoaded) != nil) {
            if gotNotification {
                gotNotification = false
                showAlert()
                
                //masterViewController!.scrollToNotified()
            }
        }
        */
        
        
        
    }
    
    var notificationIDs = [String]()
    var notificationPointer = 0
    
    func showAlert() {
        
        WebApi.sharedInstance.sendNotificationConfirm(notificationData!)
        print(notificationData ?? "no notificationData")
        
        /*
        let title = notificationData!["aps"]!["alert"]!!["title"] as! String
        let body = notificationData!["aps"]!["alert"]!!["body"] as! String
        let idsString = notificationData!["idad"] as! String
        notificationIDs = idsString.components(separatedBy: ",")
        
        
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let actionShow = UIAlertAction(title: "Mostra", style: .default, handler: {(alert: UIAlertAction!) in
        
            self.gotNotification = false
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            self.masterViewController?.showNotificationsAds()
            
        })
        alertController.addAction(actionShow)
        
        self.masterViewController!.present(alertController, animated: true, completion: nil)
        
        gotNotification = false
        */
    }
    
    
    
    var token: Int = 0
    var chance = 3
    
    
    
    func getBeaconProximityString(_ value: Int) -> String {
        
        
        switch value {
        case CLProximity.far.rawValue:
            return "Far"
            
        case CLProximity.near.rawValue:
            return "Near"
            
        case CLProximity.immediate.rawValue:
            return "Immediate"
            
        case CLProximity.unknown.rawValue:
            return "Unknown"
            
        default:
            return "No value"
        }
        
        
    }
    
    /*
    var geocoding = false
    func geocodeLocation(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] 
                
                var address = ""
                
                if pm.thoroughfare != nil {
                    address += pm.thoroughfare!+", "
                }
                
                if pm.postalCode != nil {
                    address += pm.postalCode!+" "
                }

                
                if pm.locality != nil {
                    address += pm.locality!+" "
                }
                
                //print("LOCATION: "+address)
                
                WebApi.sharedInstance.userAddress = address
                UserDefaults.standard.setValue(address, forKey: "userAddress")
                UserDefaults.standard.synchronize()
                
                self.geocoding = false
                
                
            }
            else {
                print("Problem with the data received from geocoder")
            }
        });
    }
    */
    
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        /*
        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey:sourceApplication!,UIApplicationOpenURLOptionsAnnotationKey: annotation]
        */
        
        
        
        if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        else if GIDSignIn.sharedInstance().handle(url,sourceApplication:
            sourceApplication, annotation: annotation) {
            return true
        }
        
        if url.scheme?.localizedCaseInsensitiveCompare("com.livelife.PioAlert.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, sourceApplication: sourceApplication)
        }
        
        print("sourceApplication: "+sourceApplication!+" url: "+url.absoluteString)
        
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        
        // 1
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components =  URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        
        print("continueUserActivity: "+components.path+" "+components.query!)
        
        
        let queryComponents = components.query!.components(separatedBy: "&")
        let idadComp = queryComponents[0].components(separatedBy: "=")
        
        let idad = idadComp[1]
        
        let promo = WebApi.sharedInstance.getAdById(idad)
        
        
        
        let storyboard = UIStoryboard(name: "Virgi", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PromoViewController") as! PromoViewController
        
        vc.promo = promo
        
        Utility.sharedInstance.homeController.present(vc, animated: true, completion: nil)
 
        
        return false
        
        
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    
    /*
    func sign(signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!{
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    */

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        appIsInBackgroundOrKilled = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        appIsInBackgroundOrKilled = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
        appIsInBackgroundOrKilled = false
        application.applicationIconBadgeNumber = 0;
        
        /*
        if((self.masterViewController?.isViewLoaded()) != nil) {
            if gotNotification {
                gotNotification = false
                showAlert()
                
                //masterViewController!.scrollToNotified()
            }
        }
        */
        
        /*
        if gotNotification {
            gotNotification = false
            showAlert()
            
            //masterViewController!.scrollToNotified()
        }
        */
        
        if notificationDelegate != nil && gotNotification {
            notificationDelegate?.notificationReceived(ids: notificationIDs)
        }
        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        appIsInBackgroundOrKilled = true
    }


}


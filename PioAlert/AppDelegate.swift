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


let PIO_NETWORK_UUID = "7ADF3A88-FCCF-4C68-B9E0-F12143E3FCDB"

struct Color {
    static let primary = UIColor(red: 0, green: 0.592, blue: 0.655, alpha: 1)
    static let primaryDark = UIColor(red: 0, green: 0.474, blue: 0.529, alpha: 1)
    static let accent = UIColor(red: 1.000, green: 0.922, blue: 0.231, alpha: 1)
    static let facebook = UIColor(red: 26/255, green: 102/255, blue: 177/255, alpha: 1)
}

struct Login {
    static let None = 0
    static let FacebookLogged = 1
    static let GoogleLogged = 2
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var gotNotification = false
    var notificationData:[NSObject: AnyObject]?
    var masterViewController:MasterViewController?
    
    var beaconRegion:CLBeaconRegion!
    
    var canMonitoringRegions = false
    
    var appIsInBackgroundOrKilled = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            gotNotification = true
            notificationData = notification
        }
        
        
        if (launchOptions?[UIApplicationLaunchOptionsLocationKey] as? [NSObject : AnyObject]) != nil {
            locationManager.requestAlwaysAuthorization()
            //startLocationManager()
            //startMonitoringPioBeacons()
            
        }
        
        
        
        
        return true
    }
    
    /*
 
 
        PUSH NOTIFICATIONS
 
 
    */
    
    func registerForNotifications() {
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(pushNotificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        
        //print("DEVICE TOKEN = \(deviceToken)")
        
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
        
        WebApi.sharedInstance.notificationToken = tokenString
        WebApi.sharedInstance.canReceiveNotifications = true
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "canReceiveNotifications")
        NSUserDefaults.standardUserDefaults().setValue(tokenString, forKey: "deviceToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        
        WebApi.sharedInstance.sendDeviceToken()
        
        
        
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        print(error)
        WebApi.sharedInstance.canReceiveNotifications = false
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "canReceiveNotifications")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "refusedNotifications")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        WebApi.sharedInstance.deviceToken = "user_refused"
        WebApi.sharedInstance.sendDeviceToken()
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        
        print("didReceiveRemoteNotification...")
        gotNotification = true
        notificationData = userInfo
        
        
        if((self.masterViewController?.isViewLoaded()) != nil) {
            if gotNotification {
                gotNotification = false
                showAlert()
                
                //masterViewController!.scrollToNotified()
            }
        }
        
        
        
    }
    
    var notificationIDs = [String]()
    var notificationPointer = 0
    
    func showAlert() {
        
        
        
        WebApi.sharedInstance.sendNotificationConfirm(notificationData!)
        print(notificationData)
        
        let title = notificationData!["aps"]!["alert"]!!["title"] as! String
        let body = notificationData!["aps"]!["alert"]!!["body"] as! String
        let idsString = notificationData!["idad"] as! String
        notificationIDs = idsString.componentsSeparatedByString(",")
        
        
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .Alert)
        let actionShow = UIAlertAction(title: "Mostra", style: .Default, handler: {(alert: UIAlertAction!) in
        
            self.gotNotification = false
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            
            self.masterViewController?.showNotificationsAds()
            
            
        })
        alertController.addAction(actionShow)
        
        self.masterViewController!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func startLocationManager() {
        print("starting LOCATION MANAGER")
        geocoding = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        //locationManager.requestWhenInUseAuthorization()
        
        //locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        manager.stopUpdatingLocation()
        print(error)
    }
    
    var token: dispatch_once_t = 0
    var chance = 3
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        if location?.horizontalAccuracy > 200 {
            //print("location accuracy: \(location?.horizontalAccuracy)")
            return
        }
        
        currentLocation = location
        //print(currentLocation)
            
        
        NSUserDefaults.standardUserDefaults().setDouble(location!.coordinate.latitude, forKey: "lat")
        NSUserDefaults.standardUserDefaults().setDouble(location!.coordinate.longitude, forKey: "lng")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        dispatch_once(&token) {
            print("registerForNotifications()...")
            self.registerForNotifications()
        }
        
        manager.stopUpdatingLocation()
        geocodeLocation(location!)
        
        
    }
    
    var bgTask:UIBackgroundTaskIdentifier?
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Did entered region for: "+region.identifier)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Did exit region for: "+region.identifier)
    }
    /*
    func launchBgBeaconRanging() {
        bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithName("rangingBeacons", expirationHandler: {
            
            print("Background task end...")
            
        })
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
            
        })
    }
    */
    
    
    
    func sendBeaconNotification(body: String) {
        let notification = UILocalNotification()
        notification.alertBody = body
        notification.alertAction = "Guarda l'offerta"
        notification.fireDate = NSDate()
        notification.soundName = "blip.caf"//UILocalNotificationDefaultSoundName
        //notification.userInfo = ["title": "Benvenuto!", "UUID": PIO_NETWORK_UUID] // assign a unique identifier to the notification so that we can retrieve it later
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    
    
    dynamic var lastCloserBeacon:CLBeacon!
    
    var beaconAlertOn = false
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        
        
        //print("Found beacons...")
        
        
        let knownBeacons = beacons.filter{ ($0.proximity != CLProximity.Unknown) &&  ($0.proximity != CLProximity.Far) && ($0.accuracy <= 2.0) }
        //let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Far }
        
        if knownBeacons.count == 0 {
            return
        }
        
        
        
        if knownBeacons.first!.proximityUUID.UUIDString == PIO_NETWORK_UUID {
            
            lastCloserBeacon = knownBeacons.first
            /*
            print("########## PIO BEACON ##########")
            print("UUID: "+lastCloserBeacon.proximityUUID.UUIDString)
            print("Accuracy: \(lastCloserBeacon.accuracy)")
            print("RSSI: \(lastCloserBeacon.rssi)")
            print("Proximity: "+getBeaconProximityString(lastCloserBeacon.proximity.rawValue))
            */
            print("Getting data for Company: "+lastCloserBeacon.major.stringValue+" Zone: "+lastCloserBeacon.minor.stringValue)
            
            print("\n")
            
            /*
            var body = ""
            switch lastCloserBeacon.minor.integerValue {
            case 1:
                body = "Benvenuto al camino! Freddo?"
                break
            case 2:
                body = "Benvenuto in cucina. Non scuocere la pasta!"
                break
            case 3:
                body = "Sei nel corridoio... Il bagno è più avanti a sinistra"
                break
            default:
                break
            }
            
            
            if appIsInBackgroundOrKilled {
                sendBeaconNotification(lastCloserBeacon, body: body)
                
                if self.bgTask != UIBackgroundTaskInvalid{
                    UIApplication.sharedApplication().endBackgroundTask(
                        self.bgTask!)
                    self.bgTask = UIBackgroundTaskInvalid
                }
            } else {
                let alertController = UIAlertController(title: "Ciao!", message: body, preferredStyle: .Alert)
                let doneAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                    print("you have pressed OK button")
                    self.beaconAlertOn = false
                    
                }
                alertController.addAction(doneAction)
                
                if !beaconAlertOn {
                    self.masterViewController!.presentViewController(alertController, animated: true, completion:nil)
                    self.beaconAlertOn = true
                }
                
            }
            */
            
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
        
        if state == CLRegionState.Inside {
            print("locationManager didDetermineState INSIDE for "+region.identifier)
        }
        else if state == CLRegionState.Outside  {
            print("locationManager didDetermineState OUTSIDE for "+region.identifier)
        }
        else {
            print("locationManager didDetermineState OTHER for "+region.identifier)
        }
        
    }
    
    func getBeaconProximityString(value: Int) -> String {
        
        
        switch value {
        case CLProximity.Far.rawValue:
            return "Far"
            
        case CLProximity.Near.rawValue:
            return "Near"
            
        case CLProximity.Immediate.rawValue:
            return "Immediate"
            
        case CLProximity.Unknown.rawValue:
            return "Unknown"
            
        default:
            return "No value"
        }
        
        
    }
    
    var geocoding = false
    
    func geocodeLocation(location: CLLocation) {
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
                NSUserDefaults.standardUserDefaults().setValue(address, forKey: "userAddress")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.geocoding = false
                
                
            }
            else {
                print("Problem with the data received from geocoder")
            }
        });
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            print("NotDetermined")
            //locationManager.requestAlwaysAuthorization()
            break
        case .AuthorizedWhenInUse:
            print("AuthorizedWhenInUse")
            locationManager.startUpdatingLocation()
            
            startMonitoringPioBeacons()
            
            break
        case .AuthorizedAlways:
            print("AuthorizedAlways")
            
            locationManager.startUpdatingLocation()
            
            startMonitoringPioBeacons()
            
            
            break
        case .Restricted:
            print("Restricted")
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .Denied:
            print("Denied")
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        }
    }
    
    
    func updateLocationAddress() {
        geocoding = true
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    
    func startMonitoringPioBeacons() {
        
        if beaconRegion == nil {
            beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: PIO_NETWORK_UUID)!, identifier: "PioNEAR")
            
            
            beaconRegion.notifyEntryStateOnDisplay = true
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
            locationManager.startMonitoringForRegion(beaconRegion)
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
        
        
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        /*
        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey:sourceApplication!,UIApplicationOpenURLOptionsAnnotationKey: annotation]
        */
        
        
        
        if FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        else if GIDSignIn.sharedInstance().handleURL(url,sourceApplication:
            sourceApplication, annotation: annotation) {
            return true
        }
        
        
        return false
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            
            
            
            WebApi.sharedInstance.sendGoogleUserData(user)
            WebApi.sharedInstance.loggedWith = Login.GoogleLogged
            
            WebApi.sharedInstance.userName = user.profile.givenName
            WebApi.sharedInstance.userImagePath = user.profile.imageURLWithDimension(40).absoluteString
            
            NSUserDefaults.standardUserDefaults().setValue(WebApi.sharedInstance.userName, forKey: "userName")
            NSUserDefaults.standardUserDefaults().setValue(WebApi.sharedInstance.userImagePath, forKey: "userImagePath")
            NSUserDefaults.standardUserDefaults().synchronize()
            NSUserDefaults.standardUserDefaults().setValue(WebApi.sharedInstance.loggedWith, forKey: "loggedWith")
            print("logged in with Google")
            
            
        } else {
            WebApi.sharedInstance.isLogged = false
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        appIsInBackgroundOrKilled = true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        appIsInBackgroundOrKilled = true
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
        appIsInBackgroundOrKilled = false
        
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
        
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        appIsInBackgroundOrKilled = true
    }


}


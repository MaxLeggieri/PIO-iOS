//
//  PioUser.swift
//  PioAlert
//
//  Created by LiveLife on 20/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import Foundation
import MapKit

class PioUser {
    static let sharedUser = PioUser()
    
    var userCat = [Int]()
    
    var logged = false
    var profiled = false
    var consent = false
    var consentGeo = false
    var consentData = false
    var localized = false
    
    var readGeneral = false
    var readPrivacy = false
    
    
    var userName = ""
    var userImagePath = ""
    
    var location = CLLocation(latitude: 41.899254, longitude: 12.494790)
    var userLat = 41.899254
    var userLon = 12.494790
    
    var uid = 0
    
    var rankData:[String:AnyObject]!
    
    func updateUser() {
        logged = UserDefaults.standard.bool(forKey: "logged")
        profiled = UserDefaults.standard.bool(forKey: "profiled")
        
        localized = UserDefaults.standard.bool(forKey: "localized")
        userLat = UserDefaults.standard.double(forKey: "userLat")
        userLon = UserDefaults.standard.double(forKey: "userLon")
        location = CLLocation(latitude: userLat, longitude: userLon)
        
        uid = UserDefaults.standard.integer(forKey: "uid")
        if UserDefaults.standard.object(forKey: "userCat") == nil {
            UserDefaults.standard.set(userCat, forKey: "userCat")
        } else {
            userCat = UserDefaults.standard.object(forKey: "userCat") as! [Int]
        }
        
        consent = UserDefaults.standard.bool(forKey: "consent")
        consentGeo = UserDefaults.standard.bool(forKey: "consentGeo")
        consentData = UserDefaults.standard.bool(forKey: "consentData")
        
        if let un = UserDefaults.standard.string(forKey: "userName") {
            userName = un
            userImagePath = UserDefaults.standard.string(forKey: "userImagePath")!
        }
        
        
        UserDefaults.standard.synchronize()
    }
    
    func setLogged(_ logged: Bool) {
        self.logged = logged
        UserDefaults.standard.set(logged, forKey: "logged")
        UserDefaults.standard.synchronize()
    }
    
    func setProfiled(_ profiled: Bool) {
        self.profiled = profiled
        UserDefaults.standard.set(profiled, forKey: "profiled")
        UserDefaults.standard.synchronize()
    }
    
    func setLocalized(_ localized: Bool) {
        self.localized = localized
        
        UserDefaults.standard.set(localized, forKey: "localized")
        UserDefaults.standard.synchronize()
        
        location = CLLocation(latitude: userLat, longitude: userLon)
    }
    
    func setUserPosition(_ userLat: Double, userLon: Double) {
        self.userLat = userLat
        self.userLon = userLon
        
        UserDefaults.standard.set(userLat, forKey: "userLat")
        UserDefaults.standard.set(userLon, forKey: "userLon")
        UserDefaults.standard.synchronize()
        
        location = CLLocation(latitude: userLat, longitude: userLon)
    }
    
    func setUid(_ uid: Int) {
        self.uid = uid
        
        UserDefaults.standard.set(uid, forKey: "uid")
        UserDefaults.standard.synchronize()
    }
    
    func setUserCat(_ userCat: [Int]) {
        
        self.userCat = userCat
        
        UserDefaults.standard.set(userCat, forKey: "userCat")
        UserDefaults.standard.synchronize()
        
    }
    
    func setGeoConsent(_ consentGeo: Bool) {
        self.consentGeo = consentGeo
        
        UserDefaults.standard.set(consentGeo, forKey: "consentGeo")
        UserDefaults.standard.synchronize()
        
    }
    
    func setDataConsent(_ consentData: Bool) {
        self.consentData = consentData
        
        UserDefaults.standard.set(consentGeo, forKey: "consentData")
        UserDefaults.standard.synchronize()
        
    }
    
    func setGeneralConsent(_ consent: Bool) {
        self.consent = consent
        
        UserDefaults.standard.set(consent, forKey: "consent")
        UserDefaults.standard.synchronize()
        
    }
    
    func setReadGeneral(read: Bool) {
        self.readGeneral = read
    }
    
    func setReadPrivacy(read: Bool) {
        self.readPrivacy = read
    }
    
    func setUserName(_ userName: String) {
        self.userName = userName
        
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.synchronize()
    }
    
    func setuserImagePath(_ userImagePath: String) {
        self.userImagePath = userImagePath
        
        UserDefaults.standard.set(userImagePath, forKey: "userImagePath")
        UserDefaults.standard.synchronize()
    }
    
    
}

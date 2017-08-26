//
//  PioLocationManager.swift
//  PioAlert
//
//  Created by LiveLife on 20/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import CoreLocation


protocol PioLocationManagerDelegate {
    func userLocationChanged()
    func userPermissionChanged(_ status: CLAuthorizationStatus)
}

class PioLocationManager: NSObject, CLLocationManagerDelegate {
    
    var delegate:PioLocationManagerDelegate!
    
    
    static let sharedManager = PioLocationManager()
    
    
    let locationManager = CLLocationManager()
    
    func startTrackingUser() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        /*
        if locations.last?.horizontalAccuracy > 200 {
            print("Accuracy low...")
            return
        }
        */
        
        PioUser.sharedUser.location = locations.last!
        
        if delegate != nil {
            delegate.userLocationChanged()
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        case .notDetermined:
            print("NotDetermined")
            break
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            PioUser.sharedUser.setLocalized(true)
            manager.startUpdatingLocation()
            startMonitoringPioBeacons()
            break
        case .authorizedAlways:
            print("AuthorizedAlways")
            manager.startUpdatingLocation()
            startMonitoringPioBeacons()
            break
        default:
            break
        }
        
        if delegate != nil {
            delegate.userPermissionChanged(status)
        }
    }
    
    
    var beaconRegion:CLBeaconRegion!
    func startMonitoringPioBeacons() {
        
        if beaconRegion == nil {
            beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: PIO_NETWORK_UUID)!, identifier: "PioNEAR")
            
            
            beaconRegion.notifyEntryStateOnDisplay = true
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(in: beaconRegion)
        }
        
        
    }
    
    dynamic var lastCloserBeacon:CLBeacon!
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        
        
        //print("Found beacons...")
        
        
        let knownBeacons = beacons.filter{ ($0.proximity != CLProximity.unknown) }
        //let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Far }
        
        if knownBeacons.count == 0 {
            return
        }
        
        
        
        if knownBeacons.first!.proximityUUID.uuidString == PIO_NETWORK_UUID {
            
            lastCloserBeacon = knownBeacons.first
            
            
            
            /*
            print("########## PIO BEACON ##########")
            print("UUID: "+lastCloserBeacon.proximityUUID.uuidString)
            print("Accuracy: \(lastCloserBeacon.accuracy)")
            print("RSSI: \(lastCloserBeacon.rssi)")
            
            print("Getting data for Company: "+lastCloserBeacon.major.stringValue+" Zone: "+lastCloserBeacon.minor.stringValue)
            
            print("\n")
            */
            
            
            WebApi.sharedInstance.sendBeaconData(lastCloserBeacon.major.stringValue, minor: lastCloserBeacon.minor.stringValue, uuid: lastCloserBeacon.proximityUUID.uuidString, accuracy: String(lastCloserBeacon.accuracy))
            
            
            
            
        }
        
    }
    
    
    
}

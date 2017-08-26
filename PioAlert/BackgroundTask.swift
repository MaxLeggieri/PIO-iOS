//
//  BackgroundTask.swift
//  PioAlert
//
//  Created by LiveLife on 12/09/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//
import UIKit

class BackgroundTask {
    fileprivate let application: UIApplication
    fileprivate var identifier = UIBackgroundTaskInvalid
    
    init(application: UIApplication) {
        self.application = application
    }
    
    class func run(_ application: UIApplication, handler: (BackgroundTask) -> ()) {
        // NOTE: The handler must call end() when it is done
        
        let backgroundTask = BackgroundTask(application: application)
        backgroundTask.begin()
        handler(backgroundTask)
    }
    
    func begin() {
        self.identifier = application.beginBackgroundTask (expirationHandler: {
            self.end()
        })
    }
    
    func end() {
        if (identifier != UIBackgroundTaskInvalid) {
            application.endBackgroundTask(identifier)
        }
        
        identifier = UIBackgroundTaskInvalid
    }
}

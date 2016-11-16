//
//  NotificationsController.swift
//  PioAlert
//
//  Created by LiveLife on 06/07/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class NotificationsController: UIViewController, WebApiDelegate {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        WebApi.sharedInstance.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear...")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func askForNotificationsPermissions() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.startLocationManager()
    }
    
    func didSendApiMethod(method: String, result: String) {
        print("didSendApiMethod... "+method+" result: "+result);
        
        if method == "tokenHandler" {
            dispatch_async(dispatch_get_main_queue()) {
                let vc = self.presentingViewController as? MasterViewController
                WebApi.sharedInstance.delegate = vc
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }
    
    func errorSendingApiMethod(method: String, error: String) {
        print(error)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

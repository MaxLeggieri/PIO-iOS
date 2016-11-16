//
//  LocationController.swift
//  PioAlert
//
//  Created by LiveLife on 20/08/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class LocationController: UIViewController {

    @IBOutlet weak var topBar:UIView!
    @IBOutlet weak var updateButton:UIButton!
    @IBOutlet weak var locationLabel:UILabel!
    @IBOutlet weak var loader:UIActivityIndicatorView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topBar.layer.shadowColor = UIColor.blackColor().CGColor
        topBar.layer.shadowOpacity = 0.6
        topBar.layer.shadowOffset = CGSizeMake(0, 2)
        
        loader.hidden = true
        
        locationLabel.text = WebApi.sharedInstance.userAddress
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var timer:NSTimer!
    
    @IBAction func updateLocation(sender: UIButton) {
        appDelegate.updateLocationAddress()
        loader.hidden = false
        loader.startAnimating()
        updateButton.enabled = false
        updateButton.alpha = 0.4
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(LocationController.checkGeocoding), userInfo: nil, repeats: true)
        
    }
    
    func checkGeocoding() {
        print("checkGeocoding...")
        if !appDelegate.geocoding {
            timer.invalidate()
            locationLabel.text = WebApi.sharedInstance.userAddress
            loader.stopAnimating()
            loader.hidden = true
            updateButton.enabled = true
            updateButton.alpha = 1
        }
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

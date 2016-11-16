//
//  PioNavigationController.swift
//  PioAlert
//
//  Created by LiveLife on 06/10/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class PioNavigationController: UINavigationController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem?.title = ""
        //self.navigationBar.barStyle = UIBarStyle.
        //self.navigationBar.barTintColor = Color.primaryDark
        /*
        self.navigationBar.layer.shadowColor = UIColor.blackColor().CGColor
        self.navigationBar.layer.shadowOffset = CGSizeMake(0, 1)
        //self.navigationBar.layer.shadowRadius = 4
        self.navigationBar.layer.shadowOpacity = 0.4
        self.navigationBar.layer.masksToBounds = false
        */
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

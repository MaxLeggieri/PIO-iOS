//
//  InfoController.swift
//  PioAlert
//
//  Created by LiveLife on 19/07/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class InfoController: UIViewController {

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismiss(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

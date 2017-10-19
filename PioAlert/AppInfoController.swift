//
//  AppInfoController.swift
//  PioAlert
//
//  Created by LiveLife on 31/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class AppInfoController: UIViewController {

    
    @IBOutlet weak var claimTitle:UILabel!
    @IBOutlet weak var claimDesc:UILabel!
    
    @IBOutlet weak var versionLabel:UILabel!
    @IBOutlet weak var buildLabel:UILabel!
    
    @IBAction func dismissInfo(sender: RoundedButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let claim = WebApi.sharedInstance.claim()
        
        claimTitle.text = claim[0]
        claimDesc.text = claim[1]
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        versionLabel.text = "version "+version
        buildLabel.text = "build "+build
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}

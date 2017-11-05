//
//  IPController.swift
//  PioAlert
//
//  Created by LiveLife on 27/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class IPController: UIViewController {

    
    @IBOutlet weak var webView:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "http://www.pioalert.com/app/privacy/")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

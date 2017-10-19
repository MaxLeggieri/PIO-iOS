//
//  PoiController.swift
//  PioAlert
//
//  Created by LiveLife on 10/08/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class PoiController: UIViewController {
    
    
    @IBOutlet weak var navTitle:UILabel!
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var phoneButton:UIButton!
    @IBOutlet weak var fixedPhoneButton:UIButton!
    @IBOutlet weak var locationLabel:UILabel!
    @IBOutlet weak var webButton:UIButton!
    
    var result:[String:AnyObject]!
    var websiteUrl:String!
    var phone:String!
    var address:String!
    var photoReference:String!
    
    @IBAction func dismissPoi(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nameString = result["name"] as! String
        
        navTitle.text = nameString
        name.text = nameString
        
        if let pn = result["formatted_phone_number"] as? String {
            phone = pn
            phoneButton.setTitle(phone, for: .normal)
        } else {
            phoneButton.isHidden = true
            fixedPhoneButton.isHidden = true
        }
        address = result["formatted_address"] as! String
        locationLabel.text = address
        
        if let url = result["website"] as? String {
            websiteUrl = url
        } else {
            webButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        if photoReference != nil {
            
            
            if photoReference == "noimage" {
                imageView.image = UIImage(named: "signin-logo-pio")
            } else {
                let path = "https://maps.googleapis.com/maps/api/place/photo?photoreference="+photoReference+"&maxwidth=1280&key=AIzaSyDRV45yi1TJZDx3rCNe5S-9qmRy3AtonPI"
                WebApi.sharedInstance.downloadedFrom(imageView, link: path, mode: .scaleAspectFill, shadow: false)
            }
            
            
            
            
            
        }
    }
    
    @IBAction func showWebsite(sender: UIButton) {
        
        if let requestUrl = URL(string: websiteUrl) {
            UIApplication.shared.openURL(requestUrl)
        }
        
    }

    @IBAction func callPoi(sender: UIButton) {
        let clean = phone.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        if let url = URL(string: "tel://"+clean), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

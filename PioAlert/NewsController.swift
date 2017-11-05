//
//  NewsController.swift
//  PioAlert
//
//  Created by Max L. on 22/10/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class NewsController: UIViewController {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var descLabel:UILabel!
    @IBOutlet weak var linkButton:RoundedButton!
    @IBOutlet weak var attButton:RoundedButton!
    @IBOutlet weak var videoButton:RoundedButton!
    
    var promo:Promo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = promo.title
        nameLabel.text = promo.title
        descLabel.text = promo.desc
        
        if promo.link == "" {
            linkButton.isHidden = true
        }
        if promo.attachment == "" {
            attButton.isHidden = true
        }
        if promo.youtube == "" {
            videoButton.isHidden = true
        }
        
    }
    
    @IBAction func open(_ sender: UIButton) {
        
        if sender.tag == 1 {
            if let requestUrl = URL(string: promo!.link) {
                UIApplication.shared.openURL(requestUrl)
            }
        }
        else if sender.tag == 2 {
            if let requestUrl = URL(string: "http://pioalert.com"+promo!.attachment) {
                UIApplication.shared.openURL(requestUrl)
            }
        }
        else if sender.tag == 3 {
            if let requestUrl = URL(string: promo!.youtube) {
                UIApplication.shared.openURL(requestUrl)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let imgPath = "http://pioalert.com/imgDelivery/?i="+promo.imagePath+"&w=250";
        WebApi.sharedInstance.downloadedFrom(image, link: imgPath, mode: .scaleAspectFill, shadow: false)
        
        
    }

    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

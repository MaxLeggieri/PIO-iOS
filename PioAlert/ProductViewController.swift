//
//  ProductViewController.swift
//  PioAlert
//
//  Created by LiveLife on 25/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import MessageUI

class ProductViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var navTitle:UILabel!
    @IBOutlet weak var prodTitle:UILabel!
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var finalPrice:UILabel!
    @IBOutlet weak var initialPrice:UILabel!
    @IBOutlet weak var priceOff:UILabel!
    @IBOutlet weak var availability:UILabel!
    @IBOutlet weak var companyName:UILabel!
    @IBOutlet weak var companyAddress:UILabel!
    @IBOutlet weak var prodDesc:UILabel!
    
    var product:Product!

    override func viewDidLoad() {
        super.viewDidLoad()

        navTitle.text = product.companyName
        prodTitle.text = product.name
        finalPrice.text = "€ "+product.price
        
        //initialPrice.text = "€ "+product.initialPrice
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "€ "+product.initialPrice)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        initialPrice.attributedText = attributeString
        
        if product.initialPrice == "0" {
            initialPrice.isHidden = true
            priceOff.isHidden = true
        } else {
            initialPrice.isHidden = false
        }
        
        priceOff.text = "Risparmi € "+product.priceOff
        availability.text = String(product.available)+" unità"
        companyName.text = product.companyName
        companyAddress.text = product.companyAddress
        prodDesc.text = product.descLong
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        WebApi.sharedInstance.downloadedFrom(image, link: "https://www.pioalert.com"+product.image, mode: .scaleAspectFit, shadow: true)
        
        Utility.sharedInstance.addFullscreenTouch(image, selector: #selector(showImageFullscreen), target: self)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissProduct(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func showImageFullscreen(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        Utility.sharedInstance.startImageZoomController(sender: imageView, parent: self)
    }

    @IBAction func sendEmail(sender: AnyObject) {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        var rec = [String]()
        rec.append("feedback@pioalert.com")
        if product.companyEmail != "arnaldoguido@email.com" {
            rec.append(product.companyEmail)
        }
        mailVC.setToRecipients(rec)
        mailVC.setSubject("Richiesta informazioni su: "+product.name)
        
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addToCart(sender: UIButton) {
        
        WebApi.sharedInstance.basketMove(product.pid, quantity: 1)
        
        self.performSegue(withIdentifier: "showCartFromProduct", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCartFromProduct" {
            let vc = segue.destination as! CartViewController
            vc.comId = product.idCom
        }
    }

}

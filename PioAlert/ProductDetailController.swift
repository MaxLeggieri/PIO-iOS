//
//  ProductDetailController.swift
//  PioAlert
//
//  Created by LiveLife on 06/10/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit


class ProductDetailController: UIViewController, WebApiDelegate {

    var selectedProduct:Product!
    var companyName:String!
    var prodId:Int!
    var isFromSearch:Bool!
    
    @IBOutlet weak var productLabel:UILabel!
    @IBOutlet weak var descLabel:UILabel!
    @IBOutlet weak var priceLabel:UILabel!
    @IBOutlet weak var initialPriceLabel:UILabel!
    @IBOutlet weak var shippingLabel:UILabel!
    
    @IBOutlet weak var addToCartButton:UIButton!
    
    @IBOutlet weak var productImage:UIImageView!
    
    @IBOutlet weak var scrollView:UIScrollView!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        
        WebApi.sharedInstance.delegate = self
        super.viewDidAppear(animated)
        
        if selectedProduct == nil {
            selectedProduct = WebApi.sharedInstance.getProductById(String(prodId))
        }
        
        UIView.animateWithDuration(0.15) {
            
            self.scrollView.alpha = 1
        }
        
        self.navigationItem.title = "Dettaglio prodotto"
        
        productLabel.text = selectedProduct.name
        descLabel.text = selectedProduct.descLong
        priceLabel.text = "€"+selectedProduct.price
        
        if selectedProduct.initialPrice != "0" {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "€"+selectedProduct.initialPrice)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            initialPriceLabel.attributedText = attributeString
        } else {
            initialPriceLabel.hidden = true
        }
        WebApi.sharedInstance.downloadedFrom(productImage, link: "http://www.pioalert.com"+selectedProduct.image, mode: .ScaleAspectFit, shadow: true)
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        WebApi.sharedInstance.delegate = self
        // Do any additional setup after loading the view.
        
        
        
        self.scrollView.alpha = 0
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    /*
    @IBAction func buyNow() {
        
        
        WebApi.sharedInstance.getPaypalClientToken()
        
        /*
        self.braintreeClient = BTAPIClient(authorization: clientToken)
        
        
        print("Braintree clientToken: "+clientToken)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.processPayment()
        }
        */
        
    }
    */
    
    @IBAction func addToCart() {
        
        WebApi.sharedInstance.basketAddProduct(selectedProduct.pid)
        
    }
    
    func didSendApiMethod(method: String, result: String) {
        
        print(method+": "+result)
        
        if method == "basketAddProduct" {
            self.performSegueWithIdentifier("showCart", sender: self)
        }
    }
    
    func errorSendingApiMethod(method: String, error: String) {
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showCart" {
            
            let vc = segue.destinationViewController as! CartController
            vc.idCom = selectedProduct.idCom
            
        }
        
    }
    

}

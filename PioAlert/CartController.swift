//
//  CartController.swift
//  PioAlert
//
//  Created by LiveLife on 11/10/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit
import Braintree

class CartController: UITableViewController, BTDropInViewControllerDelegate, WebApiDelegate {

    
    @IBOutlet weak var shippingAddress:UILabel!
    @IBOutlet weak var changeShippingButton:UIButton!
    @IBOutlet weak var subtotalLabel:UILabel!
    @IBOutlet weak var shippingLabel:UILabel!
    @IBOutlet weak var totalLabel:UILabel!
    @IBOutlet weak var checkoutButton:UIButton!
    
    var braintreeClient:BTAPIClient?
    
    var selectedCart:Cart!
    var idCom:Int!
    
    var gotShippingAddress:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        WebApi.sharedInstance.delegate = self
        selectedCart = WebApi.sharedInstance.basketShow(idCom)
        
        
        
        shippingAddress.text = selectedCart.shippingAddress
        subtotalLabel.text = "€"+String(selectedCart.subTotal)
        let total = selectedCart.subTotal+selectedCart.shippingTotal
        totalLabel.text = "€"+String(total)
        
        self.navigationItem.title = "Acquisto in "+selectedCart.companyName
        
        gotShippingAddress = NSUserDefaults.standardUserDefaults().boolForKey("gotShippingAddress")
        WebApi.sharedInstance.delegate = self
        
        tableView.reloadData()
    }
    
    /*
    func checkShipping() {
        
        // Update shipping price?
        
        gotShippingAddress = NSUserDefaults.standardUserDefaults().boolForKey("gotShippingAddress")
        
    }
    */
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        WebApi.sharedInstance.delegate = self
        gotShippingAddress = NSUserDefaults.standardUserDefaults().boolForKey("gotShippingAddress")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkOut() {
        
        if !gotShippingAddress {
            let alert = UIAlertController(title: "Attenzione", message: "Non hai specificato un indirizzo di spedizione! Premi 'Cambia indirizzo' per specificarne uno.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            
            // Paypal
            WebApi.sharedInstance.getPaypalClientToken()
            
        }
        
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCart.products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: CartItemViewCell!
        
        
        cell = tableView.dequeueReusableCellWithIdentifier("cartItemViewCell", forIndexPath: indexPath) as! CartItemViewCell
        
        
        let product = selectedCart.products[indexPath.row]
        
        WebApi.sharedInstance.downloadedFrom(cell.pImage, link: product.image, mode: .ScaleAspectFill, shadow: false)
        cell.pImage.alpha = 0
        
        cell.pName.text = product.name
        cell.pPrice.text = "Prezzo unitario: €"+product.price
        
        cell.pQuantity.text = "Quantità: \(product.quantity)"
        
        let p = Double(product.price)
        let q = Double(product.quantity)
        let tot = p!*q
        cell.pTotal.text = "€\(tot)"
        
        return cell
        
    }
    
    
    // PAYPAL
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        
        print("didSucceedWithTokenization: "+paymentMethodNonce.nonce+" type: "+paymentMethodNonce.type)
        
        postNonceToServer(paymentMethodNonce.nonce, amount: String(selectedCart.subTotal))
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        
        print("dropInViewControllerDidCancel...")
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func postNonceToServer(paymentMethodNonce: String, amount: String) {
        let paymentURL = NSURL(string: WebApi.sharedInstance.apiAddress)!
        let request = NSMutableURLRequest(URL: paymentURL)
        request.HTTPBody = "method=payPalTrans&basketId=\(selectedCart.cartId!)&payment_method_nonce=\(paymentMethodNonce)&amount=\(amount)".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            
            if error == nil {
                let response = String(data: data!, encoding: NSUTF8StringEncoding)
                print("postNonceToServer success: "+response!)
            } else {
                print("postNonceToServer error: "+error.debugDescription)
            }
            
            
        }.resume()
    }
    
    func didSendApiMethod(method: String, result: String) {
        
        if method == "getPaypalClientToken" {
            
            self.braintreeClient = BTAPIClient(authorization: result)
            dispatch_async(dispatch_get_main_queue()) {
                //WebApi.sharedInstance.sendFakePOST("arnaldo numero uno", data2: "arnaldo COMANDA")
                self.processPayment()
            }
        }
         
        /*
        else if method == "basketAddProduct" {
            
            print("basketAddProduct: "+result)
            
            self.performSegueWithIdentifier("showCart", sender: self)
            
            
        }
        */
        
    }
    
    func errorSendingApiMethod(method: String, error: String) {
        print("errorSendingApiMethod: "+error)
    }
    
    func processPayment() {
        
        // Create a BTDropInViewController
        let dropInViewController = BTDropInViewController(APIClient: braintreeClient!)
        dropInViewController.delegate = self
        
        // This is where you might want to customize your view controller (see below)
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally-presented navigation controller:
        
        dropInViewController.view.tintColor = Color.primaryDark
        let paymentRequest = BTPaymentRequest()
        paymentRequest.summaryTitle = "Acquisto su "+selectedCart.companyName //selectedProduct.name
        paymentRequest.summaryDescription = "Spedito in 7 giorni"
        paymentRequest.displayAmount = "€\(selectedCart.subTotal)"
        paymentRequest.callToActionText = "Paga adesso - €\(selectedCart.subTotal)"
        
        dropInViewController.paymentRequest = paymentRequest
        
        
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Cancel,
            target: self, action: #selector(CartController.userDidCancelPayment))
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        presentViewController(navigationController, animated: true, completion: nil)
        
        
    }
    
    func userDidCancelPayment() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}


//
//  CartViewController.swift
//  PioAlert
//
//  Created by LiveLife on 26/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,BTDropInViewControllerDelegate {
    
    
    
    
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var navTitle:UILabel!
    
    @IBOutlet weak var shippingAddress:UILabel!
    @IBOutlet weak var subtotalAmount:UILabel!
    @IBOutlet weak var shippingAmount:UILabel!
    @IBOutlet weak var totalAmount:UILabel!
    @IBOutlet weak var messageTextField:UITextField!
    
    @IBOutlet weak var buyDhlButton:UIButton!
    @IBOutlet weak var buyRegularButton:UIButton!
    
    @IBOutlet weak var changeShippingButton:UIButton!
    
    var braintreeClient:BTAPIClient?
    var currentDhlRateAmount:String!
    var currentDhlRateId:Int!
    var currentPaypalClientToken:String!
    var finalTotal:Double!
    
    var cart:Cart!
    var comId:Int!

    @IBAction func dismissCart(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        messageTextField.delegate = self
        
        buyDhlButton.isEnabled = false
        buyDhlButton.alpha = 0.4
        buyRegularButton.isEnabled = false
        buyRegularButton.alpha = 0.4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCart()
    }
    
    func closeCart() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func reloadShippingData() {
        let userData = WebApi.sharedInstance.shippingAddressGet()
        
        
        if (userData["address"] as? String) != nil {
            let name = userData["first_name"] as! String
            let surname = userData["last_name"] as! String
            let address = userData["address"] as! String
            let zip = userData["zip"] as! String
            let town = userData["town"] as! String
            let province = userData["province"] as! String
            
            DispatchQueue.main.async {
                self.shippingAddress.text = name+" "+surname+"\n"+address+"\n"+zip+" "+town+" ("+province+")"
            }
            PioUser.sharedUser.setGotShippingAddress(true)
        } else {
            self.shippingAddress.text = "Premi 'Cambia indirizzo' per inserire un indirizzo di spedizione"
        }
        
    }
    func updateCart() {
        cart = WebApi.sharedInstance.basketShow(comId)
        print("\(cart.products.count) prodotti nel carrello")
        if cart.products.count == 0 {
            perform(#selector(closeCart), with: nil, afterDelay: 0.3)
        } else {
            navTitle.text = cart.companyName
            subtotalAmount.text = Utility.sharedInstance.formatPrice(price: cart.subTotal)
            
            reloadShippingData()
            
            let total = cart.subTotal + cart.shippingTotal
            totalAmount.text = Utility.sharedInstance.formatPrice(price: total)
            
            
            shippingAddress.text = cart.shippingAddress
            self.subtotalAmount.text = Utility.sharedInstance.formatPrice(price: cart.subTotal)
            self.shippingAmount.text = "€ 0.00"
            self.navigationItem.title = "Carrello in "+cart.companyName
            
            if cart.sellingMethod == 1 {
                
                
                self.buyDhlButton.isEnabled = false
                self.buyDhlButton.alpha = 0.4
                
                self.buyRegularButton.isEnabled = false
                self.buyRegularButton.alpha = 0.4
                
                var isServiceOrBooking = false
                for p in cart.products {
                    print("CALENDAR TYPE "+p.calendarType!)
                    if p.calendarType != "0" {
                        isServiceOrBooking = true
                        break
                    }
                }
                
                
                DispatchQueue.global(qos: .background).async {
                    
                    if PioUser.sharedUser.gotShippingAddress && !isServiceOrBooking {
                        let rateRes = WebApi.sharedInstance.getDhlRate(self.cart.companyId)
                        
                        if rateRes["id_rate"] == nil {
                            Utility.sharedInstance.showSimpleAlert(title: "Attenzione", message: "Si è verificato un errore, si prega di riprovare", sender: self)
                            return
                        }
                        
                        self.currentDhlRateId = rateRes["id_rate"] as! Int
                        let results = rateRes["results"] as! [String:AnyObject]
                        let totalNet = results["TotalNet"] as! [String:AnyObject]
                        self.currentDhlRateAmount = totalNet["Amount"] as! String
                        self.currentPaypalClientToken = rateRes["payPalClientToken"] as! String
                        
                        DispatchQueue.main.async {
                            
                            self.cart.shippingTotal = Double(self.currentDhlRateAmount)
                            self.shippingAmount.text = Utility.sharedInstance.formatPrice(price: self.cart.shippingTotal)
                            
                            self.finalTotal = self.cart.subTotal+self.cart.shippingTotal
                            self.totalAmount.text = Utility.sharedInstance.formatPrice(price: self.finalTotal)
                            
                            self.buyDhlButton.isEnabled = true
                            self.buyDhlButton.alpha = 1
                            self.buyDhlButton.setTitle("PAGA E RICEVI A CASA "+Utility.sharedInstance.formatPrice(price: self.finalTotal), for: .normal)
                            
                            self.buyRegularButton.isEnabled = true
                            self.buyRegularButton.alpha = 1
                            self.buyRegularButton.setTitle("PAGA E RITIRA IN NEGOZIO "+Utility.sharedInstance.formatPrice(price: self.cart.subTotal), for: .normal)
                            
                        }
                        
                    } else {
                        /*
                        DispatchQueue.main.async {
                            self.shippingAddress.text = "Specifica un indirizzo di spedizione per proseguire con l'acquisto."
                        }
                         */
                        
                        let rateRes = WebApi.sharedInstance.getRegularRate(self.cart.companyId)
                        
                        self.currentPaypalClientToken = rateRes["payPalClientToken"] as! String
                        
                        DispatchQueue.main.async {
                            
                            self.finalTotal = self.cart.subTotal
                            self.totalAmount.text = Utility.sharedInstance.formatPrice(price: self.finalTotal)
                            
                            self.buyRegularButton.isEnabled = true
                            self.buyRegularButton.alpha = 1
                            
                            if !isServiceOrBooking {
                                self.buyRegularButton.setTitle("PAGA E RITIRA IN NEGOZIO "+self.totalAmount.text!, for: .normal)
                            } else {
                                self.buyRegularButton.setTitle("PAGA LA PRENOTAZIONE "+self.totalAmount.text!, for: .normal)
                            }
                            
                        }
                    }
                    
                    
                }
                
            }
            
            
            tableView.reloadData()
        }
        
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeShipping(_ sender: UIButton) {
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = cart.products[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartCell
        
        WebApi.sharedInstance.downloadedFrom(cell.prodImage, link: "https://www.pioalert.com"+product.image, mode: .scaleAspectFit, shadow: false)
        
        cell.prodName.text = product.name
        cell.prodQuantity.text = "Quantità: "+String(product.quantity)
        
        
        let price = Double(product.price)!
        let q = Double(product.quantity)
        let subtotal = (price * q)
        
        cell.prodSubTotal.text =  Utility.sharedInstance.formatPrice(price: subtotal)
        
        cell.modifyButton.tag = indexPath.row
        cell.modifyButton.addTarget(self, action:#selector(handleModify(sender:)), for: .touchUpInside)
        
        return cell
        
    }
    
    
    func handleModify(sender: UIButton) {
        
        let prod = cart.products[sender.tag]
        
        let storyboard = UIStoryboard(name: "Virgi", bundle: nil)
        let modifyAlert = storyboard.instantiateViewController(withIdentifier: "modifyAlert") as! ModifyCartController
        modifyAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modifyAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        modifyAlert.product = prod
        modifyAlert.parentCart = self
        self.present(modifyAlert, animated: true, completion: nil)
        
        
    }

    @IBAction func buyCart(sender: UIButton) {
        
        switch sender.tag {
        case 1:
            if WebApi.sharedInstance.basket2emailPrenotation(comId, message: messageTextField.text!) {
                let alert = UIAlertController(title: "Grazie!", message: "La richiesta è andata a buon fine, verrai ricontattato via e-mail per ulteriori informazioni", preferredStyle: UIAlertControllerStyle.alert)
                //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }))
                //self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Errore...", message: "Si è verificato un errore nella richiesta, si prega di riprovare.", preferredStyle: UIAlertControllerStyle.alert)
                //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        case 2:
            
            self.braintreeClient = BTAPIClient(authorization: currentPaypalClientToken)
            DispatchQueue.main.async {
                self.processPayment(withShipping: true)
            }
            
        case 3:
            
            self.braintreeClient = BTAPIClient(authorization: currentPaypalClientToken)
            DispatchQueue.main.async {
                self.processPayment(withShipping: false)
            }
            
        default:
            break
        }
        
        
        
    }
    
    func processPayment(withShipping: Bool) {
        
        
        
        // Create a BTDropInViewController
        let dropInViewController = BTDropInViewController(apiClient: braintreeClient!)
        dropInViewController.delegate = self
        
        // This is where you might want to customize your view controller (see below)
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally-presented navigation controller:
        
        dropInViewController.view.tintColor = Color.primaryDark
        let paymentRequest = BTPaymentRequest()
        paymentRequest.summaryTitle = "Carrello in "+cart.companyName //selectedProduct.name
        //paymentRequest.summaryDescription = "Spedito in 2/3 giorni lavorativi"
        
        
        let subTot = Double(cart.subTotal)
        
        var ship = 0.0
        var tot = 0.0
        
        if withShipping {
            ship = Double(currentDhlRateAmount)!
            tot = subTot+ship
        } else {
            tot = subTot
        }
        
        
        paymentRequest.displayAmount = Utility.sharedInstance.formatPrice(price: tot)
        paymentRequest.callToActionText = "Paga adesso - "+Utility.sharedInstance.formatPrice(price: tot)
        dropInViewController.paymentRequest = paymentRequest
        
        
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.cancel,
            target: self, action: #selector(CartViewController.userDidCancelPayment))
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        present(navigationController, animated: true, completion: nil)
        
        
        
        
    }
    
    func userDidCancelPayment() {
        dismiss(animated: true, completion: nil)
    }
    
    func drop(_ viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        
        
        print("didSucceedWithTokenization: "+paymentMethodNonce.nonce+" type: "+paymentMethodNonce.type)
        
        viewController.dismiss(animated: true, completion: nil)
        
        //postNonceToServer(paymentMethodNonce.nonce, amount: String(selectedCart.subTotal))
        
        let res = WebApi.sharedInstance.payPalTrans(paymentMethodNonce.nonce, amount: String(finalTotal), rateId: currentDhlRateId, idcom: cart.companyId)
        
        //let dhlResponse = res["dhl_response"] as! Bool
        let globalResponse = res["response"] as! Bool
        
        var title = ""
        var message = ""
        
        if globalResponse {
            title = "Grazie!"
            message = "L'ordine è andato a buon fine, controlla la sezione ordini nel menu dove troverai tutte le informazioni sul tuo ordine."
            //self.orderDone = true
            
        } else {
            title = "Attenzione!"
            message = "Si è verificato un errore, si prega di riprovare"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            
            self.navigationController?.popViewController(animated: true)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func drop(inViewControllerDidCancel viewController: BTDropInViewController) {
        
        print("dropInViewControllerDidCancel...")
        
        
    }

}

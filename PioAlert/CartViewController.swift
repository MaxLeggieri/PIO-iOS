//
//  CartViewController.swift
//  PioAlert
//
//  Created by LiveLife on 26/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var navTitle:UILabel!
    
    @IBOutlet weak var shippingAddress:UILabel!
    @IBOutlet weak var subtotalAmount:UILabel!
    @IBOutlet weak var shippingAmount:UILabel!
    @IBOutlet weak var totalAmount:UILabel!
    @IBOutlet weak var messageTextField:UITextField!
    
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCart()
    }
    
    func closeCart() {
        dismiss(animated: true, completion: nil)
    }
    
    func updateCart() {
        cart = WebApi.sharedInstance.basketShow(comId)
        print("\(cart.products.count) prodotti nel carrello")
        if cart.products.count == 0 {
            perform(#selector(closeCart), with: nil, afterDelay: 0.3)
        } else {
            navTitle.text = cart.companyName
            tableView.reloadData()
            
            
            
            subtotalAmount.text = Utility.sharedInstance.formatPrice(price: cart.subTotal)
            let total = cart.subTotal + cart.shippingTotal
            totalAmount.text = Utility.sharedInstance.formatPrice(price: total)
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
        
        if WebApi.sharedInstance.basket2emailPrenotation(comId, message: messageTextField.text!) {
            let alert = UIAlertController(title: "Grazie!", message: "La prenotazione è andata a buon fine, verrai ricontattato via e-mail per completare la prenotazione", preferredStyle: UIAlertControllerStyle.alert)
            //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Errore...", message: "Si è verificato un errore nella prenotazione, si prega di riprovare.", preferredStyle: UIAlertControllerStyle.alert)
            //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

}

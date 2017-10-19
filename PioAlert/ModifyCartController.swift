//
//  ModifyCartController.swift
//  PioAlert
//
//  Created by LiveLife on 27/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class ModifyCartController: UIViewController {
    
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var quantityLabel:UILabel!
    
    var product:Product!
    var parentCart:CartViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = product.name
        quantityLabel.text = String(product.quantity)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func removeFromCart(sender: UIButton) {
        WebApi.sharedInstance.basketMove(product.pid, quantity: 0)
        parentCart.updateCart()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(sender: UIButton) {
        WebApi.sharedInstance.basketMove(product.pid, quantity: product.quantity)
        parentCart.updateCart()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func modifyQuantity(sender: UIButton) {
        var q = product.quantity!
        
        if sender.tag == 1 {
            // Subtract
            
            if product.quantity > 0 {
                q -= 1
            }
            
            
            
        }
        else if sender.tag == 2 {
            q += 1
            
            if q > product.available {
                q = product.available
            }
            
        }
        
        product.quantity = q
        quantityLabel.text = String(q)
    }
}

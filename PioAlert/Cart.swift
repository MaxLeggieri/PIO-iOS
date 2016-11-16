//
//  Cart.swift
//  PioAlert
//
//  Created by LiveLife on 11/10/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation

class Cart {
    
    var companyId:Int!
    var cartId:Int!
    var companyName:String!
    var shippingAddress:String!
    var products = [Product]()
    var shippingTotal:Double!
    var subTotal:Double!
    
    init(json: [String:AnyObject]) {
        
        print("Cart json: "+json.debugDescription)
        
        cartId = 1
        companyId = json["idcom"]?.integerValue
        companyName = json["brandname"] as! String
        subTotal = json["totPriceSellVatIncluded"]?.doubleValue
        shippingTotal = 0
        
        let gotShippingAddress = NSUserDefaults.standardUserDefaults().boolForKey("gotShippingAddress")
        
        if !gotShippingAddress {
            shippingAddress = "Nessun indirizzo..."
        } else {
            shippingAddress = generateShippingData()
        }
        
        let prods = json["items"] as! [[String:AnyObject]]
        
        for prod in prods {
            
            //print("PRODUCT: "+prod.debugDescription)
            
            let pid = prod["idp"]?.integerValue
            let p = Product(pid: pid!)
            p.name = prod["name"] as! String
            p.price = prod["priceSellVatIncluded"] as! String
            p.quantity = prod["quantity"]?.integerValue
            p.image = prod["imgpath"] as! String
            
            
            
            products.append(p)
            
        }
    }
    
    func generateShippingData() -> String {
        
        let name = NSUserDefaults.standardUserDefaults().stringForKey("shippingName")
        let surname = NSUserDefaults.standardUserDefaults().stringForKey("shippingSurname")
        let address = NSUserDefaults.standardUserDefaults().stringForKey("shippingAddress")
        let postalCode = NSUserDefaults.standardUserDefaults().stringForKey("shippingPostalCode")
        let city = NSUserDefaults.standardUserDefaults().stringForKey("shippingCity")
        let area = NSUserDefaults.standardUserDefaults().stringForKey("shippingArea")
        
        var s = name! + " " + surname! + " - "
        s +=  address! + " - "
        s += postalCode! + " " + city! + " " + area!
        
        return s
        
    }
    
    
}

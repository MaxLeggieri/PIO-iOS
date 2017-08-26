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
    //var cartId:Int!
    var companyName:String!
    var shippingAddress:String!
    var products = [Product]()
    var subTotal:Double!
    var shippingTotal:Double!
    var sellingMethod:Int!
    var companyLogo:String!
    
    init(json: [String:AnyObject]) {
        
        print("Cart json: "+json.debugDescription)
        
        companyId = json["idcom"]?.intValue
        companyName = json["brandname"] as! String
        subTotal = json["totPriceSellVatIncluded"]?.doubleValue
        sellingMethod = json["sellingMethod"]?.intValue
        companyLogo = json["companyLogo"] as! String
        shippingTotal = 0
        
        let prods = json["products"] as! [[String:AnyObject]]
        
        for prod in prods {
            
            //print("PRODUCT: "+prod.debugDescription)
            
            let p = WebApi.sharedInstance.createProductFromJson(prod)
            
            products.append(p)
            
        }
    }
    
    init() {
        companyId = 0
    }
    
}

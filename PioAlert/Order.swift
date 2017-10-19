//
//  Order.swift
//  PioAlert
//
//  Created by LiveLife on 22/12/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation
import UIKit

class Order {
    
    var idOrder:Int!
    var idcom:Int!
    var brandname:String!
    var brandlogo:String!
    
    var subTotal:String!
    var shipping:String!
    var total:String!
    
    var trackingNumber:String!
    var shippingAddress:String!
    
    var shippingIdentification:String!
    var shippingConfirmation:String!
    
    var deliveryTime:Int!
    var cutoffTime:Int!
    var timestamp:Int!
    
    var createdHuman:String!
    var deliveryTimeHuman:String!
    var cutoffTimeHuman:String!
    
    var companyEmail:String!
    var companyModEmail:String!
    
    var products = [Product]()
    
    var totalItems:Int!
    
    init(json: [String:AnyObject]) {
        
        print("Order json: "+json.debugDescription)
        
        idOrder = json["idOrder"]?.intValue
        idcom = json["idcom"]?.intValue
        
        companyEmail = json["companyEmail"] as! String
        companyModEmail = json["companyModEmail"] as! String
        brandname = json["brandname"] as! String
        brandlogo = json["brandlogo"] as! String
        subTotal = json["_price_basketTotalNoShip"] as! String
        shipping = json["_price_basketShip"] as! String
        total = json["_price_basketTotalWithShip"] as! String
        trackingNumber = json["trackingNumber"] as! String
        
        
        
        
        let n = json["first_name"] as! String
        let s = json["last_name"] as! String
        let add = json["address"] as! String
        let t = json["town"] as! String
        let zip = json["zip"] as! String
        let p = json["province"] as! String
        let tel = json["tel"] as! String
        
        shippingAddress = n+" "+s+"\n"+add+"\n"+zip+" "+t+" "+p+"\ntel: "+tel
        shippingIdentification = json["ShipmentIdentificationNumber"] as! String
        shippingConfirmation = json["DispatchConfirmationNumber"] as! String
        
        deliveryTime = json["DeliveryTime"]?.intValue
        cutoffTime = json["CutoffTime"]?.intValue
        timestamp = json["createdTimestamp"]?.intValue
        
        createdHuman = json["createdHuman"] as! String
        deliveryTimeHuman = json["DeliveryTimeHuman"] as! String
        cutoffTimeHuman = json["CutoffTimeHuman"] as! String
        
        
        let prods = json["products"] as! [[String:AnyObject]]
        totalItems = 0
        for prod in prods {
            
            //print("PRODUCT: "+prod.debugDescription)
            
            let p = WebApi.sharedInstance.createProductFromJson(prod) //Product(pid: pid!)
            totalItems = totalItems + p.quantity
            products.append(p)
            
        }
    }
    
}

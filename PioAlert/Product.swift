//
//  Product.swift
//  PioAlert
//
//  Created by LiveLife on 05/09/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation

enum SellingMethod {
    case none
    case paypalDhl
    case emailPrenotation
    case directLink
}

class Product {
    
    
    var pid:Int!
    var idCom:Int!
    var name:String!
    var descShort:String!
    var descLong:String!
    var price:String!
    var initialPrice:String!
    var priceUnit:String!
    var priceOff:String!
    var discountPercent:String!
    var image:String!
    var available:Int!
    var quantity:Int!
    
    var companyName:String!
    var companyAddress:String!
    var companyEmail:String!
    
    var hashtags:String!
    var category:String!
    
    var calendarType: String?
    var workingDays: String?
    var fromTime: String?
    var toTime: String?

    var rating:Double!
    var votes:Int!
    var myRating:Double!
    var freeCategory = Array<AnyObject>()

    
    init(pid: Int) {
        self.pid = pid
        self.calendarType = ""
        self.workingDays = ""
        self.fromTime = ""
        self.toTime = ""
        
        rating = 0
        votes = 0
        myRating = 0
    }
    
    func debugPrint() {
        print("Product")
        print(" pid:        \(pid)")
        print(" idCom:      \(idCom)")
        print(" name:       "+name)
        print(" descShort:  "+descShort)
        print(" descLong:   "+descLong)
        print(" price:      "+price)
        print(" image:      "+image)
        print(" quantity:   \(quantity)")
    }
}

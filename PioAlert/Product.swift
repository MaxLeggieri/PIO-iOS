//
//  Product.swift
//  PioAlert
//
//  Created by LiveLife on 05/09/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation

class Product {
    
    var pid:Int!
    var idCom:Int!
    var name:String!
    var descShort:String!
    var descLong:String!
    var price:String!
    var initialPrice:String!
    var priceUnit:String!
    var discountPercent:String!
    var image:String!
    var quantity:Int!
    
    init(pid: Int) {
        self.pid = pid
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

//
//  Promo.swift
//  MenoPercento
//
//  Created by LiveLife on 22/05/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation
import MapKit

class Promo {
    
    var promoId: Int!
    var brandId: Int!
    var typeId: Int!
    var title: String!
    var desc: String!
    var imagePath: String!
    var prodName: String!
    var prodSpecs: String!
    
    var lat: Double!
    var lon: Double!
    
    var viewedCount:String!
    var brandName:String!
    var address:String!
    var catHuman:String!
    var distanceHuman:String!
    
    var youtube:String!
    var youtubePreview:String!
    var link:String!
    var attachment:String!
    var couponCode:String!
    var usedCoupon:Int!
    var liked:Bool!
    
    var cimage:String!
    var companyAddress:String!
    var companyEmail:String!
    
    var expirationHuman:String!
    var releatedProductId:String!

    init(pid: Int) {
        promoId = pid
        brandId = 0
        typeId = 0
        title = "title"
        desc = "desc"
        imagePath = ""
        cimage = ""
        prodName = ""
        prodSpecs = ""
        
        viewedCount = ""
        brandName = ""
        address = ""
        catHuman = ""
        distanceHuman = ""
        
        youtube = ""
        link = ""
        attachment = ""
        couponCode = ""
        usedCoupon = 0
        
        liked = false
        
        lat = 0.00
        lon = 0.00
        
        releatedProductId = ""
    }
}

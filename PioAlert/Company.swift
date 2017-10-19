//
//  Company.swift
//  PioAlert
//
//  Created by LiveLife on 04/09/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation

class Company {
    
    var cid:Int!
    var officialName:String!
    var brandName:String!
    var phone:String!
    var email:String!
    var image:String!
    var description:String!
    
    var locations = [Location]()
    
    init(cid: Int) {
       self.cid = cid
    }
    
    init(json: [String:AnyObject]) {
        
        cid = json["idcom"]?.intValue
        officialName = json["officialname"] as! String
        brandName = json["brandname"] as! String
        phone = json["phone"] as! String
        email = json["email"] as! String
        image = json["companylogo"] as! String
        description = json["description"] as! String
        
        if let locs = json["loc"] as? [[String:AnyObject]] {
            for loc in locs {
                let l = Location(json: loc)
                locations.append(l)
            }
        }
        
    }
    
}

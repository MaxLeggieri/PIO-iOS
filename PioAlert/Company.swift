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
    var freeCategory = [FreeCategory]()
    var rating:Double!
    var votes:Int!
    var myRating:Double!

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
            let rate = locs[0]["rate"] as! [String:AnyObject]
            rating = rate["rating_avg"] as! Double
            let v = rate["votes"] as! String
            votes = Int(v)
            if  let myRate = locs[0]["myrating"] as? [String:AnyObject] {
                let r = myRate["rating"] as! String
                myRating = Double(r)
            }
            else {
                myRating = 0
            }
            


            
            for loc in locs {
                let l = Location(json: loc)
                locations.append(l)
            }
        }
        
        if let comcats = json["comcat"] as? [[String:AnyObject]] {
            for comcat in comcats {
                let l = FreeCategory(json: comcat)
                freeCategory.append(l)
            }
        }

        
    }
    
}

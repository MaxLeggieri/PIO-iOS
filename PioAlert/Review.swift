//
//  Review.swift
//  PioAlert
//
//  Created by Max L. on 22/10/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import Foundation

class Review {
    
    
    var rid:Int!
    var comment:String!
    var elementId:Int!
    var elementType:String!
    var rating:Double!
    var userName:String!
    var userImage:String!
    
    init(data: [String:AnyObject]) {
        
        let rids = data["id"] as! String
        rid = Int(rids)
        
        let eid = data["element_id"] as! String
        elementId = Int(eid)
        
        let r = data["rating"] as! String
        rating = Double(r)
        
        comment = data["comment"] as! String
        userName = data["user_name"] as! String
        userImage = data["user_image"] as! String
        elementType = data["element_type"] as! String
    }
    
    
}

//
//  Result.swift
//  PioAlert
//
//  Created by LiveLife on 11/11/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation

class Result {
    
    var type:String!
    var id:Int!
    var title:String!
    var image:String!
    var desc:String!
    
    init(json: [String:AnyObject]) {
        
        
        type = json["type"] as! String
        id = json["id"]?.integerValue
        title = json["title"] as! String
        image = json["img"] as! String
        desc = json["desc"] as! String
        
        
    }
    
    
}

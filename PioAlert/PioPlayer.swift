//
//  PioPlayer.swift
//  PioAlert
//
//  Created by LiveLife on 31/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import Foundation

class PioPlayer {
    
    var name:String!
    var imagePath:String!
    var score:String!
    var rank:String!
    var uid:Int!
    
    init(json: [String:AnyObject]) {
        
        name = json["uname"] as! String
        imagePath = json["upic"] as! String
        score = json["score"] as! String
        rank = json["pos"] as! String
        uid = json["uid"]?.intValue
        
    }
    
    
}

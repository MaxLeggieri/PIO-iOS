//
//  Location.swift
//  PioAlert
//
//  Created by LiveLife on 29/12/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation

class Location {
    
    var idLoc:Int!
    var name:String!
    var address:String!
    var lat:Double!
    var lng:Double!
    var distanceHuman:String!
    
    
    init(json: [String:AnyObject]) {
        
        
        idLoc = json["idlocation"]?.intValue
        name = json["name"] as! String
        address = json["address"] as! String
        lat = json["lat"]?.doubleValue
        lng = json["lng"]?.doubleValue
        distanceHuman = json["distance"] as! String
        
        
    }
    
    
}

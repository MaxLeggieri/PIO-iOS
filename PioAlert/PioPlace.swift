//
//  PioPlace.swift
//  PioAlert
//
//  Created by LiveLife on 10/08/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import Foundation

class PioPlace {
    
    var placeId:String!
    var name:String!
    var address:String!
    var lat:Double!
    var lon:Double!
    var icon:String!
    var photoReference:String!
    
    init(json: [String:AnyObject]) {
        
        placeId = json["place_id"] as! String
        name = json["name"] as! String
        address = json["vicinity"] as! String
        
        let location = json["geometry"]?["location"] as! [String:AnyObject]
        
        lat = location["lat"] as! Double
        lon = location["lng"] as! Double
        
        icon = json["icon"] as! String
        
        if let photos = json["photos"] as? [[String:AnyObject]] {
            photoReference = photos[0]["photo_reference"] as! String
        }
        
    }
    
    
}

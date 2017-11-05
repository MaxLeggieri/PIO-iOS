//
//  FreeCategory.swift
//  PioAlert
//
//  Created by Suresh Jagnani on 26/10/17.
//  Copyright © 2017 iApps. All rights reserved.
//

import Foundation

class FreeCategory {
    
    var idcat:String?
    var name:String?
    
    init(json: [String:AnyObject]) {
        
        self.idcat = json["idcat"] as? String
        self.name = json["name"] as? String
        //print(json["id"])
        //print(self.cid)
        
    }
    
    init() {
        self.idcat = ""
        self.name = ""
    }
    
}

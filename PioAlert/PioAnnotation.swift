//
//  PioAnnotation.swift
//  PioAlert
//
//  Created by LiveLife on 20/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import MapKit



class PioAnnotation: MKPointAnnotation {

    enum AnnotationType {
        case user,store,promo,product,poi
    }
    
    var image:UIImage!
    var annType:AnnotationType! = .user
    var annId:String!
    var annPhotoReference:String!
    
    var annImageView:UIImageView!
    
    func setType(_ type: AnnotationType) {
        annType = type
    }
    
}

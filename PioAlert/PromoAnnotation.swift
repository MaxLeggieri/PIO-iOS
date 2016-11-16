//
//  PromoAnnotation.swift
//  PioAlert
//
//  Created by LiveLife on 12/07/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation
import MapKit

class PromoAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var info: String?
    var latitude: Double
    var longitude:Double
    var promo:Promo!
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(promo: Promo) {
        self.promo = promo
        self.title = promo.title
        self.info = promo.desc
        self.subtitle = promo.address
        self.latitude = promo.lat
        self.longitude = promo.lon
    }
}
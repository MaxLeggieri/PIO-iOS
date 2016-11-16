//
//  MapContentController.swift
//  PioAlert
//
//  Created by LiveLife on 04/06/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit
import MapKit

class MapContentController: UIViewController,MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var nameLabel:UILabel!
    
    var promos = [Promo]()
    var name:String!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("promo: \(promos.count)")
        
        for promo in promos {
            let promoAnn = PromoAnnotation(promo: promo)
            mapView.addAnnotation(promoAnn)
        }
        
        nameLabel.text = name+" (\(promos.count) offerte)"
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fitMapViewToAnnotaionList(mapView.annotations)
    }
    
    /*
    func flyToPlace(sender:UIButton!) {
        let promo = WebApi.sharedInstance.allPromo[sender.tag] as Promo!
        
        print("flyToPlace: lat \(promo.lat) lon \(promo.lon)")
        //let userLocation = mapView.userLocation
        let coord = CLLocationCoordinate2D.init(latitude: promo.lat!, longitude: promo.lon!)
        let region = MKCoordinateRegionMakeWithDistance(coord, 150, 150)
        
        mapView.setRegion(region, animated: true)
    }
    */
    
    func fitMapViewToAnnotaionList(annotations: [MKAnnotation]) -> Void {
        let mapEdgePadding = UIEdgeInsets(top: 120, left: 120, bottom: 120, right: 120)
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<annotations.count {
            let annotation = annotations[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

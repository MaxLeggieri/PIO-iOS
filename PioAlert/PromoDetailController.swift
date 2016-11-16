//
//  PromoDetailController.swift
//  PioAlert
//
//  Created by LiveLife on 12/07/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit
import MapKit

class PromoDetailController: UIViewController {

    var selectedPromo:Promo?
    var idAd:Int!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var isFromNotification = false
    var isFromSearch = false
    
    @IBOutlet weak var pimage:UIImageView!
    @IBOutlet weak var cimage:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var productLabel:UILabel!
    @IBOutlet weak var descLabel:UILabel!
    @IBOutlet weak var viewsLabel:UILabel!
    @IBOutlet weak var companyLabel:UILabel!
    @IBOutlet weak var mapView:MKMapView!
    
    @IBOutlet weak var linkButton:UIButton!
    @IBOutlet weak var attachmentButton:UIButton!
    @IBOutlet weak var videoButton:UIButton!
    @IBOutlet weak var couponButton:UIButton!
    @IBOutlet weak var companyButton:UIButton!
    
    @IBOutlet weak var navigationButton:UIButton!
    
    @IBOutlet weak var contentScrollView:UIScrollView!
    
    var location:CLLocation!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkButton.layer.cornerRadius = 5
        attachmentButton.layer.cornerRadius = 5
        videoButton.layer.cornerRadius = 5
        couponButton.layer.cornerRadius = 5
        companyButton.layer.cornerRadius = 5
        navigationButton.layer.cornerRadius = 5
        navigationButton.layer.borderColor = UIColor.whiteColor().CGColor
        navigationButton.layer.borderWidth = 1.4
        
        /*
        mapView.clipsToBounds = false;
        mapView.layer.shadowColor = UIColor.blackColor().CGColor
        mapView.layer.shadowOpacity = 0.6
        mapView.layer.shadowOffset = CGSizeMake(0, -2)
        */
        
        if isFromSearch {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        contentScrollView.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        if selectedPromo == nil {
            selectedPromo = WebApi.sharedInstance.getAdById(String(idAd))
        }
        
        UIView.animateWithDuration(0.15) { 
            self.contentScrollView.alpha = 1
        }
        
        if selectedPromo!.link == "" {
            linkButton.enabled = false
            linkButton.alpha = 0.3
        }
        
        if selectedPromo!.attachment == "" {
            attachmentButton.enabled = false
            attachmentButton.alpha = 0.3
        }
        
        if selectedPromo!.youtube == "" {
            videoButton.enabled = false
            videoButton.alpha = 0.3
        }
        
        if selectedPromo!.couponCode == "" {
            couponButton.enabled = false
            couponButton.alpha = 0.3
        }
        
        if selectedPromo!.usedCoupon != 0 {
            couponButton.enabled = false
            couponButton.alpha = 0.3
        }
        
        pimage.image = UIImage(named: "pioapp_80_x1")
        cimage.image = UIImage(named: "pioapp_80_x1")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PromoDetailController.openCompanyDetail))
        cimage.addGestureRecognizer(tapGesture)
        cimage.userInteractionEnabled = true
        
        WebApi.sharedInstance.downloadedFrom(pimage, link: "http://www.pioalert.com"+selectedPromo!.imagePath, mode: .ScaleAspectFill, shadow: false)
        
        
        print("http://PioAlert.com"+selectedPromo!.cimage)
        WebApi.sharedInstance.downloadedFrom(cimage, link: "http://www.pioalert.com"+selectedPromo!.cimage, mode: .ScaleAspectFill, shadow: true)
        
        cimage.layer.shadowColor = UIColor.blackColor().CGColor
        cimage.layer.shadowOffset = CGSizeMake(1, 1)
        cimage.layer.shadowOpacity = 0.6
        //cimage.layer.borderColor = UIColor.darkGrayColor().CGColor
        //cimage.layer.borderWidth = 1
        
        titleLabel.text = selectedPromo?.title
        productLabel.text = selectedPromo?.prodName
        descLabel.text = selectedPromo?.desc
        viewsLabel.text = "Visto "+(selectedPromo?.viewedCount)!+" volte"
        
        var cstring = "Disponibile da: "
        cstring += selectedPromo!.brandName
        cstring += " (A "
        cstring += selectedPromo!.distanceHuman
        cstring += " da te)"
        
        companyLabel.text = cstring
        self.navigationItem.title = selectedPromo?.catHuman.stringByReplacingOccurrencesOfString("&raquo;", withString: "•")
        
        
        location = CLLocation(latitude: selectedPromo!.lat, longitude: selectedPromo!.lon)
        
        zoomToRegion()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func openCompanyDetail() {
        
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nc = storyboard.instantiateViewControllerWithIdentifier("companyNavigationController") as! UINavigationController
        let vc = nc.topViewController as! CompanyController
        vc.company = WebApi.sharedInstance.getCompanyData(selectedPromo!.brandId)
        self.presentViewController(vc, animated: true, completion: nil)
        */
        
        
        self.performSegueWithIdentifier("showDetailFromCompany", sender: self)
    }

    func zoomToRegion() {
        
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate , 5000.0, 7000.0)
        
        mapView.setRegion(region, animated: true)
        
        let ann = PromoAnnotation(promo: selectedPromo!)
        
        mapView.addAnnotation(ann)
        
        
    }
    
    @IBAction func showExtras(sender: UIButton) {
        
        switch sender.tag {
        case 1:
            // Link
            if let requestUrl = NSURL(string: selectedPromo!.link) {
                UIApplication.sharedApplication().openURL(requestUrl)
            }
            
            break
        case 2:
            // Attachment
            if let requestUrl = NSURL(string: "http://pioalert.com"+selectedPromo!.attachment) {
                UIApplication.sharedApplication().openURL(requestUrl)
            }
            break
        case 3:
            // Video
            if let requestUrl = NSURL(string: selectedPromo!.youtube) {
                UIApplication.sharedApplication().openURL(requestUrl)
            }
            break
        case 4:
            // Coupon
            
            self.performSegueWithIdentifier("showCouponController", sender: self)
            
            
            break
        case 5:
            // Company
            
            //openCompanyDetail()
            
            
            break
        default: break
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCouponController" {
            let vc = segue.destinationViewController as! CouponController
            vc.selectedPromo = selectedPromo
        }
        else if segue.identifier == "showDetailFromCompany" {
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.topViewController as! CompanyController
            
            vc.companyId = selectedPromo?.brandId
            //vc.company = WebApi.sharedInstance.getCompanyData(selectedPromo!.brandId)
        }
        
        
        
    }
    
    @IBAction func openMapForPlace() {
        
        let lat1 : NSString = String(selectedPromo!.lat)
        let lng1 : NSString = String(selectedPromo!.lon)
        
        let latitute:CLLocationDegrees =  lat1.doubleValue
        let longitute:CLLocationDegrees =  lng1.doubleValue
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = selectedPromo!.brandName+" "+selectedPromo!.prodName
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismiss(sender: UIButton) {
        
        if isFromSearch {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true) {
                if self.isFromNotification {
                    self.appDelegate.notificationPointer += 1
                    if self.appDelegate.notificationPointer < self.appDelegate.notificationIDs.count {
                        self.appDelegate.masterViewController?.showNotificationsAds()
                    } else {
                        self.appDelegate.notificationPointer = 0
                        self.appDelegate.notificationIDs = [String]()
                        
                        print("End of Notifications...")
                    }
                }
            }
        }
        
        
    }

}

/*
extension String {
    init(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        let attributedString = NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: AutoreleasingUnsafeMutablePointer<NSDictionary?>)
        
        self.init(attributedString.string)
    }
}
 */

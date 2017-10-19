//
//  PromoViewController.swift
//  PioAlert
//
//  Created by LiveLife on 20/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import MapKit

class PromoViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var scrollContainer:UIView!
    
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var navTitle:UILabel!
    @IBOutlet weak var promoImage:UIImageView!
    @IBOutlet weak var companyImage:UIImageView!
    @IBOutlet weak var companyName:UILabel!
    @IBOutlet weak var promoDistance:UILabel!
    @IBOutlet weak var likeButton:UIButton!
    @IBOutlet weak var promoTitle:UILabel!
    @IBOutlet weak var promoExpire:UILabel!
    @IBOutlet weak var promoDesc:UILabel!
    @IBOutlet weak var promoViewCount:UILabel!
    @IBOutlet weak var linkButton:RoundedButton!
    @IBOutlet weak var attachmentButton:RoundedButton!
    @IBOutlet weak var couponButton:RoundedButton!
    //@IBOutlet weak var videoContainer:UIView!
    @IBOutlet weak var videoImagePreview:UIImageView!
    @IBOutlet weak var youtubeButton:UIImageView!
    @IBOutlet weak var promoMapView:MKMapView!
    @IBOutlet weak var navigateToButton:RoundedButton!
    
    @IBOutlet weak var collectionViewHightConstraint:NSLayoutConstraint!
    @IBOutlet weak var collectionView:UICollectionView?
    var prodContent = [Product]()
    var promo:Promo!
    var imgFolder = "https://www.pioalert.com"

    override func viewDidLoad() {
        super.viewDidLoad()

        print(promo.releatedProductId)
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        scrollView.contentSize = CGSize(width: screenSize.width, height: scrollContainer.bounds.size.height)
        scrollView.frame = view.bounds
        print(scrollContainer.bounds.size.height)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        /*
        
 
        
        */
        self.prodContent = WebApi.sharedInstance.getProductByMultipleId(promo.releatedProductId)

        if prodContent.count == 0 {
            collectionViewHightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        navTitle.text = promo.brandName
        companyName.text = promo.brandName
        promoDistance.text = "a "+promo.distanceHuman+" da te"
        promoTitle.text = promo.title
        promoExpire.text = "Promozione valida fino al "+promo.expirationHuman
        promoDesc.text = promo.desc
        promoViewCount.text = "Visto "+promo.viewedCount+" volte"
        
        if promo.liked {
            likeButton.setImage(UIImage(named: "icon-like-attivo"), for: .normal)
            likeButton.tag = 1
        }
        
        if promo.link == "" {
            linkButton.isHidden = true
        }
        
        if promo.attachment == "" {
            attachmentButton.isHidden = true
        }
        
        if promo.couponCode == "" {
            couponButton.isHidden = true
        }
        
        if promo.youtube == "" {
            //videoContainer.removeFromSuperview()
            youtubeButton.removeFromSuperview()
            videoImagePreview.removeFromSuperview()
            
            let mapTopSpace = NSLayoutConstraint(item: promoMapView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: collectionView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 32)
            
            mapTopSpace.isActive = true
            
        } else {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            youtubeButton.isUserInteractionEnabled = true
            youtubeButton.addGestureRecognizer(tapGestureRecognizer)
        }
        
        
        
        
        
        promoMapView.delegate = self
        let ann = MKPointAnnotation()
        ann.coordinate = CLLocationCoordinate2D(latitude: promo.lat, longitude: promo.lon)
        ann.title = promo.brandName+" - "+promo.title
        ann.subtitle = promo.address
        promoMapView.addAnnotation(ann)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        companyImage.isUserInteractionEnabled = true
        companyImage.addGestureRecognizer(tapGestureRecognizer2)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        WebApi.sharedInstance.downloadedFrom(promoImage, link: imgFolder+promo.imagePath, mode: .scaleAspectFit, shadow: false)
        
        WebApi.sharedInstance.downloadedFrom(companyImage, link: imgFolder+promo.cimage, mode: .scaleAspectFit, shadow: true)
        
        if promo.youtube != "" {
            WebApi.sharedInstance.downloadedFrom(videoImagePreview, link: promo.youtubePreview, mode: .scaleAspectFit, shadow: true)
        }
        

        zoomToRegion()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissPromo(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func likeAd(_ sender: UIButton) {
        
        
        if sender.tag == 1 {
            sender.tag = 0
            sender.setImage(UIImage(named: "icon-like"), for: .normal)
            let q = DispatchQueue.global(qos: .background)
            q.async {
                WebApi.sharedInstance.likeAd(false, idad: self.promo.promoId)
            }
            
        } else {
            sender.tag = 1
            sender.setImage(UIImage(named: "icon-like-attivo"), for: .normal)
            let q = DispatchQueue.global(qos: .background)
            q.async {
                WebApi.sharedInstance.likeAd(true, idad: self.promo.promoId)
            }
        }
        
    }
    
    @IBAction func shareAd(_ sender: UIButton) {
        let textToShare = promo.title
        
        let urlString = "https://www.pioalert.com/sharead/?idad="+String(promo.promoId)+"&uid="+String(WebApi.sharedInstance.uid)
        
        if let myWebsite = URL(string: urlString) {
            let objectsToShare = [textToShare ?? "Guarda questa promo su PIO", myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        print("tappedImage tag: \(tappedImage.tag)")
        
        if tappedImage.tag == 1 {
            self.performSegue(withIdentifier: "showCompanyFromPromo", sender: self)
        } else {
            // Video
            if let requestUrl = URL(string: promo!.youtube) {
                UIApplication.shared.openURL(requestUrl)
            }
        }
        
        
    }
    
    @IBAction func showExtras(_ sender: AnyObject) {
        
        switch sender.tag {
        case 1:
            // Link
            if let requestUrl = URL(string: promo!.link) {
                UIApplication.shared.openURL(requestUrl)
            }
            
            break
        case 2:
            // Attachment
            if let requestUrl = URL(string: "http://pioalert.com"+promo!.attachment) {
                UIApplication.shared.openURL(requestUrl)
            }
            break
        case 3:
            
            // Coupon
            
            self.performSegue(withIdentifier: "showCouponScanner", sender: self)
            
            
            break
        case 4:
            
            // Video
            if let requestUrl = URL(string: promo!.youtube) {
                UIApplication.shared.openURL(requestUrl)
            }
            
            break
        case 5:
            // Company
            
            //openCompanyDetail()
            
            
            break
        default: break
            
        }
        
    }
    
    @IBAction func navigateToPromo() {
        
        let coordinates = CLLocationCoordinate2D(latitude: promo.lat, longitude: promo.lon)
        
        let regionDistance:CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = promo.brandName+" "+promo.prodName
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var av = mapView.dequeueReusableAnnotationView(withIdentifier: "promoAnnotation")
        if av == nil {
            av = MKAnnotationView(annotation: annotation, reuseIdentifier: "promoAnnotation")
            av?.image = UIImage(named: "icon-geolocal")
            av?.canShowCallout = true
        }
        
        return av
    }
    
    func zoomToRegion() {
        
        let location = CLLocationCoordinate2D(latitude: promo.lat, longitude: promo.lon)
        let region = MKCoordinateRegionMakeWithDistance(location , 1000, 1000)
        
        promoMapView.setRegion(region, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCouponScanner" {
            let vc = segue.destination as! CouponController
            vc.selectedPromo = promo
            vc.presenting = self
        }
        else if segue.identifier == "showCompanyFromPromo" {
            let vc = segue.destination as! ShopViewController
            vc.company = WebApi.sharedInstance.getCompanyData(String(promo.brandId))
        }
    }
    
    //MARK: Collection View Delegate and DataSource
    //MARK: - Collection View Delegate
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return prodContent.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromoCollectionCell", for: indexPath) as! PromoCollectionCell
        
        let product = prodContent[indexPath.row] as Product

        if cell.imageView.image == nil { WebApi.sharedInstance.downloadedFrom(cell.imageView, link: imgFolder+product.image, mode: .scaleAspectFit, shadow: false)
        }

        let titleText = product.name
        cell.titleLabel.text = titleText
        cell.subtitleLabel.text = product.price
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10.0
    }
    
    


}

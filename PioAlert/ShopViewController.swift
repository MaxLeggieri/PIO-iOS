//
//  ShopViewController.swift
//  PioAlert
//
//  Created by LiveLife on 29/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

class ShopViewController: UIViewController, MFMailComposeViewControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var navTitle:UILabel!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var comImage:UIImageView!
    @IBOutlet weak var comName:UILabel!
    @IBOutlet weak var comDistance:UILabel!
    @IBOutlet weak var comDesc:UILabel!
    @IBOutlet weak var comPhone:UIButton!
    @IBOutlet weak var comAddress:UIButton!
    @IBOutlet weak var productsLabel:UILabel!
    @IBOutlet weak var promoLabel:UILabel!
    
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var scrollContainer:UIView!
    
    @IBOutlet weak var productCollectionView:UICollectionView!
    @IBOutlet weak var promoCollectionView:UICollectionView!
    
    @IBOutlet weak var productContainer:UIView!
    @IBOutlet weak var promoContainer:UIView!
    
    var company:Company!
    
    var prodResults = [Product]()
    var promoResults = [Promo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        scrollView.contentSize = CGSize(width: screenSize.width, height: scrollContainer.bounds.size.height)
        scrollView.frame = view.bounds

        navTitle.text = company.brandName
        
        comName.text = company.brandName
        comDistance.text = "A "+company.locations[0].distanceHuman+" da te"
        comDesc.text = company.description
        comPhone.setTitle(company.phone, for: .normal)
        //comAddress.setTitle(company.locations[0].address, for: .normal)
        
        mapView.delegate = self
        let ann = MKPointAnnotation()
        ann.coordinate = CLLocationCoordinate2D(latitude: company.locations[0].lat, longitude: company.locations[0].lng)
        ann.title = company.brandName
        ann.subtitle = company.locations[0].address
        mapView.addAnnotation(ann)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WebApi.sharedInstance.downloadedFrom(comImage, link: "https://www.pioalert.com"+company.image, mode: .scaleAspectFit, shadow: true)
        
        
    }
    
    
    @IBOutlet var productHeighConstrait:NSLayoutConstraint!
    @IBOutlet var promoHeighConstrait:NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        zoomToRegion()
        
        
        prodResults = WebApi.sharedInstance.getCompanyProducts(company.cid)
        print("Products: \(prodResults.count)")
        
        if prodResults.count == 0 {
            productsLabel.text = ""
            if productCollectionView != nil {
                print("removed productCollectionView...")
                productCollectionView.removeFromSuperview()
                
                productHeighConstrait.constant = 0
                productContainer.updateConstraints()
                
            }
        } else {
            productsLabel.text = "Prodotti ("+String(prodResults.count)+")"
            productCollectionView.reloadData()
            
        }
        
        promoResults = WebApi.sharedInstance.getCompanyAds(company.cid)
        print("Promo: \(promoResults.count)")
        
        
        if promoResults.count == 0 {
            promoLabel.text = ""
            
            if promoCollectionView != nil {
                print("removed promoCollectionView...")
                promoCollectionView.removeFromSuperview()
                
                promoHeighConstrait.constant = 0
                promoContainer.updateConstraints()
                
            }
        } else {
            promoLabel.text = "Promo ("+String(promoResults.count)+")"
            promoCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismissShop(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callShop(sender: UIButton) {
        let clean = company.phone.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        if let url = URL(string: "tel://"+clean), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func navigateShop(sender: UIButton) {
        let coordinates = CLLocationCoordinate2D(latitude: company.locations[0].lat, longitude: company.locations[0].lng)
        
        let regionDistance:CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = company.brandName
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func askInfoShop(sender: UIButton) {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        var rec = [String]()
        rec.append("feedback@pioalert.com")
        if company.email != "accountemail@fakeaccountemail.it" {
            rec.append(company.email)
        }
        mailVC.setToRecipients(rec)
        mailVC.setSubject("Richiesta informazioni su: "+company.brandName)
        
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
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
        
        let location = CLLocationCoordinate2D(latitude: company.locations[0].lat, longitude: company.locations[0].lng)
        let region = MKCoordinateRegionMakeWithDistance(location , 1000, 1000)
        
        mapView.setRegion(region, animated: false)
    }
    
    var selectedProduct:Product!
    func showProduct() {
        self.performSegue(withIdentifier: "showProductFromCompany", sender: self)
    }
    
    var selectedPromo:Promo!
    func showPromo() {
        self.performSegue(withIdentifier: "showPromoFromCompany", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductFromCompany" {
            let vc = segue.destination as! ProductViewController
            vc.product = selectedProduct
        }
        else if segue.identifier == "showPromoFromCompany" {
            let vc = segue.destination as! PromoViewController
            vc.promo = selectedPromo
        }
        
    }
}

extension ShopViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return prodResults.count
        } else {
            return promoResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            let r = prodResults[indexPath.row]
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCollectionViewCell", for: indexPath) as! CompanyCollectionViewCell
        
            cell.titleLabel.text = r.name
            cell.priceLabel.text = "€ "+r.price
            let opt = "http://pioalert.com/imgDelivery/?i="+r.image!+"&w=260"
            WebApi.sharedInstance.downloadedFrom(cell.imageView, link: opt, mode: .scaleAspectFill, shadow: true)
        
            return cell
        } else {
            let r = promoResults[indexPath.row]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCollectionViewCell", for: indexPath) as! CompanyCollectionViewCell
            
            cell.titleLabel.text = r.title
            cell.priceLabel.text = r.distanceHuman
            let opt = "http://pioalert.com/imgDelivery/?i="+r.imagePath!+"&w=462"
            WebApi.sharedInstance.downloadedFrom(cell.imageView, link: opt, mode: .scaleAspectFill, shadow: true)
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 1 {
            selectedProduct = prodResults[indexPath.row]
            showProduct()
        } else {
            selectedPromo = promoResults[indexPath.row]
            showPromo()
        }
    }
    
}

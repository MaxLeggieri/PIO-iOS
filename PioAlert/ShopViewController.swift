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
import Cosmos

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
    @IBOutlet weak var categoryCollectionView:UICollectionView!

    @IBOutlet weak var categoryCollectionViewHeightConstraint:NSLayoutConstraint!

    @IBOutlet weak var productContainer:UIView!
    @IBOutlet weak var promoContainer:UIView!
    
    @IBOutlet var cosmosView:CosmosView!

    var selectedIndex : Int = 0
    var company:Company!
    
    var prodResults = [Product]()
    var filterProdResults = [Product]()
    var promoResults = [Promo]()
    var filter : Bool = false 
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
        
        print(company.freeCategory)
        mapView.delegate = self
        let ann = MKPointAnnotation()
        ann.coordinate = CLLocationCoordinate2D(latitude: company.locations[0].lat, longitude: company.locations[0].lng)
        ann.title = company.brandName
        ann.subtitle = company.locations[0].address
        
        mapView.addAnnotation(ann)
        
        if company.freeCategory.count == 0 {
            categoryCollectionViewHeightConstraint.constant = 0
        }
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (showReviews))
        cosmosView.addGestureRecognizer(gesture)
        
        cosmosView.rating = company.rating
        if company.votes == 0 {
            cosmosView.text = "NESSUNA RECENSIONE"
        } else {
            cosmosView.text = "("+String(company.votes)+") VEDI LE RECENSIONI"
        }

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
    
    @IBAction func writeReview(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showAddReview", sender: self)
    }

    func showReviews(sender:UITapGestureRecognizer){
        // do other task
        
        //        if promo.votes != 0 {
        //            self.performSegue(withIdentifier: "showReviews", sender: self)
        //        }
    }

    
    func categoryButtonAction(_ sender: UIButton) {
        selectedIndex = sender.tag

        if selectedIndex == 0 {
            filter = false
            productCollectionView.reloadData()
            categoryCollectionView.reloadData()
        }
        else {
            if selectedIndex > 0 {
                let r = company.freeCategory[selectedIndex - 1]
                filterProdResults = findCategoryContaining(word: r.name!)
                if (filterProdResults.count > 0) {
                    filter = true
                    productCollectionView.reloadData()
                }
            }
            categoryCollectionView.reloadData()
        }
        
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

        else if segue.identifier == "showAddReview" {
            let vc = segue.destination as! AddReviewController;
            vc.company = company
            vc.reviewType = .companyReview
        }
        
        else if segue.identifier == "showReviews" {
            let vc = segue.destination as! ReviewController;
            vc.company = company
            vc.getReviewType = .companyReview

        }
        
    }
    
    func findCategoryContaining(word: String) -> [Product] {
        var newProd = [Product]()

        for prod  in prodResults {
            for item in prod.freeCategory
            {
                if (item.contains(word))
                {
                    newProd.append(prod)
                    break
                }
            }
        }
        return newProd
    }
}

extension ShopViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return filter == true ? filterProdResults.count : prodResults.count
        }
        else if collectionView.tag == 3 {
            if company.freeCategory.count > 0 {
                return company.freeCategory.count + 1
            }
            else {
                return 0
            }
        }
        else {
            return promoResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            let r = filter == true ? filterProdResults[indexPath.row] :  prodResults[indexPath.row]
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCollectionViewCell", for: indexPath) as! CompanyCollectionViewCell
        
            cell.titleLabel.text = r.name
            cell.priceLabel.text = "€ "+r.price
            let opt = "http://pioalert.com/imgDelivery/?i="+r.image!+"&w=260"
            WebApi.sharedInstance.downloadedFrom(cell.imageView, link: opt, mode: .scaleToFill, shadow: true)
        
            return cell
        }
        else if collectionView.tag == 3 {
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FreeCategoryCell", for: indexPath) as! FreeCategoryCell
            
            cell.categoryButton.tag = indexPath.row
            cell.categoryButton.isSelected = false
            cell.categoryButton.buttonBackgroundColor = UIColor.darkSkyBlue
            cell.categoryButton.setBorder(false, color: UIColor.black)
            cell.categoryButton.setTitle("", for: .normal)
            cell.categoryButton.hasBorder = false
            cell.categoryTitle.textColor =  UIColor.white
            if cell.categoryButton.tag == selectedIndex {
                cell.categoryButton.isSelected = true
                cell.categoryButton.buttonBackgroundColor = UIColor.white
                cell.categoryButton.setBorder(true, color: UIColor.black)
                cell.categoryTitle.textColor =  UIColor.darkSkyBlue
            }
            cell.categoryButton.addTarget(self, action: #selector(categoryButtonAction(_:)), for: .touchUpInside)
            if indexPath.row == 0 {
                cell.categoryTitle.text = "tutti"
            }
            else {
                let r = company.freeCategory[indexPath.row - 1]
                cell.categoryTitle.text = r.name
            }
            return cell

        }
        else {
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
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 3 {
            
            var textString = "tutti"
            if indexPath.row > 0 {
                let r = company.freeCategory[indexPath.row - 1]
                textString = r.name!
            }

            _ = 30
            // x is the width of the logo in the left
            
            let size = CGSize(width: 1000, height: 30)
            
            //1000 is the large arbitrary values which should be taken in case of very high amount of content
            
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
            let estimatedFrame = NSString(string: textString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            return CGSize(width: estimatedFrame.width + 35, height: 30)


        }
        else if collectionView.tag == 1{

            return CGSize(width:130,height:184)
        }
        else {
            return CGSize(width:231,height:184)
        }
        
    }
    
}

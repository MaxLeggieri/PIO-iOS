//
//  HomeController.swift
//  PioAlert
//
//  Created by LiveLife on 18/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//9898411358,9712132558

import Foundation
import UIKit
import MapKit
import FBSDKCoreKit
import GoogleSignIn
//import GooglePlaces

class HomeController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, PioLocationManagerDelegate, UISearchBarDelegate, NotificationDelegate {

    @IBOutlet weak var promoTableView:UITableView!
    @IBOutlet weak var exploreMapView:MKMapView!
    @IBOutlet weak var topBarView:UIView!
    //@IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var searchBarContainer:UIView!
    
    var locationManager:CLLocationManager!
    var searchController:UISearchController? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func notificationReceived(ids: [String]) {
        
        print("notificationReceived...")
        
        self.tabBarController?.tabBar.items?.last?.badgeValue = String(ids.count)
        
        guard
            let aps = appDelegate.notificationData?[AnyHashable("aps")] as? NSDictionary,
            let alert = aps["alert"] as? NSDictionary,
            let body = alert["body"] as? String,
            let title = alert["title"] as? String
            else {
                // handle any error here
                return
        }
        
        
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let actionShow = UIAlertAction(title: "Mostra", style: .default, handler: {(alert: UIAlertAction!) in
            
            self.appDelegate.gotNotification = false
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            self.tabBarController?.selectedIndex = 4
            
        })
        let actionIgnore = UIAlertAction(title: "Ignora", style: .cancel, handler: nil)
        alertController.addAction(actionShow)
        alertController.addAction(actionIgnore)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    var menuIsVisible = false
    var mainMenuController:MainMenuController!
    var menuWidth:CGFloat!
    @IBAction func togglePioMenu() {
        
        
        
        if !menuIsVisible {
            self.mainMenuController.view.isHidden = true
            
            print("Name: "+PioUser.sharedUser.userName)
            print("Image: "+PioUser.sharedUser.userImagePath)
            
            WebApi.sharedInstance.downloadedFrom(mainMenuController.userImage, link: PioUser.sharedUser.userImagePath, mode: .scaleAspectFit, shadow: false)
            self.mainMenuController.userWelcomeLabel.text = "Ciao "+PioUser.sharedUser.userName
            
            
            
            let score = PioUser.sharedUser.rankData["score"] as? String
            print("Score: "+score!)
            self.mainMenuController.userPointsLabel.text = score!+" pts"
            
            self.tabBarController?.view.addSubview(self.mainMenuController.view)
            var frame = self.mainMenuController.view.frame
            frame.origin.x -= frame.size.width
            frame.size.width = menuWidth
            self.mainMenuController.view.frame = frame
            UIView.animate(withDuration: 0.3, animations: {
                self.mainMenuController.view.isHidden = false
                frame.origin.x=0
                self.mainMenuController.view.frame = frame
            })
            
            
            
        } else {
            
            var frame = self.mainMenuController.view.frame
            UIView.animate(withDuration: 0.2, animations: {
                frame.origin.x = -self.menuWidth
                self.mainMenuController.view.frame = frame
            }, completion: { (done) in
                if done {
                    self.mainMenuController.view.isHidden = true
                }
            })
            
            
        }
        menuIsVisible = !menuIsVisible
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utility.sharedInstance.homeController = self
        
        if mainMenuController == nil {
            let storyboard = UIStoryboard(name: "Virgi", bundle: nil)
            mainMenuController = storyboard.instantiateViewController(withIdentifier: "MainMenu") as! MainMenuController
            
            menuWidth = mainMenuController.view.frame.size.width-80
            mainMenuController.homeController = self
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            mainMenuController.view.addGestureRecognizer(swipeLeft)
        }
        
        
        
        appDelegate.notificationDelegate = self
        
        let searchResultController = storyboard?.instantiateViewController(withIdentifier: "SearchResultController") as! SearchResultController
        searchResultController.homeController = self
        
        searchController = UISearchController(searchResultsController: searchResultController)
        
        searchController?.searchResultsUpdater = searchResultController
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Cerca su PIO"
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.searchBar.backgroundColor = UIColor(colorLiteralRed: 0.965, green:0.788, blue:0.255, alpha:1.00)
        searchController?.searchBar.delegate = self
        
        let textFieldInsideSearchBar = searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        textFieldInsideSearchBar?.font = UIFont(name: "Lato-medium", size: 16)
        
        searchBarContainer.addSubview((searchController?.searchBar)!)
        definesPresentationContext = false
        
        
        topBarView.layer.shadowColor = UIColor.black.cgColor
        topBarView.layer.shadowOpacity = 0.4
        topBarView.layer.shadowRadius = 5
        topBarView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        promoTableView.delegate = self
        exploreMapView.delegate = self
        
        if Reachability.isConnectedToNetwork(){
            if UserDefaults.standard.string(forKey: "deviceToken") == nil {
                let dt = UIDevice.current.identifierForVendor?.uuidString
                UserDefaults.standard.setValue(dt, forKey: "deviceToken")
                UserDefaults.standard.synchronize()
                WebApi.sharedInstance.deviceToken = dt!
            } else {
                WebApi.sharedInstance.deviceToken = UserDefaults.standard.string(forKey: "deviceToken")!
                print("Device token: "+WebApi.sharedInstance.deviceToken);
            }
            
            
            if WebApi.sharedInstance.uid == 0 {
                WebApi.sharedInstance.uid = UserDefaults.standard.integer(forKey: "uid")
            }
            
            PioUser.sharedUser.updateUser()
 
        }
        else {
            let alert = UIAlertController(title: "Please check your internet connection", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }

        
        
        
        //promoTableView.rowHeight = UITableViewAutomaticDimension
        //promoTableView.estimatedRowHeight = 70
        
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                togglePioMenu()
            default:
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkUserStatus()
    }
    
    func checkUserStatus() {
        
        if !PioUser.sharedUser.logged {
            print("user not logged...")
            self.performSegue(withIdentifier: "showLogin", sender: self)
        }
        else if !PioUser.sharedUser.profiled {
            print("user not localized...")
            self.performSegue(withIdentifier: "showProfile", sender: self)
        }
        else if !PioUser.sharedUser.consent {
            print("user no consent...")
            self.performSegue(withIdentifier: "showConsent", sender: self)
        }
        else {
            
            print("startTrackingUser...");
            PioLocationManager.sharedManager.delegate = self
            PioLocationManager.sharedManager.startTrackingUser()
            
            appDelegate.registerForNotifications()
            _ = WebApi.sharedInstance.ranking(limit: 1)
            
            
        }
        
        
    }
    
    func searchGooglePlaces() {
        let placesResults = WebApi.sharedInstance.getGooglePlaces()
        print("G places num res: \(placesResults.count)")
        
        for p in placesResults {
            //print("name: "+p.name+" address: "+p.address+" pid: "+p.placeId+" lat: \(p.lat) lon: \(p.lon)")
            
            
            let ann = PioAnnotation()
            ann.coordinate = CLLocationCoordinate2D(latitude: p.lat, longitude: p.lon)
            ann.annId = p.placeId
            ann.title = p.name
            ann.subtitle = p.address
            ann.setType(.poi)
            ann.annPhotoReference = p.photoReference
            let cImage = UIImageView(frame: CGRect(x: 4, y: 4, width: 32, height: 32))
            cImage.layer.cornerRadius = cImage.frame.size.width/2
            WebApi.sharedInstance.downloadedFrom(cImage, link: p.icon, mode: .scaleAspectFit, shadow: false)
            
            ann.annImageView = cImage
            
            exploreMapView.addAnnotation(ann)
            
        }
    }
    
    
    @IBAction func zoomToUserPosition(sender: UIButton) {
        
        zoomToUser()
        
    }
    
    var mapResults = [[String:AnyObject]]()
    var com1Results = [String:AnyObject]()
    var com1ProdResults = [[String:AnyObject]]()
    
    var com2Results = [String:AnyObject]()
    var com2ProdResults = [[String:AnyObject]]()
    
    var currentSearchText:String!
    var currentSearchCat = "0"
    func searchTerm(text: String, idcat: String) {
        
        
        
        currentSearchText = text
        currentSearchCat = idcat
        
        searchController?.searchBar.text = text
        print("Searching for: "+text)
        
        
        DispatchQueue.global(qos: .default).async {
            if self.currentSearchText == "" {
                let home = WebApi.sharedInstance.home(1, searchTerm: nil, idcat: idcat)
                DispatchQueue.main.async {
                    self.updateMapAndResults(home,zoomToAnnotation: true)
                }
                
            } else {
                let home = WebApi.sharedInstance.home(1, searchTerm: text, idcat: idcat)
                DispatchQueue.main.async {
                    self.updateMapAndResults(home,zoomToAnnotation: true)
                }
            }
        }
        
    }
    
    var isRotating = false
    var shouldStopRotating = false
    var timer: Timer!
    @IBOutlet weak var refreshButton:UIButton!
    @IBAction func refreshSearch(sender: UIButton) {
        
        if self.isRotating == false {
            self.refreshButton.rotate360Degrees(completionDelegate: self)
            // Perhaps start a process which will refresh the UI...
            
            /*
            self.timer = Timer(duration: 5.0, completionHandler: {
                self.shouldStopRotating = true
            })
            */
            
            if #available(iOS 10.0, *) {
                timer = Timer(timeInterval: 5.0, repeats: false, block: { (timer) in
                    self.shouldStopRotating = true
                })
                self.timer.fire()
                self.isRotating = true
            } else {
                // Fallback on earlier versions
            }
            
            if currentSearchText == nil {
                currentSearchText = ""
            }
            searchTerm(text: currentSearchText, idcat: currentSearchCat)
        }
        
        
        
    }
    
    func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.refreshButton.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.isRotating = false
        self.shouldStopRotating = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        currentSearchText = ""
        currentSearchCat = "0"
        searchTerm(text: "", idcat: "0")
    }
    
    func startHome() {
        
        print("startHome...")
        
        
        let home = WebApi.sharedInstance.home(1,searchTerm: nil, idcat: "0")
        updateMapAndResults(home,zoomToAnnotation: false)
        
    }
    
    func updateMapAndResults(_ home: [String:AnyObject], zoomToAnnotation: Bool) {
        
        exploreMapView.removeAnnotations(exploreMapView.annotations)
        
        mapResults = home["map"] as! [[String:AnyObject]]
        
        com1Results = home["com1"] as! [String:AnyObject]
        com1ProdResults = home["com1prd"] as! [[String:AnyObject]]
        
        
        
        if let c2 = home["com2"] as? [String:AnyObject] {
            com2Results = c2
        }
        
        if let p2 = home["com2prd"] as? [[String:AnyObject]] {
            com2ProdResults = p2
        }
        
        var count = 0
        for r in mapResults {
            
            count+=1
            if count == 30 {
                break
            }
            
            let coord = r["LL"] as! String
            let cArr = coord.components(separatedBy: ",")
            
            let type = r["type"] as! String
            
            let lat = cArr[0]
            let lon = cArr[1]
            let locCoord = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
            
            
            let ann = PioAnnotation()
            ann.annId = r["id"] as? String
            
            if type == "ad" {
                let imgPath = r["brandimg"] as? String
                let opt = "http://pioalert.com/imgDelivery/?i="+imgPath!+"&w=78"
                let cImage = UIImageView(frame: CGRect(x: 4, y: 4, width: 32, height: 32))
                cImage.layer.cornerRadius = cImage.frame.size.width/2
                WebApi.sharedInstance.downloadedFrom(cImage, link: opt, mode: .scaleAspectFit, shadow: false)
                
                ann.annImageView = cImage
                ann.coordinate = locCoord
                
                
                ann.setType(.promo)
                ann.title = r["title"] as? String
                ann.subtitle = (r["brand"] as! String) + " - " + (r["subtitle"] as! String)
            }
            else if type == "prd" {
                let imgPath = r["img"] as? String
                let opt = "http://pioalert.com/imgDelivery/?i="+imgPath!+"&w=78"
                let cImage = UIImageView(frame: CGRect(x: 4, y: 4, width: 32, height: 32))
                cImage.layer.cornerRadius = cImage.frame.size.width/2
                WebApi.sharedInstance.downloadedFrom(cImage, link: opt, mode: .scaleAspectFit, shadow: false)
                
                ann.annImageView = cImage
                ann.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                
                
                ann.setType(.product)
                ann.title = r["title"] as? String
                ann.subtitle = r["subititle"] as? String
            }
            else {
                let imgPath = r["img"] as? String
                let opt = "http://pioalert.com/imgDelivery/?i="+imgPath!+"&w=78"
                let cImage = UIImageView(frame: CGRect(x: 4, y: 4, width: 32, height: 32))
                cImage.layer.cornerRadius = cImage.frame.size.width/2
                WebApi.sharedInstance.downloadedFrom(cImage, link: opt, mode: .scaleAspectFit, shadow: false)
                
                ann.annImageView = cImage
                ann.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                
                
                ann.setType(.store)
                ann.title = r["title"] as? String
                ann.subtitle = r["address"] as? String
            }
            
            exploreMapView.addAnnotation(ann)
            
            /*
            let up = MKPointAnnotation()
            up.coordinate = ann.coordinate
            exploreMapView.addAnnotation(up)
            */
        }
        
        let ann = PioAnnotation()
        ann.coordinate = PioUser.sharedUser.location.coordinate
        ann.title = "Sei qui"
        ann.annType = PioAnnotation.AnnotationType.user
        exploreMapView.addAnnotation(ann)
        
        /*
        let up = MKPointAnnotation()
        up.coordinate = PioUser.sharedUser.location.coordinate
        exploreMapView.addAnnotation(up)
        */
        
        if zoomToAnnotation {
            zoomToAnnotations()
        } else {
            zoomToUser()
        }
        promoTableView.reloadData()
        isRotating = false
        
        self.perform(#selector(searchGooglePlaces), with: nil, afterDelay: 1)
    }
    
    func zoomToUser() {
        let span = MKCoordinateSpanMake(0.003, 0.003)
        let region = MKCoordinateRegion(center: PioUser.sharedUser.location.coordinate, span: span)
        exploreMapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //print(mapView.region.span.latitudeDelta.description+"   "+mapView.region.span.longitudeDelta.description)
    }
    
    func isInRegion (_ region : MKCoordinateRegion, coordinate : CLLocationCoordinate2D) -> Bool {
        
        let center   = region.center;
        let northWestCorner = CLLocationCoordinate2D(latitude: center.latitude  - (region.span.latitudeDelta  / 2.0), longitude: center.longitude - (region.span.longitudeDelta / 2.0))
        let southEastCorner = CLLocationCoordinate2D(latitude: center.latitude  + (region.span.latitudeDelta  / 2.0), longitude: center.longitude + (region.span.longitudeDelta / 2.0))
        
        return (
            coordinate.latitude  >= northWestCorner.latitude &&
                coordinate.latitude  <= southEastCorner.latitude &&
                
                coordinate.longitude >= northWestCorner.longitude &&
                coordinate.longitude <= southEastCorner.longitude
        )
    }
    
    func zoomToAnnotations() {
        
        var zoomRect = MKMapRectNull
        
        for ann in exploreMapView.annotations {
            let annotationPoint = MKMapPointForCoordinate(ann.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = pointRect;
            } else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
        }
        
        exploreMapView.setVisibleMapRect(zoomRect, animated: true)
        
    }
    
    func zoomToRegion() {
        
        let region = MKCoordinateRegionMakeWithDistance(PioUser.sharedUser.location.coordinate , 1000.0, 1000.0)
        
        exploreMapView.setRegion(region, animated: true)
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if !(annotation is PioAnnotation) {
            return nil
        }
        
        let pa = annotation as! PioAnnotation
        
        var reuseId = ""
        
        if pa.annType == PioAnnotation.AnnotationType.user {
            reuseId = "userAnn"
        }
        else if pa.annType == PioAnnotation.AnnotationType.poi {
            reuseId = "poiAnn"
        }
        else {
            reuseId = "defAnn"
        }
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: pa, reuseIdentifier: reuseId)
        }
        else {
            anView!.annotation = pa
        }
        
        if pa.annType == PioAnnotation.AnnotationType.user {
            anView!.image = UIImage(named:"You")
            anView?.centerOffset = CGPoint(x: 0, y: 0)
            anView!.canShowCallout = false
        }
        else  {
            anView?.image = UIImage(named: "icon-geolocal-bg")
            let h = (anView?.image?.size.height)! / 2
            anView?.centerOffset = CGPoint(x: 0, y: -h)
            anView!.canShowCallout = true
            
            let rightButton = UIButton(type: .custom)
            rightButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            
            if pa.annType == PioAnnotation.AnnotationType.store {
                rightButton.setImage(UIImage(named: "menu-negozi-60"), for: .normal)
            }
            else if pa.annType == PioAnnotation.AnnotationType.promo {
                rightButton.setImage(UIImage(named: "menu-promo-60"), for: .normal)
            }
            else if pa.annType == PioAnnotation.AnnotationType.product {
                rightButton.setImage(UIImage(named: "menu-vetrina-60"), for: .normal)
            }
            else if pa.annType == PioAnnotation.AnnotationType.poi {
                rightButton.setImage(UIImage(named: "star-60"), for: .normal)
            }
            
            rightButton.tag = annotation.hash
            rightButton.isUserInteractionEnabled = true
            anView?.rightCalloutAccessoryView = rightButton
            
            anView?.addSubview(pa.annImageView)
        }
        
        return anView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
        print("calloutAccessoryControlTapped")
        
        let ann = view.annotation as! PioAnnotation
        
        if ann.annType == PioAnnotation.AnnotationType.promo {
            showPromo(pid: ann.annId)
        }
        else if ann.annType == PioAnnotation.AnnotationType.product {
            showProduct(pid: ann.annId)
        }
        else if ann.annType == PioAnnotation.AnnotationType.store {
            showCompany(cid: ann.annId)
        }
        else if ann.annType == PioAnnotation.AnnotationType.poi {
            
            
            var pr = "noimage"
            
            if ann.annPhotoReference != nil {
                pr = ann.annPhotoReference
            }
            showPoi(pid: ann.annId, photoReference: pr)
        }
        
    }
    
    var locationReady = false
    func userLocationChanged() {
        reloadUserAnnotation()
        if !locationReady {
            locationReady = true
            startHome()
        }
    }
    
    
    
    func userPermissionChanged(_ status: CLAuthorizationStatus) {
        
        
        //reloadAnnotations()
        
    }
    
    func reloadUserAnnotation() {
        for ann in exploreMapView.annotations {
            if ann.isKind(of: PioAnnotation.self) {
                
                let pa = ann as! PioAnnotation
                
                if pa.annType == PioAnnotation.AnnotationType.user {
                    exploreMapView.removeAnnotation(pa)
                    let ann = PioAnnotation()
                    ann.coordinate = PioUser.sharedUser.location.coordinate
                    ann.title = "Sei qui"
                    ann.annType = PioAnnotation.AnnotationType.user
                    exploreMapView.addAnnotation(ann)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 240
        } else if indexPath.section == 1 {
            if com1ProdResults.count == 0 {
                return 223
            } else {
                return 453
            }
        } else {
            if com2ProdResults.count == 0 {
                return 0
            } else {
                return 319
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath) as! MapTableViewCell
            
            cell.setResults(res: mapResults, hc: self)
            Utility.sharedInstance.addBottomBorder(view: cell.container)
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyTableViewCell", for: indexPath) as! CompanyTableViewCell
            
            if com1Results.count == 0 {
                return cell
            }
            
            cell.companyName.text = com1Results["brand"] as? String
            
            print(com1Results)
            
            let imgPath = com1Results["brandimg"] as? String
            let opt = "http://pioalert.com/imgDelivery/?i="+imgPath!+"&w=1024"
            
            WebApi.sharedInstance.downloadedFrom(cell.companyImageView!, link: opt, mode: .scaleAspectFill, shadow: false)
            
            cell.pointer.removeFromSuperview()
            
            cell.setProdResults(res: com1ProdResults, hc: self)
            Utility.sharedInstance.addBottomBorder(view: cell.container)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Company2TableViewCell", for: indexPath) as! CompanyTableViewCell
            
            if com2Results.count == 0 {
                return cell
            }
            
            cell.companyName.text = com2Results["brand"] as? String
            
            let imgPath = com2Results["brandimg"] as? String
            let opt = "http://pioalert.com/imgDelivery/?i="+imgPath!+"&w=1024"
            
            WebApi.sharedInstance.downloadedFrom(cell.companyImageView!, link: opt, mode: .scaleAspectFill, shadow: false)
            
            cell.setProdResults(res: com2ProdResults, hc: self)
            Utility.sharedInstance.addBottomBorder(view: cell.container)
            
            return cell
        }
        
    }
    
    
    
    func isAlreadyLogged() -> Bool {
        
        var alreadyLogged = false
        
        if((FBSDKAccessToken.current()) != nil) {
            alreadyLogged = true
            print("User already logged on FB")
        }
        else if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            alreadyLogged = true
            print("User already logged on Google")
        }
        else {
            print("User not logged")
        }
        
        return alreadyLogged
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked...")
        
        searchController?.dismiss(animated: true, completion: { 
            self.searchTerm(text: searchBar.text!, idcat: "0")
        })
        
    }
    
    var selectedPromo:Promo!
    var selectedProduct:Product!
    var selectedCompany:Company!
    var selectedPoi:[String:AnyObject]!
    var selectedPhotoReference:String!
    
    func showPromo(pid: String) {
        selectedPromo = WebApi.sharedInstance.getAdById(pid)
        self.performSegue(withIdentifier: "showPromoFromMap", sender: self)
    }
    
    func showProduct(pid: String) {
        selectedProduct = WebApi.sharedInstance.getProductById(pid)
        self.performSegue(withIdentifier: "showProductFromMap", sender: self)
    }
    
    func showCompany(cid: String) {
        selectedCompany = WebApi.sharedInstance.getCompanyData(cid)
        self.performSegue(withIdentifier: "showCompanyFromMap", sender: self)
    }
    
    func showPoi(pid: String, photoReference: String) {
        selectedPhotoReference = photoReference
        selectedPoi = WebApi.sharedInstance.getPoiDetails(pid)
        self.performSegue(withIdentifier: "showPoiFromMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPromoFromMap" {
            let vc = segue.destination as! PromoViewController
            vc.promo = selectedPromo
        }
        else if segue.identifier == "showProductFromMap" {
            let vc = segue.destination as! ProductViewController
            vc.product = selectedProduct
        }
        else if segue.identifier == "showCompanyFromMap" {
            let vc = segue.destination as! ShopViewController
            vc.company = selectedCompany
        }
        else if segue.identifier == "showCompanyFromHome" {
            let vc = segue.destination as! ShopViewController
            vc.company = WebApi.sharedInstance.getCompanyData(com1Results["id"] as! String)
        }
        else if segue.identifier == "showPoiFromMap" {
            let vc = segue.destination as! PoiController
            vc.photoReference = selectedPhotoReference
            vc.result = selectedPoi
        }
        
    }
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as? CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

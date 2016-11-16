//
//  MasterViewController.swift
//  PioAlert
//
//  Created by LiveLife on 04/06/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import CoreLocation

protocol HorizontalScrollActionDelegate {
    func menuDidScroll(index: Int)
}

class MasterViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, GIDSignInUIDelegate, WebApiDelegate, UIGestureRecognizerDelegate {

    
    //var index = 0
    let api = WebApi.sharedInstance
    var fbUserId:String!
    var facebookProfileUrl:String?
    var appActive = false
    
    var bottomScrollMenu:UIScrollView?
    var totalWidth:CGFloat = 0
    var menuLabels = [UIButton]()
    let topBarview = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 60))
    
    var ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    var locationTimer:NSTimer?
    
    
    @IBOutlet weak var loginView:UIView?
    
    @IBOutlet weak var fbLoginButton:UIButton?
    @IBOutlet weak var googleLoginButton:UIButton?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    
    //let color = UIColor(red: (213/255), green: (181/255), blue: (76/255), alpha: 1.0)
    
    var allViewControllers = [ScrollingContentController]()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ai.color = Color.accent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        appDelegate.masterViewController = self
        
        if appDelegate.currentLocation == nil {
            let lat = NSUserDefaults.standardUserDefaults().doubleForKey("lat")
            let lng = NSUserDefaults.standardUserDefaults().doubleForKey("lng")
 
            
            //let lat = 40.380167
            //let lng = 15.540667
            appDelegate.currentLocation = CLLocation(latitude: lat, longitude: lng)
        }
        
        if WebApi.sharedInstance.uid == 0 {
            WebApi.sharedInstance.uid = NSUserDefaults.standardUserDefaults().integerForKey("uid")
        }
        
        WebApi.sharedInstance.delegate = self
        pageViewController.delegate = self
        pageViewController.dataSource = self
        GIDSignIn.sharedInstance().uiDelegate = self
        fbLoginButton?.layer.cornerRadius = 5
        googleLoginButton?.layer.cornerRadius = 5
        
        // User prefs
        if NSUserDefaults.standardUserDefaults().integerForKey("maxDistanceFromAds") == 0 {
            NSUserDefaults.standardUserDefaults().setInteger(20000, forKey: "maxDistanceFromAds")
        }
        
        WebApi.sharedInstance.isProfiled = NSUserDefaults.standardUserDefaults().boolForKey("isProfiled")
        WebApi.sharedInstance.canReceiveNotifications = NSUserDefaults.standardUserDefaults().boolForKey("canReceiveNotifications")
        WebApi.sharedInstance.isLogged = isAlreadyLogged()
        WebApi.sharedInstance.userName = NSUserDefaults.standardUserDefaults().stringForKey("userName")
        WebApi.sharedInstance.userImagePath = NSUserDefaults.standardUserDefaults().stringForKey("userImagePath")
        WebApi.sharedInstance.loggedWith = NSUserDefaults.standardUserDefaults().integerForKey("loggedWith")
        
        if NSUserDefaults.standardUserDefaults().stringForKey("deviceToken") == nil {
            let dt = UIDevice.currentDevice().identifierForVendor?.UUIDString
            NSUserDefaults.standardUserDefaults().setValue(dt, forKey: "deviceToken")
            NSUserDefaults.standardUserDefaults().synchronize()
            WebApi.sharedInstance.deviceToken = dt!
        } else {
            WebApi.sharedInstance.deviceToken = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken")!
        }
        
        WebApi.sharedInstance.userAddress = NSUserDefaults.standardUserDefaults().stringForKey("userAddress")
        
        
        
        ai.center = self.view.center
        view.addSubview(ai)
        
        if WebApi.sharedInstance.isLogged {
            self.loginView?.alpha = 0
            ai.startAnimating()
        }
        
        
        // Starting location update timer
        locationTimer = NSTimer.scheduledTimerWithTimeInterval(120, target: self, selector: #selector(MasterViewController.updateLocation), userInfo: nil, repeats: true)
        locationTimer?.fire()
        
    }
    
    
    
    func updateLocation() {
        if !appDelegate.geocoding {
            appDelegate.updateLocationAddress()
        }
    }
    
    /*
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !WebApi.sharedInstance.isLogged {
            loginView?.alpha = 0
            ai.startAnimating()
        }
        
    }
    */
    
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        if WebApi.sharedInstance.isLogged {
            print("viewDidAppear logged")
            checkAppAndRun()
        } else {
            print("viewDidAppear NOT logged")
        }
        
        if appDelegate.gotNotification {
            appDelegate.gotNotification = false
            appDelegate.showAlert()
            //masterViewController!.scrollToNotified()
        }
        
        
    }
    
    func showNotificationsAds() {
        if appDelegate.notificationIDs.count != 0 && appDelegate.notificationPointer <= appDelegate.notificationIDs.count {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("promoDetailController") as! PromoDetailController
            vc.isFromNotification = true
            vc.idAd = Int(appDelegate.notificationIDs[appDelegate.notificationPointer])
            /*
            vc.selectedPromo = WebApi.sharedInstance.getAdById(appDelegate.notificationIDs[appDelegate.notificationPointer])
            */
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
    }
    
    var token: dispatch_once_t = 0
    
    func checkAppAndRun() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if !api.checkApiServer() {
            let alertController = UIAlertController(title: "Server non raggiungibile", message: "Controlla la tua connessione internet o riprova tra poco.", preferredStyle: .Alert)
            
            //then we create a default action for the alert...
            //It is actually a button and we have given the button text style and handler
            //currently handler is nil as we are not specifying any handler
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            //now we are adding the default action to our alertcontroller
            alertController.addAction(defaultAction)
            
            //and finally presenting our alert using this method
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        if !WebApi.sharedInstance.isLogged && !WebApi.sharedInstance.isProfiled {
            
            print("NOT LOGGED NOT PROFILED")
            appActive = false
            self.loginView?.alpha = 0
            UIView.animateWithDuration(0.4, animations: {
                self.loginView?.alpha = 1
            })
        }
        else if !WebApi.sharedInstance.isLogged && WebApi.sharedInstance.isProfiled {
            
            print("NOT LOGGED   PROFILED")
            
            appActive = false
            self.loginView?.alpha = 0
            UIView.animateWithDuration(0.4, animations: {
                self.loginView?.alpha = 1
            })
            
        }
        else if WebApi.sharedInstance.isLogged && !WebApi.sharedInstance.isProfiled {
            
            print("LOGGED   NOT PROFILED")
            
            appActive = false
            self.loginView?.alpha = 0
            self.performSegueWithIdentifier("showCategoriesProfiler", sender: self)
            
        }
        else if WebApi.sharedInstance.isLogged && WebApi.sharedInstance.isProfiled && !WebApi.sharedInstance.canReceiveNotifications {
            
            print("LOGGED   PROFILED  NO NOTIF")
            
            appActive = false
            self.loginView?.alpha = 0
            self.performSegueWithIdentifier("showNoticationsAccept", sender: self)
            
        }
        else {
            
            
            if(token != 0) {
                print("Updating DATA? ***********************************************")
                /*
                for controller in allViewControllers {
                    controller.reloadData()
                }
                */
            }
            
            dispatch_once(&token) {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                print("READY")
                self.appActive = true
                self.loginView?.alpha = 0
                //self.createTopMenu()
                self.createMenuView()
                self.createBottomMenu()
                self.startApp(true)
            }
            
            //WebApi.sharedInstance.delegate = self
            
            /*
            if !appActive {
                print("App not active")
            } else {
                print("App already active")
            }
            */
            
            
            
        }
 
        
        /*
        if WebApi.sharedInstance.isLogged {
            appActive = false
            self.loginView?.alpha = 0
            self.performSegueWithIdentifier("showExtraInfo", sender: self)
        }
        */
    }
    
    
    func getFacebookInfo() {
        var path = "me"
        
        if fbUserId != nil {
            path = "/\(fbUserId)/"
        }
        
        let fbRequest = FBSDKGraphRequest(graphPath: path, parameters: ["fields": "id,name,email,first_name,last_name,verified,locale,timezone,gender,birthday,location,picture.type(large)"]);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            
            /*
            let alertController = UIAlertController(title: "FB", message: String(result), preferredStyle: .Alert)
            let actionShow = UIAlertAction(title: "Mostra", style: .Default, handler: nil)
            alertController.addAction(actionShow)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            */
            
            
            if error == nil {
                
                
                
                self.fbUserId = result.valueForKey("id") as? String
                print("User ID: \(self.fbUserId)")
                
                
                print("User Info : \(result)")
                
                WebApi.sharedInstance.userName = result.valueForKey("first_name") as? String
                
                
                
                let picture = result.valueForKey("picture")?.valueForKey("data")?.valueForKey("url") as! String
                print(picture)
                
                self.facebookProfileUrl = picture//"http://graph.facebook.com/\(self.fbUserId)/picture?type=large"
                
                WebApi.sharedInstance.userImagePath = picture//"http://graph.facebook.com/"+String(self.fbUserId)+"/picture?type=large"
                
                
                
                
                
                WebApi.sharedInstance.loggedWith = Login.FacebookLogged
                
                NSUserDefaults.standardUserDefaults().setValue(result.valueForKey("first_name"), forKeyPath: "userName")
                NSUserDefaults.standardUserDefaults().setValue(WebApi.sharedInstance.userImagePath, forKeyPath: "userImagePath")
                NSUserDefaults.standardUserDefaults().setValue(WebApi.sharedInstance.loggedWith, forKeyPath: "loggedWith")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                WebApi.sharedInstance.sendFbUserData(result)
                
            } else {
                
                print("Error Getting Info \(error)");
                
            }
            
        }
    }
    
    /*
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapSignOut(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
    }
    */
    
    
    
    func showLogin(active: Bool) {
        
        if active {
            
        }
        
    }
    
    func isAlreadyLogged() -> Bool {
        
        var alreadyLogged = false
        
        if((FBSDKAccessToken.currentAccessToken()) != nil) {
            alreadyLogged = true
            print("User already logged on FB")
            //WebApi.sharedInstance.isLogged = true
            //self.getFacebookInfo()
        }
        else if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            alreadyLogged = true
            print("User already logged on Google")
            //WebApi.sharedInstance.isLogged = true
            //GIDSignIn.sharedInstance().signInSilently()
        }
        else {
            print("User not logged")
        }
        
        //WebApi.sharedInstance.isLogged = alreadyLogged
        
        return alreadyLogged
    }
    
    var menuButton = UIButton()
    var searchButton = UIButton()
    var menuVisible = false
    var menuView:UIView!
    
    func createMenuView() {
        // Create menu view
        
        let screen = UIScreen.mainScreen().bounds
        
        let menuViewFrame = CGRectMake(-menuWidth, 0, menuWidth, screen.size.height)
        menuView = UIView(frame: menuViewFrame)
        menuView.backgroundColor = Color.primaryDark
        menuView.layer.shadowColor = UIColor.blackColor().CGColor
        menuView.layer.shadowOpacity = 0.6
        menuView.layer.shadowOffset = CGSizeMake(2, 0)
        
        
        // Create menu items
        let items = ["Ciao "+WebApi.sharedInstance.userName!+"!","Coupon","Opzioni","Mi Interessa","La mia posizione","I miei Carrelli","Info su PIO"]
        
        
        
        let userImage = UIImageView(frame: CGRectMake(10, 30, 40, 40))
        userImage.layer.cornerRadius = 20
        userImage.layer.borderColor = Color.accent.CGColor
        userImage.layer.borderWidth = 2
        userImage.clipsToBounds = true
        WebApi.sharedInstance.downloadedFrom(userImage, link: WebApi.sharedInstance.userImagePath!, mode: .ScaleAspectFill, shadow: true)
        
        menuView.addSubview(userImage)
        
        var ypos:CGFloat = 80
        let h:CGFloat = 50
        var count = 0
        
        for item in items {
            let itemButton = UIButton()
            itemButton.frame = CGRectMake(10,ypos,menuView.frame.size.width-10,h)
            itemButton.setTitle(item, forState: .Normal)
            itemButton.titleLabel?.font = UIFont(name: "Futura-Medium", size: 20)
            itemButton.contentHorizontalAlignment = .Left
            itemButton.tag = count
            itemButton.addTarget(self, action: #selector(MasterViewController.selectMenuItem(_:)), forControlEvents: .TouchUpInside)
            count += 1
            
            menuView.addSubview(itemButton)
            
            let borderBottom = UIView(frame: CGRectMake(0,ypos+h,menuView.frame.size.width,1))
            borderBottom.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
            borderBottom.clipsToBounds = false
            borderBottom.layer.shadowColor = UIColor.blackColor().CGColor
            borderBottom.layer.shadowOffset = CGSizeMake(0, 1)
            borderBottom.layer.shadowOpacity = 1
            menuView.addSubview(borderBottom)
            
            ypos+=h
            ypos+=1
            
        }
        
        if WebApi.sharedInstance.loggedWith == Login.FacebookLogged {
            let fbButt = UIButton(frame: CGRectMake(10, screen.size.height-fbLoginButton!.frame.size.height-10, menuWidth-20, fbLoginButton!.frame.size.height))
            fbButt.backgroundColor = Color.facebook
            fbButt.setTitle("LOGOUT DA FACEBOOK", forState: .Normal)
            fbButt.titleLabel?.font = UIFont(name: "Futura-Medium", size: 13)
            fbButt.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            fbButt.layer.cornerRadius = 3
            fbButt.tag = Login.FacebookLogged
            fbButt.addTarget(self, action: #selector(logout), forControlEvents: .TouchUpInside)
            menuView.addSubview(fbButt)
        } else {
            let gButt = UIButton(frame: CGRectMake(10, screen.size.height-fbLoginButton!.frame.size.height-10, menuWidth-20, fbLoginButton!.frame.size.height))
            gButt.backgroundColor = UIColor.whiteColor()
            gButt.setTitle("LOGOUT DA GOOGLE", forState: .Normal)
            gButt.titleLabel?.font = UIFont(name: "Futura-Medium", size: 13)
            gButt.setTitleColor(UIColor.blackColor(), forState: .Normal)
            gButt.layer.cornerRadius = 3
            gButt.tag = Login.GoogleLogged
            gButt.addTarget(self, action: #selector(logout), forControlEvents: .TouchUpInside)
            menuView.addSubview(gButt)
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(MasterViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Left
        swipeRight.delegate = self
        menuView.addGestureRecognizer(swipeRight)
    }
    
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func createTopMenu() {
        let screen = UIScreen.mainScreen().bounds
        
        topBarview.backgroundColor = Color.primary
        topBarview.layer.shadowColor = UIColor.blackColor().CGColor
        topBarview.layer.shadowOpacity = 0.6
        topBarview.layer.shadowOffset = CGSizeMake(0, 2)
        
        let logoImage = UIImageView(image: UIImage(named: "pioapp_40_x1"))
        let logoFrame = CGRectMake((screen.size.width/2)-20, 20, 40, 40)
        logoImage.frame = logoFrame
        logoImage.contentMode = .ScaleAspectFill
        topBarview.addSubview(logoImage)
        
        let frame = CGRectMake(8, 20, 40, 40)
        menuButton.frame = frame
        menuButton.setImage(UIImage(named: "menu_button_40_x1"), forState: .Normal)
        menuButton.addTarget(self, action: #selector(showMenu), forControlEvents: .TouchUpInside)
        topBarview.addSubview(menuButton)
        
        let searchFrame = CGRectMake(screen.size.width-36, 25, 26, 26)
        searchButton.frame = searchFrame
        searchButton.setImage(UIImage(named: "search_button"), forState: .Normal)
        searchButton.addTarget(self, action: #selector(showSearch), forControlEvents: .TouchUpInside)
        topBarview.addSubview(searchButton)
        
        
        
        
    }
    
    func selectMenuItem(sender: UIButton) {
        
        
        switch sender.tag {
        case 0:
            // None
            break
        case 1:
            // Coupon
            self.performSegueWithIdentifier("showUsedCoupon", sender: self)
            break
        case 2:
            // Opzioni
            self.performSegueWithIdentifier("showOptions", sender: self)
            break
        case 3:
            // Mi Interessa
            self.performSegueWithIdentifier("showCategoriesProfiler", sender: self)
            break
        case 4:
            // La mia posizione
            self.performSegueWithIdentifier("showLocation", sender: self)
            break
        case 5:
            // Info
            self.performSegueWithIdentifier("showCarts", sender: self)
            break
        case 6:
            // Info
            self.performSegueWithIdentifier("showInfo", sender: self)
            break
        default:
            break
        }
        
        
    }
    
    func logout(sender: UIButton) {
        
        
        
        if sender.tag == Login.FacebookLogged {
            print("logout from FB...")
            FBSDKLoginManager().logOut()
            
        } else {
            print("logout from G...")
            GIDSignIn.sharedInstance().signOut()
        }
        
        WebApi.sharedInstance.isLogged = false
        WebApi.sharedInstance.logout();
        
        
        
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                print("Swiped left")
                showMenu()
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    let menuWidth:CGFloat = 220
    
    @IBAction func showSearch() {
        // Show map with ads
        self.performSegueWithIdentifier("showSearchContent", sender: self)
    }
    
    @IBAction func showMenu() {
        if !menuVisible {
            menuVisible = true
            
            //self.view.addSubview(menuView)
            self.navigationController?.view.addSubview(menuView)
            
            var frame = menuView.frame
            frame.origin.x = 0
            
            var mainFrame = pageViewController.view.frame
            mainFrame.origin.x = menuWidth
            
            UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseInOut, animations: {
                self.pageViewController.view.frame = mainFrame
                self.menuView.frame = frame
                }, completion: { (Bool) in
                    
            })
            
           
            
        } else {
            menuVisible = false
            
            var frame = menuView.frame
            frame.origin.x = -menuWidth
            
            var mainFrame = pageViewController.view.frame
            mainFrame.origin.x = 0
            
            UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseInOut, animations: {
                self.pageViewController.view.frame = mainFrame
                self.menuView.frame = frame
                }, completion: { (Bool) in
                    self.menuView.removeFromSuperview()
            })
            
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCategoriesProfiler" {
            //let viewController = segue.destinationViewController as? CategoriesController
            
            //viewController?.allCats = WebApi.sharedInstance.getAllCategories()
        }
        
        /*
        else if segue.identifier == "showSingleScrollContent" {
            let butt = sender as! UIButton
            
            if butt.tag == 2 {
                //let liked = WebApi.sharedInstance.liked.map({"\($0)"}).joinWithSeparator(",")
                let viewController = segue.destinationViewController as? ScrollingContentController
                
                viewController?.content = WebApi.sharedInstance.getUserLiked()
                viewController?.name = "Piaciuti"
                viewController?.cat = 9999
            }
            
        }
        */
        else if segue.identifier == "showMapContent" {
            let viewController = segue.destinationViewController as? MapContentController
            let currentViewController = self.pageViewController.viewControllers![pageIndex] as! ScrollingContentController
            viewController?.promos = currentViewController.content
            viewController?.name = currentViewController.name
        }
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        UIView.animateWithDuration(0.3) { 
            self.loginView?.alpha = 0
            self.ai.startAnimating()
        }
        
        fbLoginManager.logInWithReadPermissions(["public_profile","email"], fromViewController: self, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFacebookInfo()
                    
                }
            } else {
                print(error)
            }
        })
        
        
    }
    
    @IBAction func loginWithGoogle(sender: AnyObject) {
        UIView.animateWithDuration(0.3) {
            self.loginView?.alpha = 0
            self.ai.startAnimating()
        }
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    func startApp(active: Bool) {
        
        if(active) {
            self.addChildViewController(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)
            self.pageViewController.didMoveToParentViewController(self)
        
            self.pageViewController.view.addSubview(topBarview)
            self.pageViewController.view.addSubview(bottomScrollMenu!)
            
            
            // Add view controllers
            let cats = NSUserDefaults.standardUserDefaults().arrayForKey("choosenCats") as! [Int]
            
            var count = 0
            
            // Add main Mi Interessa
            let nextViewController: ScrollingContentController = self.storyboard!.instantiateViewControllerWithIdentifier("scrollingContentController") as! ScrollingContentController
            
            nextViewController.content = WebApi.sharedInstance.getUserAds()
            nextViewController.index = count
            nextViewController.name = "Mi Interessa"
            
            allViewControllers.append(nextViewController)
            
            count+=1
            
            for cat in cats {
                let nextViewController: ScrollingContentController = self.storyboard!.instantiateViewControllerWithIdentifier("scrollingContentController") as! ScrollingContentController
                
                nextViewController.content = WebApi.sharedInstance.getCategoryAds(cat)
                nextViewController.index = count
                nextViewController.name = menuLabels[count].titleLabel!.text
                nextViewController.cat = cat
                allViewControllers.append(nextViewController)
                
                count+=1
            }
            
            // Adding Piaciuti
            let nextViewController2: ScrollingContentController = self.storyboard!.instantiateViewControllerWithIdentifier("scrollingContentController") as! ScrollingContentController
            
            nextViewController2.content = WebApi.sharedInstance.getUserLiked()
            nextViewController2.index = count
            nextViewController2.name = "Piaciuti"
            nextViewController2.cat = 9999
            
            allViewControllers.append(nextViewController2)
            
            count+=1
            
            // Adding Notificati
            let nextViewController3: ScrollingContentController = self.storyboard!.instantiateViewControllerWithIdentifier("scrollingContentController") as! ScrollingContentController
            
            nextViewController3.content = WebApi.sharedInstance.getUserNotified()
            nextViewController3.index = count
            nextViewController3.name = "Notificati"
            nextViewController3.cat = 7777
            
            allViewControllers.append(nextViewController3)
            
            pageViewController.setViewControllers([allViewControllers[0]], direction: .Forward, animated: false, completion: {done in })
            
        } else {
            self.menuLabels.removeAll()
            self.pageViewController.view.removeFromSuperview()
            self.pageViewController.removeFromParentViewController()
            self.topBarview.removeFromSuperview()
            self.bottomScrollMenu?.removeFromSuperview()
            self.menuView.removeFromSuperview()
            self.allViewControllers.removeAll()
            self.token = 0
        }
        
        
        
    }
    
    func createBottomMenu() {
        
        let screen = UIScreen.mainScreen().bounds
        let menuFrame = CGRectMake(0, screen.size.height-55, screen.size.width, 55)
        self.bottomScrollMenu = UIScrollView(frame: menuFrame)
        self.bottomScrollMenu!.backgroundColor = Color.primary
        
        let leftPadding:CGFloat = 8
        let topPadding:CGFloat = 13
        let w:CGFloat = 125
        let h:CGFloat = 30.0
        var count:CGFloat = 0
        
        let userCats = NSUserDefaults.standardUserDefaults().objectForKey("userCats") as! [[String:AnyObject]]
        
        let x = (w * CGFloat(count) + leftPadding)
        
        let label = UIButton(frame: CGRectMake(x, topPadding, w, h))
        //label.center = CGPointMake(160, 284)
        label.titleLabel!.textAlignment = NSTextAlignment.Center
        label.setTitle("Mi Interessa", forState: .Normal)
        label.titleLabel!.font = UIFont(name: "Futura", size: 18.0)
        //label.titleLabel!.textColor = UIColor.yellowColor()
        label.tag = Int(count)
        label.addTarget(self, action: #selector(scrollToViewController), forControlEvents: .TouchUpInside)
        self.bottomScrollMenu!.addSubview(label)
        menuLabels.append(label)
        
        totalWidth += label.frame.size.width + leftPadding
        count += 1
        
        for item in userCats {
            
            let x = (w * CGFloat(count) + leftPadding)
            
            let label = UIButton(frame: CGRectMake(x, topPadding, w, h))
            //label.center = CGPointMake(160, 284)
            label.titleLabel!.textAlignment = NSTextAlignment.Center
            label.setTitle(item["name"] as? String, forState: .Normal)
            label.titleLabel!.font = UIFont(name: "Futura", size: 18.0)
            label.titleLabel!.textColor = UIColor.whiteColor()
            label.tag = Int(count)
            label.addTarget(self, action: #selector(scrollToViewController), forControlEvents: .TouchUpInside)
            /*
            if count != 0 {
                label.alpha = 0.5
            }
            */
            
            self.bottomScrollMenu!.addSubview(label)
            menuLabels.append(label)
            
            totalWidth += label.frame.size.width + leftPadding
            count += 1
        }
        
        
        let xpos:CGFloat = leftPadding+(count*w)
        
        let labelFav = UIButton(frame: CGRectMake(xpos, topPadding, w, h))
        //label.center = CGPointMake(160, 284)
        labelFav.titleLabel!.textAlignment = NSTextAlignment.Center
        labelFav.setTitle("Piaciuti", forState: .Normal)
        labelFav.titleLabel!.font = UIFont(name: "Futura", size: 18.0)
        //labelFav.titleLabel!.textColor = UIColor.yellowColor()
        labelFav.tag = Int(count)
        labelFav.addTarget(self, action: #selector(scrollToViewController), forControlEvents: .TouchUpInside)
        self.bottomScrollMenu!.addSubview(labelFav)
        menuLabels.append(labelFav)
        
        totalWidth += w + leftPadding
        
        count += 1
        
        let xpos2:CGFloat = leftPadding+(count*w)
        
        let labelNot = UIButton(frame: CGRectMake(xpos2, topPadding, w, h))
        //label.center = CGPointMake(160, 284)
        labelNot.titleLabel!.textAlignment = NSTextAlignment.Center
        labelNot.setTitle("Notificati", forState: .Normal)
        labelNot.titleLabel!.font = UIFont(name: "Futura", size: 18.0)
        //labelFav.titleLabel!.textColor = UIColor.yellowColor()
        labelNot.tag = Int(count)
        labelNot.addTarget(self, action: #selector(scrollToViewController), forControlEvents: .TouchUpInside)
        self.bottomScrollMenu!.addSubview(labelNot)
        menuLabels.append(labelNot)
        
        totalWidth += w + leftPadding
        
        
    }
    
    var pageIndex = 0
    
    func scrollToViewController(sender: UIButton) {
        
        var direction:UIPageViewControllerNavigationDirection!
            
        if sender.tag > pageIndex {
            pageIndex = sender.tag
            direction = UIPageViewControllerNavigationDirection.Forward
        }
        else if sender.tag < pageIndex {
            pageIndex = sender.tag
            direction = UIPageViewControllerNavigationDirection.Reverse
        } else {
            return
        }
        
        
        pageViewController.setViewControllers([allViewControllers[sender.tag]], direction: direction, animated: true, completion: nil)
        
        let label = menuLabels[sender.tag]
        let xpos = CGPointMake(label.center.x - label.frame.size.width/2 , (bottomScrollMenu?.contentOffset.y)!)
        
        bottomScrollMenu!.setContentOffset(xpos, animated: true)
    }
    
    func scrollToNotified() {
        
        let index = menuLabels.count-1
        
        var direction:UIPageViewControllerNavigationDirection!
        
        if index > pageIndex {
            pageIndex = index
            direction = UIPageViewControllerNavigationDirection.Forward
        }
        else if index < pageIndex {
            pageIndex = index
            direction = UIPageViewControllerNavigationDirection.Reverse
        } else {
            return
        }
        
        
        pageViewController.setViewControllers([allViewControllers[index]], direction: direction, animated: true, completion: nil)
        
        let label = menuLabels[index]
        let xpos = CGPointMake(label.center.x - label.frame.size.width/2 , (bottomScrollMenu?.contentOffset.y)!)
        
        bottomScrollMenu!.setContentOffset(xpos, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        if bottomScrollMenu != nil {
            bottomScrollMenu!.contentSize.width = totalWidth
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func indexOfViewController(viewController: ScrollingContentController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        let label = menuLabels[viewController.index]
        //print("x \(label.frame.origin.x)")
        
        let xpos = CGPointMake(label.center.x - label.frame.size.width/2 , (bottomScrollMenu?.contentOffset.y)!)
        
        bottomScrollMenu!.setContentOffset(xpos, animated: true)
        
        if viewController.index == allViewControllers.count-1 {
            //print("PIACIUTI")
            viewController.reloadData()
        }
        
        return viewController.index
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ScrollingContentController)
        
        
        index -= 1
        if index < 0 {
            return nil
        }
        return self.allViewControllers[index]
    }
    
    
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ScrollingContentController)
        
        
        index += 1
        
        if index == self.allViewControllers.count {
            return nil
        }
        
        return self.allViewControllers[index]
    }
    
    func didSendApiMethod(method: String, result: String) {
        if method == "logout" {
            
            showMenu()
            
            //self.pageViewController.view.removeFromSuperview()
            //self.pageViewController.removeFromParentViewController()
            startApp(false)
            
            
            dispatch_async(dispatch_get_main_queue()) {
                
                UIView.animateWithDuration(0.4, animations: {
                    self.loginView?.alpha = 1
                    self.ai.stopAnimating()
                })
            }
            
        }
        else if (method == "sendFbUserData" || method == "sendGoogleUserData") {
            
            print("Sent method: "+method)
            
            //WebApi.sharedInstance.isLogged = true
            dispatch_async(dispatch_get_main_queue()) {
                self.checkAppAndRun()
            }
        }
        
        
        print("MasterViewController: "+method+" sent succesfully")
        
    }
    
    func errorSendingApiMethod(method: String, error: String) {
        print("Error sending method: "+method+" error: "+error)
        
        if (method == "sendFbUserData" || method == "sendGoogleUserData") {
            
            WebApi.sharedInstance.isLogged = false
            dispatch_async(dispatch_get_main_queue()) {
                self.checkAppAndRun()
            }
        }
    }

}

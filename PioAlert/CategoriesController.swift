//
//  CategoriesController.swift
//  PioAlert
//
//  Created by LiveLife on 26/06/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class CategoriesController: UIViewController, UITableViewDelegate, UITableViewDataSource,   WebApiDelegate {
    
    
    @IBOutlet weak var check1:UIBarButtonItem!
    @IBOutlet weak var check2:UIBarButtonItem!
    @IBOutlet weak var check3:UIBarButtonItem!
    @IBOutlet weak var doneButton:UIBarButtonItem!
    
    
    @IBOutlet weak var tableView:UITableView!
    
    var allCats:[Category]!
    
    //var allChecks = [UIImageView]()
    
    var choosenCats = [Int]()
    var choosenObjects = [Category]()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WebApi.sharedInstance.delegate = self
        
        check1.enabled = false
        check2.enabled = false
        check3.enabled = false
        doneButton.enabled = false
        
        allCats = WebApi.sharedInstance.getAllCategories()
        
        if NSUserDefaults.standardUserDefaults().arrayForKey("choosenCats") != nil {
            choosenCats = NSUserDefaults.standardUserDefaults().arrayForKey("choosenCats") as! [Int]
            
            let userCats = NSUserDefaults.standardUserDefaults().objectForKey("userCats") as! [[String:AnyObject]]
            
            for obj in userCats {
                let cat = Category()
                cat.cid = obj["cid"]?.integerValue
                cat.name = obj["name"] as? String
                choosenObjects.append(cat)
            }
            
            print(userCats)
            print("found \(choosenObjects.count) categories")
            
        } else {
            choosenCats = [Int]()
        }
        
        
        checkChoosenCats()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //createScrollView()
    }
    
    func checkChoosenCats() {
        
        let checks = [check1,check2,check3]
        check1.enabled = false
        check2.enabled = false
        check3.enabled = false
        doneButton.enabled = false
        
        
        var count = 0
        for _ in choosenCats {
            
            if count >= 3 {
                break
            }
            
            checks[count].enabled = true
            count += 1
        }
        
        
        if choosenCats.count >= 3 {
            doneButton.enabled = true
        } else {
            doneButton.enabled = false
        }
        
        tableView.reloadData()
    }
    
    
    func selectCat(category: Category) {
        
        
        if choosenCats.contains(category.cid) {
            choosenCats = choosenCats.filter { $0 != category.cid }
            choosenObjects = choosenObjects.filter { $0 === category }
            
        } else {
            choosenCats.append(category.cid)
            choosenObjects.append(category)
            
        }
        
        checkChoosenCats()
        print(choosenCats)
        
    }
    
    @IBAction func start(sender: UIBarButtonItem) {
        
        
        var userCats = [[String:AnyObject]]()
        
        for cat in choosenObjects {
            var uc = [String:AnyObject]()
            uc["cid"] = cat.cid
            uc["name"] = cat.name
            
            userCats.append(uc)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(userCats, forKey: "userCats")
        NSUserDefaults.standardUserDefaults().synchronize()
    
        let cats = choosenCats.map({"\($0)"}).joinWithSeparator(",")
        WebApi.sharedInstance.setUsersCategories(cats)
        
        
        
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCats.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cat = allCats[indexPath.row]
        selectCat(cat)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath)
        
        let cat = allCats[indexPath.row]
        
        cell.textLabel?.text = cat.name
        
        if choosenCats.contains(cat.cid) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
        
    }
    
    
    
    
    
    
    func didSendApiMethod(method: String, result: String) {
        print("method "+method+" result: "+result)
        
        WebApi.sharedInstance.isProfiled = true
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isProfiled")
        NSUserDefaults.standardUserDefaults().setObject(choosenCats, forKey: "choosenCats")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        dispatch_async(dispatch_get_main_queue()) {
            let nc = self.presentingViewController as! PioNavigationController!
            let vc = nc.topViewController as! MasterViewController
            WebApi.sharedInstance.delegate = vc
            
            if vc.menuVisible {
                vc.showMenu()
                vc.startApp(false)
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        
    }
    
    func errorSendingApiMethod(method: String, error: String) {
        WebApi.sharedInstance.isProfiled = false
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isProfiled")
        NSUserDefaults.standardUserDefaults().synchronize()
        print(method+" "+error)
    }

}

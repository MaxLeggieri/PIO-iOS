//
//  SearchController.swift
//  PioAlert
//
//  Created by LiveLife on 11/11/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class SearchController: UITableViewController, UITextFieldDelegate {

    
    @IBOutlet weak var searchTextField:UITextField!
    @IBOutlet weak var closeButton:UIBarButtonItem!
    
    var results = [Result]()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //searchTextField.addTarget(self, action: #selector(textDidChange), forControlEvents: .EditingChanged)
        
        searchTextField.delegate = self
        let timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(searchCheck), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        searchTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.resignFirstResponder()
    }
    
    var lastSearch:String!
    func searchCheck() {
        
        //print("searchCheck...")
        let text = searchTextField.text
        
        if lastSearch == text {
            return
        } else {
            
            if text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 2 {
                
                results = WebApi.sharedInstance.search(text!)
                self.tableView.reloadData()
                
                
            }
            
        }
        
        lastSearch = text
        
        
    }
    
    
    @IBAction func closeSearch() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> ResultCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath) as! ResultCell
        
        let r = results[indexPath.row]
        cell.rTitle?.text = r.title
        cell.rSubtitle?.text = r.desc
        
        
        
        let imagePath = "http://www.pioalert.com"+r.image!
        cell.rImage!.alpha = 0
        
        WebApi.sharedInstance.downloadedFrom(cell.rImage!, link: imagePath, mode: .ScaleAspectFill, shadow: false)
        
        var img:UIImage!
        
        if r.type == "ad" {
            img = UIImage(named: "promo_icon")
        }
        else if r.type == "product" {
            img = UIImage(named: "cart_icon")
        }
        else if r.type == "company" {
            img = UIImage(named: "company_icon")
        }
        
        let frame = CGRectMake(0, 0, 20, 20)
        cell.accessoryView = UIView(frame: frame)
        let accImg = UIImageView(frame: frame)
        accImg.contentMode = .ScaleAspectFill
        accImg.image = img
        cell.accessoryView?.addSubview(accImg)
        return cell
        
    }
    
    //var selectedPromo:Promo!
    var selectedProduct:Product!
    var selectedAdId:Int!
    var selectedProdId:Int!
    var selectedCompanyId:Int!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let res = results[indexPath.row]
        
        if res.type == "ad" {
            
            //selectedPromo = WebApi.sharedInstance.getAdById(String(res.id))
            selectedAdId = res.id
            self.performSegueWithIdentifier("showPromo", sender: self)
        }
        else if res.type == "product" {
            
            
            selectedProdId = res.id
            self.performSegueWithIdentifier("showProduct", sender: self)
        }
        else if res.type == "company" {
            
            selectedCompanyId = res.id
            self.performSegueWithIdentifier("showCompany", sender: self)
            
        }
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showPromo" {
            let vc = segue.destinationViewController as! PromoDetailController
            vc.isFromSearch = true
            vc.idAd = selectedAdId
            
        }
        else if segue.identifier == "showProduct" {
            
            let vc = segue.destinationViewController as! ProductDetailController
            vc.isFromSearch = true
            vc.prodId = selectedProdId
            
        }
        else if segue.identifier == "showCompany" {
            
            let vc = segue.destinationViewController as! CompanyController
            vc.isFromSearch = true
            vc.companyId = selectedCompanyId
            
        }
    }

}

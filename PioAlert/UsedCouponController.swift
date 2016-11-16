//
//  UsedCouponController.swift
//  PioAlert
//
//  Created by LiveLife on 19/07/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class UsedCouponController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var content = [Promo]()
    @IBOutlet weak var tableView:UITableView!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        content = WebApi.sharedInstance.getUsedCoupons()
        
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return content.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("couponCell", forIndexPath: indexPath)

        // Configure the cell...
        let promo = content[indexPath.row]
        
        let data = promo.couponCode.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter!.setValue(data, forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")
        
        cell.imageView?.image = UIImage(CIImage:filter!.outputImage!)
        cell.textLabel?.text = promo.title
        
        
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(promo.usedCoupon))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        cell.detailTextLabel?.text = "Usato il: "+dateFormatter.stringFromDate(date)
        return cell
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        footerView.backgroundColor = Color.primaryDark.colorWithAlphaComponent(0.9)
        
        let label = UILabel(frame: CGRectMake(8,4,320,20))
        label.font = UIFont(name: "Futura", size: 15.0)
        label.textColor = UIColor.whiteColor()
        label.text = "\(content.count) Coupon"
        
        if content.count == 0 {
            label.text = label.text!+" - Trascina in basso per ricaricare"
        }
        
        footerView.addSubview(label)
        return footerView
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        headerView.backgroundColor = Color.primaryDark.colorWithAlphaComponent(0.9)
        
        let label = UILabel(frame: CGRectMake(8,4,400,20))
        label.font = UIFont(name: "Futura", size: 15.0)
        label.textColor = UIColor.whiteColor()
        label.text = "Coupon Utilizzati"
        
        headerView.addSubview(label)
        return headerView
    }
    
    var selectedPromo:Promo?
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPromo = content[indexPath.row]
        
        self.performSegueWithIdentifier("showCouponDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let vc = segue.destinationViewController as? CouponDisplayController
        vc?.selectedPromo = self.selectedPromo
        
    }
    
    @IBAction func dismiss(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

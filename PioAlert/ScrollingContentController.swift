//
//  ScrollingContentController.swift
//  PioAlert
//
//  Created by LiveLife on 04/06/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class ScrollingContentController: UITableViewController {

    var totalWidth:CGFloat = 0
    var menuLabels = [UILabel]()
    
    var index:Int = 0
    
    var content = [Promo]()
    var name:String?
    var cat:Int = 0
    let api = WebApi.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None;
        
        
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 55, 0)
        print("COMPANY IMAGE: \(selectedPromo?.cimage)")
        
        self.tableView.reloadData()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = Color.accent
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), forControlEvents: .ValueChanged)
        
        //print(api.allMenuItems[index].title)
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(footerLabel != nil) {
            footerLabel!.text = WebApi.sharedInstance.userAddress
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // UITableView methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    /*
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return api.allMenuItems[self.index].title
    }
 
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "\(content.count) Offerte"
    }
    */
    
    
    var footerLabel:UILabel?
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        footerView.backgroundColor = Color.primaryDark.colorWithAlphaComponent(0.9)
        
        footerLabel = UILabel(frame: CGRectMake(8,4,320,20))
        footerLabel!.font = UIFont(name: "Futura", size: 15.0)
        footerLabel!.textColor = UIColor.whiteColor()
        //footerLabel.text = "\(content.count) Offerte"
        
        /*
        if content.count == 0 {
            label.text = label.text!+" - Trascina in basso per ricaricare"
        }
        */
        
        if WebApi.sharedInstance.userName != nil {
            footerLabel!.text = WebApi.sharedInstance.userAddress
        }
        
        footerView.addSubview(footerLabel!)
        return footerView
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        headerView.backgroundColor = Color.primaryDark.colorWithAlphaComponent(0.9)
        
        let label = UILabel(frame: CGRectMake(8,4,400,20))
        label.font = UIFont(name: "Futura", size: 15.0)
        label.textColor = UIColor.whiteColor()
        label.text = name
        
        headerView.addSubview(label)
        return headerView
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> PromoViewCell {
        
        
        var cell: PromoViewCell!
        
        
        cell = tableView.dequeueReusableCellWithIdentifier("promoViewCell", forIndexPath: indexPath) as! PromoViewCell
        
        
        let promo = content[indexPath.row] as Promo
        
        //cell.likeButton.imageView?.image = nil
        //cell.pimage.image = nil
        
        
        
        if promo.liked! {
            cell.likeButton.setImage(UIImage(named: "star_selected_35_x1"), forState: .Normal)
            cell.likeButton.liked = true
            //promo.liked = true
        } else {
            cell.likeButton.setImage(UIImage(named: "star_unselected_35_x1"), forState: .Normal)
            cell.likeButton.liked = false
            //promo.liked = false
        }
        
        cell.likeButton.tag = promo.promoId!
        cell.likeButton.layer.masksToBounds = false
        cell.likeButton.layer.shadowColor = UIColor.blueColor().CGColor
        cell.likeButton.layer.shadowOffset = CGSizeMake(0, 1)
        cell.likeButton.layer.shadowRadius = 1;
        cell.likeButton.layer.shadowOpacity = 0.5;
        
        cell.title.text = promo.title
        cell.desc.text = promo.desc
        cell.prod_name.text = promo.prodName
        
        cell.cellContent.layer.shadowColor = UIColor.blackColor().CGColor
        cell.cellContent.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.cellContent.layer.shadowOpacity = 0.6
        
        cell.contentView.layer.shadowColor = UIColor.blackColor().CGColor
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: -2)
        cell.contentView.layer.shadowOpacity = 0.6
        
        let imagePath = "http://www.pioalert.com"+promo.imagePath!
        cell.pimage.alpha = 0
        
        api.downloadedFrom(cell.pimage, link: imagePath, mode: .ScaleAspectFill, shadow: false)
        
 
        cell.likeButton.addTarget(self, action: #selector(likeAd), forControlEvents: .TouchUpInside)
        
        return cell
        
        
    }
    
    func likeAd(sender: LikeButton) {
        if sender.liked! {
            sender.setImage(UIImage(named: "star_unselected_35_x1"), forState: .Normal)
            //WebApi.sharedInstance.liked = WebApi.sharedInstance.liked.filter { $0 != sender.tag }
            
            WebApi.sharedInstance.likeAd(false, idad: sender.tag)
            
        } else {
            sender.setImage(UIImage(named: "star_selected_35_x1"), forState: .Normal)
            //WebApi.sharedInstance.liked.append(sender.tag)
            
            WebApi.sharedInstance.likeAd(true, idad: sender.tag)
        }
        
        reloadData()
        
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        reloadData()
        
        refreshControl.endRefreshing()
    }
    
    func reloadData() {
        
        if cat == 0 {
            content = WebApi.sharedInstance.getUserAds()
            
        }
        else if cat == 9999 {
            content = WebApi.sharedInstance.getUserLiked()
        }
        else if cat == 7777 {
            content = WebApi.sharedInstance.getUserNotified()
        }
        else {
            content = WebApi.sharedInstance.getCategoryAds(cat)
        }
        
        self.tableView.reloadData()
    }
    
    
    
    var selectedPromo:Promo?
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("didSelectRowAtIndexPath...")
        
        selectedPromo = content[indexPath.row] as Promo
        
        // showPromoDetail
        
        self.performSegueWithIdentifier("showPromoDetail", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPromoDetail" {
            let nc = segue.destinationViewController as? PioNavigationController
            let vc = nc?.viewControllers.first as? PromoDetailController
            vc?.selectedPromo = self.selectedPromo
        }
    }
    
    
    
}

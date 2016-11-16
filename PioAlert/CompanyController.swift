//  CompanyController.swift
//  PioAlert
//
//  Created by LiveLife on 04/09/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class CompanyController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var company:Company!
    var companyId:Int!
    var isFromSearch = false
    
    @IBOutlet weak var companyName:UILabel!
    @IBOutlet weak var companyDesc:UILabel!
    @IBOutlet weak var companyImage:UIImageView!
    @IBOutlet weak var companyPhone:UIButton!
    @IBOutlet weak var companyEmail:UIButton!
    
    @IBOutlet weak var tableView:UITableView!
    
    //@IBOutlet weak var topBarview:UIView!
    
    let api = WebApi.sharedInstance
    var promos = [Promo]()
    var products = [Product]()

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //topBarview.layer.shadowColor = UIColor.blackColor().CGColor
        //topBarview.layer.shadowOpacity = 0.6
        //topBarview.layer.shadowOffset = CGSizeMake(0, 2)

        if isFromSearch {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.tableView.alpha = 0
        
        let nib = UINib(nibName: "PioHeader", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "PioHeader")
        
        
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if company == nil {
            company = WebApi.sharedInstance.getCompanyData(companyId)
        }
        
        UIView.animateWithDuration(0.15) { 
            self.tableView.alpha = 1
        }
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = companyImage.bounds
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0).CGColor, UIColor.blackColor().CGColor]
        companyImage.layer.insertSublayer(gradient, atIndex: 0)
        
        companyName.text = company.brandName
        companyDesc.text = company.description
        //companyPhone.setTitle("tel: "+company.phone, forState: .Normal)
        //companyEmail.setTitle("email: "+company.email, forState: .Normal)
        
        print("COMPANY IMAGE: "+company.image)
        
        WebApi.sharedInstance.downloadedFrom(companyImage, link: company.image, mode: .ScaleAspectFill, shadow: false)
        companyImage.layer.shadowColor = UIColor.blackColor().CGColor
        companyImage.layer.shadowOffset = CGSizeMake(1, 1)
        companyImage.layer.shadowOpacity = 1
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.promos = api.getCompanyAds(company.cid)
        self.products = api.getCompanyProducts(company.cid)
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func contactCompany(sender: UIButton) {
        if sender.tag == 1 {
            let url = NSURL(string: "tel://\(company.phone)")
            UIApplication.sharedApplication().openURL(url!)
        } else {
            let url = NSURL(string: "mailto:\(company.email)")
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Here, we use NSFetchedResultsController
        // And we simply use the section name as title
        
        var title = ""
        
        if section == 0 {
            title = "Promozioni"
        } else {
            title = "Prodotti"
        }
        
        
        // Dequeue with the reuse identifier
        let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("PioHeader")
        let header = cell as! PioHeader
        header.titleLabel.text = title
        
        //header.bgView.backgroundColor = Color.primary
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return promos.count
        } else {
            return products.count
        }
    }
    
    var selectedProduct:Product!
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("didSelectRowAtIndexPath...")
        
        if indexPath.section == 0 {
            selectedPromo = promos[indexPath.row]
            self.performSegueWithIdentifier("showAdFromCompany", sender: self)
        } else {
            print("Selected product...")
            
            
            selectedProduct = self.products[indexPath.row]
            self.performSegueWithIdentifier("showProductDetail", sender: self)
            
            
        }
    }
    
    
    
    
    /*
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        headerView.backgroundColor = Color.primaryDark.colorWithAlphaComponent(0.9)
        
        let label = UILabel(frame: CGRectMake(8,4,400,20))
        label.font = UIFont(name: "Futura", size: 15.0)
        label.textColor = UIColor.whiteColor()
        if section == 0 {
            label.text = "Promozioni (\(self.promos.count))"
        } else {
            label.text = "Prodotti (\(self.products.count))"
        }
        
        headerView.addSubview(label)
        return headerView
    }
    */
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            var cell: PromoViewCell!
            
            
            cell = tableView.dequeueReusableCellWithIdentifier("promoViewCell", forIndexPath: indexPath) as! PromoViewCell
            
            
            let promo = promos[indexPath.row]
            
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
            api.downloadedFrom(cell.pimage, link: imagePath, mode: .ScaleAspectFill, shadow: false)
            cell.pimage.alpha = 0
            
            
            
            cell.likeButton.addTarget(self, action: #selector(likeAd), forControlEvents: .TouchUpInside)
            
            
            return cell
        } else {
            
            var cell: ProductCellView!
            
            
            cell = tableView.dequeueReusableCellWithIdentifier("productViewCell", forIndexPath: indexPath) as! ProductCellView
            
            
            let product = products[indexPath.row]
            
            api.downloadedFrom(cell.pimage, link: "http://www.pioalert.com"+product.image, mode: .ScaleAspectFill, shadow: false)
            cell.pimage.alpha = 0
            
            cell.name.text = product.name
            cell.desc.text = product.descShort
            cell.price.text = "€"+product.price
            
            if product.initialPrice != "0" {
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "€"+product.initialPrice)
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                cell.initialPrice.attributedText = attributeString
            } else {
                cell.initialPrice.hidden = true
            }
            
            print(product.name+" > "+product.image)
            
            return cell
            
        }
        
        
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 339.0
        } else {
            return 100.0
        }
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
        
        self.tableView.reloadData()
        
    }
    
    var selectedPromo:Promo!
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAdFromCompany" {
            let vc = segue.destinationViewController as! PromoDetailController
            vc.selectedPromo = self.selectedPromo
        }
        else if segue.identifier == "showProductDetail" {
            let vc = segue.destinationViewController as! ProductDetailController
            vc.selectedProduct = self.selectedProduct
            vc.prodId = selectedProduct.pid
            //selectedProduct.debugPrint()
            
            vc.companyName = company.brandName
        }
        
    }
    
    

}

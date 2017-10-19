//
//  CompanyTableViewCell.swift
//  PioAlert
//
//  Created by LiveLife on 04/05/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class CompanyTableViewCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var companyName: UILabel!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var companyImageView: UIImageView!
    @IBOutlet var container:UIView!
    @IBOutlet var pointer:UIImageView!
    
    var results = [String:AnyObject]()
    var prodResults = [[String:AnyObject]]()
    var homeController:HomeController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setResults(res: [String:AnyObject]) {
        results = res
    }

    func setProdResults(res: [[String:AnyObject]], hc: HomeController) {
        prodResults = res
        homeController = hc
        collectionView.reloadData()
    }
    
    @IBAction func showCompany(sender: UIButton) {
        
        homeController.performSegue(withIdentifier: "showCompanyFromHome", sender: homeController)
    }
    

}

extension CompanyTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return prodResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let r = prodResults[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCollectionViewCell", for: indexPath) as! CompanyCollectionViewCell
        
        
        //print(r)
        cell.titleLabel.text = r["title"] as? String
        cell.priceLabel.text = r["subititle"] as? String
        let imgPath = r["img"] as? String
        let opt = "http://pioalert.com/imgDelivery/?i="+imgPath!+"&w=260"
        WebApi.sharedInstance.downloadedFrom(cell.imageView, link: opt, mode: .scaleAspectFill, shadow: true)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let p = prodResults[indexPath.row]
        let pid = p["id"] as! String
        homeController.showProduct(pid: pid)
        
    }
    
    /*
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
     let r = results[indexPath.row]
     let type = r["type"] as! String
     
     if type == "ad" {
     return CGSize(width: 231, height: 184)
     } else {
     return CGSize(width: 130, height: 184)
     }
     
     }
     */
}

//
//  MapTableViewCell.swift
//  PioAlert
//
//  Created by LiveLife on 03/05/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var container: UIView!
    
    var results = [[String:AnyObject]]()
    var homeController:HomeController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func setResults(res: [[String:AnyObject]], hc: HomeController) {
        results = res
        homeController = hc
        collectionView.reloadData()
    }
    

}


extension MapTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let r = results[indexPath.row]
        let type = r["type"] as! String
        
        if type == "ad" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromoCollectionCell", for: indexPath) as! PromoCollectionCell
            
            cell.titleLabel.text = r["title"] as? String
            cell.subtitleLabel.text = r["distanceHuman"] as? String
            let imgPath = r["img"] as? String
            let opt = "http://pioalert.com/imgDelivery/?i="+imgPath!+"&w=462"
            WebApi.sharedInstance.downloadedFrom(cell.imageView, link: opt, mode: .scaleAspectFit, shadow: true)
            return cell
        }
        else if type == "com" {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCollectionCell", for: indexPath) as! PromoCollectionCell
            
            cell.titleLabel.text = r["title"] as? String
            cell.subtitleLabel.text = r["distanceHuman"] as? String
            let imgPath = r["img"] as? String
            let opt = "http://pioalert.com/imgDelivery/?i="+imgPath!+"&w=1024"
            WebApi.sharedInstance.downloadedFrom(cell.imageView, link: opt, mode: .scaleAspectFit, shadow: true)
            return cell
            
        }
        else  {
            
            // prd type
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCollectionCell", for: indexPath) as! PromoCollectionCell
            
            cell.titleLabel.text = r["title"] as? String
            cell.subtitleLabel.text = r["subititle"] as? String
            let imgPath = r["img"] as? String
            let opt = "http://pioalert.com/imgDelivery/?i="+imgPath!+"&w=1024"
            WebApi.sharedInstance.downloadedFrom(cell.imageView, link: opt, mode: .scaleAspectFit, shadow: true)
            return cell
            
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let r = results[indexPath.row]
        let type = r["type"] as! String
        let pid = r["id"] as! String
        
        if type == "ad" {
            homeController.showPromo(pid: pid)
        }
        else if type == "prd" {
            homeController.showProduct(pid: pid)
        }
        else if type == "com" {
            homeController.showCompany(cid: pid)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let r = results[indexPath.row]
        let type = r["type"] as! String
        
        if type == "ad" {
            return CGSize(width: 231, height: 184)
        } else {
            return CGSize(width: 130, height: 184)
        }
        
    }
}

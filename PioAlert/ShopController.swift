//
//  ShopController.swift
//  PioAlert
//
//  Created by LiveLife on 18/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class ShopController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var content = [Company]()
    var catContent = [Category]()
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var catCollection:UICollectionView!
    var page = 1
    var selectedCat = "0"
    var isFelix = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        catCollection.delegate = self
        catCollection.dataSource = self
        
        catCollection.layer.shadowColor = UIColor.black.cgColor
        catCollection.layer.shadowOffset = CGSize(width: 0, height: 1)
        catCollection.layer.shadowOpacity = 0.4
        
        let flowLayout = catCollection.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.estimatedItemSize = CGSize(width: 180, height: 60)
        
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = UIRefreshControl()
            self.tableView.refreshControl?.tintColor = Color.accent
            self.tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        } else {
            // Fallback on earlier versions
        }
        
        
        // Do any additional setup after loading the view.
        content = WebApi.sharedInstance.companies(page, filter: selectedCat, isFelix: isFelix)
        tableView.reloadData()
    }
    
    @IBAction func toggleMenu(sender: UIButton) {
        Utility.sharedInstance.homeController.togglePioMenu()
    }
    
    @IBAction func dismissShops(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        page = 1
        //content.removeAll()
        content = WebApi.sharedInstance.companies(page, filter: selectedCat, isFelix: isFelix)
        tableView.reloadData()
        
        refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        catContent = WebApi.sharedInstance.getAllFilterCategories()
        catCollection.reloadData()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    
    var footerLabel:UILabel?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ProductCellView!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "productViewCell", for: indexPath) as! ProductCellView
        
        let company = content[indexPath.row] as Company
        
        
        cell.container.layer.cornerRadius = 3
        cell.container.layer.shadowColor = UIColor.black.cgColor
        cell.container.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.container.layer.shadowOpacity = 0.2
        
        
        WebApi.sharedInstance.downloadedFrom(cell.pimage, link: "http://www.pioalert.com"+company.image, mode: .scaleAspectFill, shadow: false)
        cell.pimage.alpha = 0
        
        cell.name.text = company.brandName
        cell.desc.text = company.description
        cell.price.text = "a "+company.locations[0].distanceHuman+" da te"
        
        return cell
    }
    
    var selectedCompany:Company!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCompany = content[indexPath.row] as Company
        if isFelix {
            self.performSegue(withIdentifier: "showCompanyFromFelix", sender: self)
        } else {
            self.performSegue(withIdentifier: "showCompany", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCompany" {
            let vc = segue.destination as! ShopViewController
            vc.company = selectedCompany
        } else {
            let vc = segue.destination as! ShopViewController
            vc.company = selectedCompany
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            
            
            DispatchQueue.main.async {
                self.page+=1
                let newContent = WebApi.sharedInstance.companies(self.page, filter: self.selectedCat, isFelix: self.isFelix)
                if newContent.count > 0 {
                    self.content.append(contentsOf: newContent)
                    self.tableView.reloadData()
                } else {
                    self.page-=1
                }
            }
            
        }
    }
    
}

extension ShopController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cat = catContent[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catCell", for: indexPath) as! CatCell
        
        cell.title.text = cat.name
        
        if cat.selected {
            cell.checkBar.alpha = 1
        } else {
            cell.checkBar.alpha = 0
        }
        
        if cat.cid == -1 {
            cell.image.image = UIImage(named: "star")
        }
        else if cat.cid == 0 {
            cell.image.image = UIImage(named: "star")
        } else {
            WebApi.sharedInstance.downloadedFrom(cell.image, link: cat.icon!, mode: .scaleAspectFit, shadow: false)
        }
        
        return cell
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let clickedIndex = imageNames[indexPath.row]
        //print(clickedIndex)
        
        let cat = catContent[indexPath.row]
        
        for c in catContent {
            if c.cid == cat.cid {
                c.selected = true
            } else {
                c.selected = false
            }
        }
        
        collectionView.reloadData()
        selectedCat = String(cat.cid)
        page = 1
        
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated:true)
        content = WebApi.sharedInstance.companies(page, filter: selectedCat, isFelix: isFelix)
        tableView.reloadData()
        
        
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

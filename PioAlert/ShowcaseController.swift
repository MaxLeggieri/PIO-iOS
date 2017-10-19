//
//  ShowcaseController.swift
//  PioAlert
//
//  Created by LiveLife on 18/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class ShowcaseController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var content = [Product]()
    var catContent = [Category]()
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var catCollection:UICollectionView!
    var page = 1
    var selectedCat = "0"
    
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
        content = WebApi.sharedInstance.productsByCats(selectedCat,page: page)
        tableView.reloadData()
    }
    
    @IBAction func toggleMenu(sender: UIButton) {
        Utility.sharedInstance.homeController.togglePioMenu()
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        page = 1
        //content.removeAll()
        content = WebApi.sharedInstance.productsByCats(selectedCat,page: page)
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
        
        let product = content[indexPath.row] as Product
        
        
        cell.container.layer.cornerRadius = 3
        cell.container.layer.shadowColor = UIColor.black.cgColor
        cell.container.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.container.layer.shadowOpacity = 0.2
        
        
        WebApi.sharedInstance.downloadedFrom(cell.pimage, link: "http://www.pioalert.com"+product.image, mode: .scaleAspectFill, shadow: false)
        cell.pimage.alpha = 0
        
        cell.name.text = product.name
        cell.desc.text = product.descShort
        cell.price.text = "€ "+product.price
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "€ "+product.initialPrice)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        cell.initialPrice.attributedText = attributeString
        
        if product.initialPrice == "0" {
            cell.initialPrice.isHidden = true
        } else {
            cell.initialPrice.isHidden = false
        }
        
        return cell
    }
    
    var selectedProduct:Product!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedProduct = content[indexPath.row] as Product
        performSegue(withIdentifier: "showProduct", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showProduct" {
            let vc = segue.destination as! ProductViewController
            vc.product = WebApi.sharedInstance.getProductById(String(selectedProduct.pid))//selectedProduct
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            
            
            DispatchQueue.main.async {
                self.page+=1
                let newContent = WebApi.sharedInstance.productsByCats(self.selectedCat,page: self.page)
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

extension ShowcaseController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        content = WebApi.sharedInstance.productsByCats(selectedCat,page: page)
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

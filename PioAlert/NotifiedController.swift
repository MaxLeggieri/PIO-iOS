//
//  NotifiedController.swift
//  PioAlert
//
//  Created by LiveLife on 18/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class NotifiedController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var content = [Promo]()
    @IBOutlet weak var tableView:UITableView!
    var selectedCat = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tabBarController?.tabBar.items?.last?.badgeValue = nil
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = UIRefreshControl()
            self.tableView.refreshControl?.tintColor = Color.accent
            self.tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
        content = WebApi.sharedInstance.getUserNotified()
        tableView.reloadData()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    @IBAction func toggleMenu(sender: UIButton) {
        Utility.sharedInstance.homeController.togglePioMenu()
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        content = WebApi.sharedInstance.getUserNotified()
        tableView.reloadData()
        
        refreshControl.endRefreshing()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ProductCellView!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "productViewCell", for: indexPath) as! ProductCellView
        
        let promo = content[indexPath.row] as Promo
        
        cell.container.layer.cornerRadius = 3
        cell.container.layer.shadowColor = UIColor.black.cgColor
        cell.container.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.container.layer.shadowOpacity = 0.2
        
        let imgPath = "http://pioalert.com/imgDelivery/?i="+promo.imagePath+"&w=250";
        WebApi.sharedInstance.downloadedFrom(cell.pimage, link: imgPath, mode: .scaleAspectFill, shadow: false)
        cell.pimage.alpha = 0
        
        cell.desc.text = promo.title
        cell.price.text = "a "+promo.distanceHuman+" da te"
        
        return cell
    }
    
    var selectedPromo:Promo!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPromo = content[indexPath.row]
        
        if selectedPromo.type == "news" {
            self.performSegue(withIdentifier: "showNewsFromNotified", sender: self)
        } else {
            self.performSegue(withIdentifier: "showPromoFromNotified", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPromoFromNotified" {
            let vc = segue.destination as! PromoViewController
            vc.promoId = selectedPromo.promoId
        }
        if segue.identifier == "showNewsFromNotified" {
            let vc = segue.destination as! NewsController
            vc.promo = selectedPromo
        }
    }
    
    
    
    
}

//
//  OrderAllController.swift
//  PioAlert
//
//  Created by LiveLife on 30/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class OrderAllController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var orders = [Order]()
    var selectedOrder:Order!
    
    @IBOutlet var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func close() {
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.orders = WebApi.sharedInstance.orders()
        if orders.count == 0 {
            self.tableView.isHidden = true
        } else {
            self.tableView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! ProductCellView
        
        let ord = orders[indexPath.row]
        
        cell.name.text = ord.brandname
        
        let status = Utility.sharedInstance.getOrderStatus(ord, time: Int(NSDate().timeIntervalSince1970))
        var text = ""
        switch status {
        case 1:
            text = "Ordine spedito"
        case 2:
            text = "Ritirato dal corriere"
        case 3:
            text = "In consegna"
        case 4:
            text = "Consegnato"
        default:
            break
        }
        cell.initialPrice.text = text
        
        var objs = ""
        if ord.products.count == 1 {
            objs = "1 oggetto"
        } else {
            objs = String(ord.products.count)+" oggetti"
        }
        cell.desc.text = objs
        
        cell.price.text = "€ "+ord.total
        //"\(ord.products.count) oggetti - €\(ord.total)"
        
        WebApi.sharedInstance.downloadedFrom(cell.pimage, link: "http://www.pioalert.com"+ord.brandlogo, mode: .scaleAspectFit, shadow: false, border: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOrder = orders[indexPath.row]
        self.performSegue(withIdentifier: "showOrderDetail", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOrderDetail" {
            
            
            let controller = segue.destination as! OrderController
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            controller.order = self.selectedOrder
            
        }
    }
    
    

}

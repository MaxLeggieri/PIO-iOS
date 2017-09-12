//
//  ShippingController.swift
//  PioAlert
//
//  Created by LiveLife on 24/10/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class ShippingController: UITableViewController {

    
    @IBOutlet weak var name:UITextField!
    @IBOutlet weak var surname:UITextField!
    @IBOutlet weak var address:UITextField!
    @IBOutlet weak var postalCode:UITextField!
    @IBOutlet weak var city:UITextField!
    @IBOutlet weak var area:UITextField!
    @IBOutlet weak var phone:UITextField!
    @IBOutlet weak var confirmButton:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ShippingController.cancelAction))
        
        //self.navigationItem.title = "Modifica indirizzo"
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let userAddress = WebApi.sharedInstance.shippingAddressGet()
        
        
        
        if let add = userAddress["address"] as? String {
            name.text = userAddress["first_name"] as? String
            surname.text = userAddress["last_name"] as? String
            address.text = add
            city.text = userAddress["town"] as? String
            postalCode.text = userAddress["zip"] as? String
            area.text = userAddress["province"] as? String
            phone.text = userAddress["tel"] as? String
        } else {
            print("No data for user...")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissShipping(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateShippingAddress() {
        
        
        var data = [String:String]()
        data["first_name"] = name.text
        data["last_name"] = surname.text
        data["address"] = address.text
        data["town"] = city.text
        data["zip"] = postalCode.text
        data["province"] = area.text
        data["tel"] = phone.text
        
        WebApi.sharedInstance.shippingAddressChange(data)
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Lato-Medium", size: 14)
    }
    

}

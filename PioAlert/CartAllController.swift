//
//  CartAllController.swift
//  PioAlert
//
//  Created by LiveLife on 28/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class CartAllController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView:UITableView!

    var carts:[Cart]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        carts = WebApi.sharedInstance.basketShowAll()
        tableView.reloadData()
    }

    @IBAction func dismissCarts(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: ProductCellView!
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "productViewCell", for: indexPath) as! ProductCellView
        
        let cart = carts[indexPath.row]
        
        cell.name.text = cart.companyName
        cell.desc.text = String(cart.products.count)+" oggetti"
        cell.price.text = Utility.sharedInstance.formatPrice(price: cart.subTotal+cart.shippingTotal)
        
        WebApi.sharedInstance.downloadedFrom(cell.pimage, link: "https://www.pioalert.com"+cart.companyLogo, mode: .scaleAspectFit, shadow: false)
        
        cell.container.layer.cornerRadius = 3
        cell.container.layer.shadowColor = UIColor.black.cgColor
        cell.container.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell.container.layer.shadowOpacity = 0.3
        
        
        return cell
        
    }
    
    var selectedCart:Cart!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCart = carts[indexPath.row]
        self.performSegue(withIdentifier: "showCartFromList", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCartFromList" {
            let vc = segue.destination as! CartViewController
            vc.comId = selectedCart.companyId
        }
    }

}

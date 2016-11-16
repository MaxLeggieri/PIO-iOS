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
    @IBOutlet weak var confirmButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(ShippingController.cancelAction))
        
        self.navigationItem.title = "Modifica indirizzo"
        
        if NSUserDefaults.standardUserDefaults().boolForKey("gotShippingAddress") {
            name.text = NSUserDefaults.standardUserDefaults().stringForKey("shippingName")
            surname.text = NSUserDefaults.standardUserDefaults().stringForKey("shippingSurname")
            address.text = NSUserDefaults.standardUserDefaults().stringForKey("shippingAddress")
            postalCode.text = NSUserDefaults.standardUserDefaults().stringForKey("shippingPostalCode")
            city.text = NSUserDefaults.standardUserDefaults().stringForKey("shippingCity")
            area.text = NSUserDefaults.standardUserDefaults().stringForKey("shippingArea")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cancelAction() {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func updateShippingAddress() {
        
        NSUserDefaults.standardUserDefaults().setValue(name.text, forKey: "shippingName")
        NSUserDefaults.standardUserDefaults().setValue(surname.text, forKey: "shippingSurname")
        NSUserDefaults.standardUserDefaults().setValue(address.text, forKey: "shippingAddress")
        NSUserDefaults.standardUserDefaults().setValue(postalCode.text, forKey: "shippingPostalCode")
        NSUserDefaults.standardUserDefaults().setValue(city.text, forKey: "shippingCity")
        NSUserDefaults.standardUserDefaults().setValue(area.text, forKey: "shippingArea")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "gotShippingAddress")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        
        // ERRORE PioAlert.PromoDetailController...
        
        //let controller = self.presentingViewController as! CartController
        //controller.checkShipping()
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        
        view.backgroundColor = UIColor.whiteColor()
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

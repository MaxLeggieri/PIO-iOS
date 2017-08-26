//
//  MainMenuController.swift
//  PioAlert
//
//  Created by LiveLife on 19/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class MainMenuController: UITableViewController {

    
    let menu = [
            ["I miei interessi","Carrelli","Ordini","Classifica","Aziende Felix"],
            ["Esci","Info"]
    ]
    
    
    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var userWelcomeLabel:UILabel!
    @IBOutlet weak var userPointsLabel:UILabel!
    
    var homeController:HomeController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOpacity = 0.3
        self.view.layer.shadowOffset = CGSize(width: 2, height: 0)
        
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.layer.borderColor = UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1).cgColor
        self.userImage.layer.borderWidth = 1
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cont = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 28))
        cont.backgroundColor = UIColor.clear
        
        let v = UIView(frame: CGRect(x: 15, y: 12, width: self.view.frame.size.width-30, height: 3))
        v.backgroundColor = UIColor(red: 0.784, green: 0.784, blue: 0.784, alpha: 1)
        
        cont.addSubview(v)
        
        return cont
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return menu.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menu[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)

        cell.textLabel?.text = menu[indexPath.section][indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "showProfileFromMenu", sender: self)
            }
            else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "showAllCarts", sender: self)
            }
            else if indexPath.row == 2 {
                self.performSegue(withIdentifier: "showOrdersFromMenu", sender: self)
            }
            else if indexPath.row == 3 {
                self.performSegue(withIdentifier: "showRankingFromMenu", sender: self)
            }
            else if indexPath.row == 4 {
                self.performSegue(withIdentifier: "showFelixCompanies", sender: self)
            }
            
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                homeController.togglePioMenu()
                PioUser.sharedUser.setLogged(false)
                homeController.checkUserStatus()
            }
            else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "showInfoFromMenu", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFelixCompanies" {
            let vc = segue.destination as! ShopController
            vc.isFelix = true
        }
        else if segue.identifier == "showProfileFromMenu" {
            let vc = segue.destination as! ProfileController
            vc.homeController = homeController
        }
    }
    
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

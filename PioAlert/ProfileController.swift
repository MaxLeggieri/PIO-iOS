//
//  ProfileController.swift
//  PioAlert
//
//  Created by LiveLife on 26/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class ProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var topBarView:UIView!
    @IBOutlet weak var doneButton:UIButton!
    
    var allCat = [Category]()
    var selectedCat = [Int]()
    
    var homeController:HomeController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBarView.layer.shadowColor = UIColor.black.cgColor
        topBarView.layer.shadowOpacity = 0.4
        topBarView.layer.shadowRadius = 5
        topBarView.layer.shadowOffset = CGSize(width: 0, height: 2)

        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        allCat = WebApi.sharedInstance.getAllCategories()
        selectedCat = PioUser.sharedUser.userCat
        checkCat()
        
        tableView.reloadData()
    }
    
    func checkCat() {
        if selectedCat.count > 0 {
            doneButton.setTitle("FATTO", for: UIControlState())
        } else {
            doneButton.setTitle("SCEGLI QUANTO TI PARE", for: UIControlState())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        let cat = allCat[indexPath.row]
        
        if selectedCat.contains(cat.cid) {
            cell.catContainer.backgroundColor = UIColor.bt_color(fromHex: "0xfceec0", alpha: 1)
        } else {
            cell.catContainer.backgroundColor = UIColor.white
        }
        
        cell.catNameLabel.text = cat.name
        WebApi.sharedInstance.downloadedFrom(cell.catImageView, link: cat.icon!, mode: .scaleAspectFit, shadow: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cat = allCat[indexPath.row]
        if !selectedCat.contains(cat.cid) {
            selectedCat.append(cat.cid)
        } else {
            let index = selectedCat.index(of: cat.cid)
            selectedCat.remove(at: index!)
        }
        
        tableView.reloadData()
        
        checkCat()
    }
    
    @IBAction func done(_ sender: UIButton) {
        if selectedCat.count > 0 {
            
            let needsRefresh = PioUser.sharedUser.profiled
            PioUser.sharedUser.setProfiled(true)
            PioUser.sharedUser.setUserCat(selectedCat)
            
            let cats = selectedCat.map({"\($0)"}).joined(separator: ",")
            if !WebApi.sharedInstance.setUsersCategories(cats) {
                return
            }
            
            if needsRefresh {
                homeController.startHome()
            }
            
            self.dismiss(animated: true, completion: nil)
        } else {
            doneButton.setTitle("SCEGLI QUALCOSA...", for: UIControlState())
        }
    }

}

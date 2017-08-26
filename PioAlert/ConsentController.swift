//
//  ConsentController.swift
//  PioAlert
//
//  Created by LiveLife on 26/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit



class ConsentController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView:UITableView!
    
    var readGeneral = false
    var readPrivacy = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Lato-Medium", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Consenso ai dati"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrivacyCell", for: indexPath) as! PrivacyCell
        
        return cell
        
        
        
    }
    
    @IBAction func done(_ sender: UIButton) {
        tableView.reloadData()
        
        
        if PioUser.sharedUser.readPrivacy && PioUser.sharedUser.readGeneral {
            PioUser.sharedUser.setGeneralConsent(true)
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Attenzione", message: "Devi spuntare i campi obbligatori per proseguire.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Capito", style: .default) { action in
                // perhaps use action.title here
            })
            self.present(alert, animated: true)
        }
    }

}

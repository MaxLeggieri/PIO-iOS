//
//  CompanyLoginViewController.swift
//  PioAlert
//
//  Created by Suresh on 16/10/17.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class CompanyLoginViewController: UIViewController , WebApiDelegate{

    @IBOutlet weak var usernameTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Enter username", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        
    }
    
    @IBAction func loginButtonAction(_ sender: AnyObject) {
       
        if usernameTextField.text != nil && passwordTextField.text != nil {
            WebApi.sharedInstance.companyLogin(usernameTextField.text!, password: passwordTextField.text!)

        }
        PioUser.sharedUser.setCompanyLogged(true)
        self.performSegue(withIdentifier: "showCompanyLoginToCreateAD", sender: self)

    }
    
    func didSendApiMethod(_ method: String, result: String) {
        if (method == "login") {
            
            print("Sent method: "+method)
            
            PioUser.sharedUser.setCompanyLogged(true)
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    func errorSendingApiMethod(_ method: String, error: String) {
        
        print("Error sending method: "+method)
        
        if (method == "login") {
            
            PioUser.sharedUser.setCompanyLogged(false)
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


//
//  CompanyLoginViewController.swift
//  PioAlert
//
//  Created by Suresh on 16/10/17.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class CompanyLoginViewController: UIViewController , WebApiDelegate, UITextFieldDelegate{

    @IBOutlet weak var usernameTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    @IBOutlet weak var linkLabel:UILabel!

    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Enter username", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        WebApi.sharedInstance.delegate = self
        
        
        let attributedString = NSMutableAttributedString(string: "Fai click qui per saperne di più")
        attributedString.addAttributes([NSForegroundColorAttributeName: UIColor.white], range: NSMakeRange(0, attributedString.length))
        
        attributedString.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, attributedString.length))
        
        attributedString.addAttributes([NSLinkAttributeName: NSURL(string: "https//pioalert.com")!], range: NSMakeRange(0, attributedString.length))
            
        linkLabel.attributedText = attributedString
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // User finished typing (hit return): hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func linkAction(_ sender: AnyObject) {
        let URL = NSURL(string: "https//pioalert.com")! as URL
        UIApplication.shared.openURL(URL)
    }
    
    @IBAction func loginButtonAction(_ sender: AnyObject) {
       
        if usernameTextField.text != nil && passwordTextField.text != nil {
            WebApi.sharedInstance.companyLogin(usernameTextField.text!, password: passwordTextField.text!)

        }
        
    }
    
    func didSendApiMethod(_ method: String, result: String) {
        if (method == "login") {
            
            print("Sent method: "+method)
            
            
            /*
            PioUser.sharedUser.setCompanyLogged(true)
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
             */
            
            PioUser.sharedUser.setCompanyLogged(true)
            
            self.performSegue(withIdentifier: "showCompanyLoginToCreateAD", sender: self)
            
        }
    }
    
    func errorSendingApiMethod(_ method: String, error: String) {
        
        print("Error sending method: "+method)
        
        if (method == "login") {
            
            PioUser.sharedUser.setCompanyLogged(false)
            
            Utility.sharedInstance.showSimpleAlert(title: "Errore", message: "Username o password errati, riprovare.", sender: self)
            
            /*
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
             */
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


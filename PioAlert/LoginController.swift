//
//  LoginController.swift
//  PioAlert
//
//  Created by LiveLife on 26/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import FBSDKLoginKit

class LoginController: UIViewController, WebApiDelegate, GIDSignInUIDelegate, UITextFieldDelegate {

    var fbUserId:String!
    var facebookProfileUrl:String?
    
    @IBOutlet weak var promoCode:UITextField!
    @IBOutlet weak var promoCodeLabel:UILabel!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promoCode.delegate = self
        WebApi.sharedInstance.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if PioUser.sharedUser.codeUsed {
            promoCode.isHidden = true
            promoCodeLabel.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginWithFacebook(_ sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: self, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFacebookInfo()
                    
                }
            } else {
                print(error?.localizedDescription ?? "empty error on loginWithFacebook...")
            }
        })
        
        
    }
    
    func getFacebookInfo() {
        var path = "me"
        
        if fbUserId != nil {
            path = "/\(fbUserId)/"
        }
        
        let fbRequest = FBSDKGraphRequest(graphPath: path, parameters: ["fields": "id,name,email,first_name,last_name,verified,locale,timezone,gender,birthday,location,picture.type(large)"]);
        
        
        
        
        fbRequest?.start(completionHandler: { (connection, result, error) -> Void in
            
            
            if let data = result as? [String:AnyObject] {
                
                if error == nil {
                    
                    self.fbUserId = data["id"] as? String
                    //print("User ID: \(self.fbUserId)")
                    
                    
                    print("User Info : \(String(describing: result))")
                    
                    //WebApi.sharedInstance.userName = data["first_name"] as? String
                    PioUser.sharedUser.setUserName(data["first_name"] as! String)
                    
                    
                    
                    //let picture = data["picture"]?["data"]?["url"] as! String
                    let picture = data["picture"] as! [String:AnyObject]
                    let picturePath = picture["data"]?["url"] as! String
                    //print(picture)
                    
                    self.facebookProfileUrl = picturePath//"http://graph.facebook.com/\(self.fbUserId)/picture?type=large"
                    
                    
                    PioUser.sharedUser.setuserImagePath(picturePath)
                    WebApi.sharedInstance.sendFbUserData(data as AnyObject, code: self.promoCode.text!)
                    
                } else {
                    
                    print("Error Getting Info \(String(describing: error))")
                    
                }
                
                
            }
            
            
            
        
        
        
            
        })
    }
    
    @IBAction func loginWithGoogle(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.code = promoCode.text
        GIDSignIn.sharedInstance().signIn()
    }
    
    func didSendApiMethod(_ method: String, result: String) {
        if (method == "sendFbUserData" || method == "sendGoogleUserData") {
            
            print("Sent method: "+method)
            
            PioUser.sharedUser.setLogged(true)
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    func errorSendingApiMethod(_ method: String, error: String) {
        
        print("Error sending method: "+method)
        
        if (method == "sendFbUserData" || method == "sendGoogleUserData") {
            
            PioUser.sharedUser.setLogged(false)
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}

//
//  webApi.swift
//  MenoPercento
//
//  Created by LiveLife on 22/05/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

/*
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}
*/


protocol WebApiDelegate {
    func didSendApiMethod(_ method: String, result: String)
    func errorSendingApiMethod(_ method: String, error: String)
}

class WebApi {
    
    static let sharedInstance = WebApi()
    
    var selectedFilter = 0 // 0 user  999  all  x catId 
    var allCats = [Category]()
    
    var delegate:WebApiDelegate?
    
    var apiAddress = "http://www.pioalert.com/api/"
    var isLogged = false
    var isProfiled = false
    var isCheckedMissing = false
    var canReceiveNotifications = false
    
    //var allPromo = [Promo]()
    //var allMenuItems = [Category]()
    
    var userName:String?
    var userImagePath:String!
    var userAddress:String!
    
    var notificationToken = ""
    var deviceToken = ""
    var uid = 0
    var loggedWith:Int!
    
    //var liked = [Int]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    func apistart() -> [String:AnyObject] {
        
        var result = [String:AnyObject]()
        
        do {
            
            
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            
            let params = "http://pioalert.com/apistart/?version="+version!+"."+build!+"&os=iOS"
            
            print(params)
            
            let data = getJSON(params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                print(dictionary)
                
                result = dictionary["response"] as! [String:AnyObject]
                
                
                
                return result
                
            }
        } catch {
            print("Error on shippingAddressGet")
            
            if delegate != nil {
                delegate?.errorSendingApiMethod("shippingAddressGet", error: "Error...")
            }
        }
        
        return result
        
    }
    
    
    
    func sendFbUserData(_ fbJson: AnyObject) {
        if !Reachability.isConnectedToNetwork(){
            return
        }
        
        do {
            
            let json = ["method":"sendFbUserData",
                        "device_token":deviceToken,
                        "fbUserData":fbJson] as [String : Any]
            
            print(json)
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            // create post request
            let url = URL(string: apiAddress)!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    print("Error -> \(String(describing: error))")
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                    
                    print("Result -> \(String(describing: result))")
                    
                    let response = result!["response"] as? [String:AnyObject]
                    
                    self.uid = ((response?["uid"] as? NSString)?.integerValue)!
                    UserDefaults.standard.set(self.uid, forKey: "uid")
                    UserDefaults.standard.synchronize()
                    
                    print("UID: "+String(self.uid))
                    
                    
                    self.isLogged = true
                    self.delegate?.didSendApiMethod("sendFbUserData", result: (result?.description)!)
                    
                    
                } catch {
                    
                    self.isLogged = false
                    self.delegate?.errorSendingApiMethod("sendFbUserData", error: "Error on sendFbUserData")
                    print("Error -> \(error)")
                }
            })
            
            task.resume()
            
            
        } catch {
            print(error)
        }
        
    }
    
    func sendGoogleUserData(_ user: GIDGoogleUser) {
        do {
            
            let json = ["method":"sendGoogleUserData",
                        "displayName":user.profile.name,
                        "email":user.profile.email,
                        "id":user.userID,
                        "idToken":user.authentication.idToken,
                        "image":user.profile.imageURL(withDimension: 60).absoluteString,
                        "serverAuthCode":user.authentication.accessToken]
                
            //print(json)
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            // create post request
            let url = URL(string: apiAddress)!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if error != nil{
                    print("Error -> \(String(describing: error))")
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                    
                    
                    
                    
                    let response = result!["response"] as! [String:AnyObject]
                    //print("Result -> \(response)")
                    
                    self.uid = (response["uid"] as! NSString).integerValue
                    UserDefaults.standard.set(self.uid, forKey: "uid")
                    UserDefaults.standard.synchronize()
                    
                    //print("UID: "+String(self.uid))
                    
                    self.isLogged = true
                    self.delegate?.didSendApiMethod("sendGoogleUserData", result: (result?.description)!)
                    
                    
                } catch {
                    
                    self.isLogged = false
                    self.delegate?.errorSendingApiMethod("sendGoogleUserData", error: "Error on sendGoogleUserData")
                    //print("Error -> \(error)")
                }
            })
            
            task.resume()
            
            
        } catch {
            print(error)
        }
    }
    
    func setUsersCategories(_ cats: String) -> Bool {
        
        
        do {
            
            print(cats)
            
            var params = "?method=ucategory_on"
            params += "&device_token="+deviceToken
            params += "&uid="+String(uid)
            params += "&idcat="+cats
            
            
            print("calling: "+apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            
            try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            //print(response)
            delegate?.didSendApiMethod("ucategory_on", result: params)
            
            return true
            
        }
        catch {
            delegate?.errorSendingApiMethod("ucategory_on", error: "Error on setUsersCategories")
            print("Error on setUsersCategories")
        }
        
        return false
    }
    
    func getCategoryAds(_ cat: Int) -> [Promo] {
        
        var catPromos = [Promo]()
        
        
        do {
            
            var params = "?method=getCategoryAds"
            params += "&idcat="+String(cat)
            params += "&uid="+String(uid)
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            params += "&maxdist="+String(UserDefaults.standard.integer(forKey: "maxDistanceFromAds"))
            params += "&format=json"
            params += "&device_token="+deviceToken
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                // JSONObject response = new JSONObject(result).getJSONObject("response");
                // JSONArray data = response.getJSONObject("data").getJSONObject("ads").getJSONArray("d");
                
                //print(dictionary)
                
                
                let response = dictionary["response"]
                let data = response!["data"] as! [String:AnyObject]
                let ads = data["ads"] as? [String:AnyObject]
                let promos = ads!["d"] as? [[String:AnyObject]]
                
                
                
                if (promos == nil) {
                    return [Promo]()
                }
                
                for promo in promos! {
                    
                    let p = createPromoFromJson(promo)
                    catPromos.append(p)
                    
                }
                
                
            }
            
            
        } catch {
            print("Error on getCategoryAds...")
        }
        
        
        
        return catPromos
        
    }
    
    func getUserAds(_ page: Int, filter: String) -> [Promo] {
        
        var catPromos = [Promo]()
        
        
        do {
            
            var params = "?method=ads2user"
            params += "&uid="+String(uid)
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            //params += "&maxdist="+String(UserDefaults.standard.integer(forKey: "maxDistanceFromAds"))
            params += "&catlev=3"
            params += "&device_token="+deviceToken
            params += "&page=\(page)"
            if filter == "-1" {
                params += "&idcategory=all"
            }
            else if filter == "0" {
                params += "&idcategory=0"
            } else {
                params += "&idcategory="+filter
            }
            
            
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            print("calling: "+apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"] as! [String:AnyObject]
                let ads = data["ads"] as? [String:AnyObject]
                let promos = ads!["d"] as? [[String:AnyObject]]
                
                if (promos == nil) {
                    return [Promo]()
                }
                
                for promo in promos! {
                    
                    let p = createPromoFromJson(promo)
                    catPromos.append(p)
                    
                }
                
                
            }
            
            
        } catch {
            print("Error on getCategoryAds...")
        }
        
        
        
        return catPromos
        
    }
    
    func likeAd(_ liked: Bool, idad: Int) {
        
        let method = liked ? "like" : "unlike"
        
        do {
            
            print("notificationToken: "+notificationToken)
            
            var params = "?method="+method
            params += "&uid="+String(uid)
            params += "&idad="+String(idad)
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            //print(response)
            delegate?.didSendApiMethod(method, result: (response as AnyObject).description)
            
            
            
        }
        catch {
            delegate?.errorSendingApiMethod(method, error: "Error on "+method)
            print("Error on tokenHandler")
        }
        
    }
    
    func getUserLiked() -> [Promo] {
        
        var liked = [Promo]()
        
        
        do {
            
            var params = "?method=liked"
            params += "&uid="+String(uid)
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            
            
            //params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"] as! [String:AnyObject]
                let ads = data["ads"] as? [String:AnyObject]
                let promos = ads!["d"] as? [[String:AnyObject]]
                
                if (promos == nil) {
                    return [Promo]()
                }
                
                for promo in promos! {
                    let p = createPromoFromJson(promo)
                    liked.append(p)
                }
                
            }
            
            
        } catch {
            print("Error on getCategoryAds...")
        }
        
        
        
        return liked
        
    }
    
    func getUserNotified() -> [Promo] {
        
        var notified = [Promo]()
        
        
        do {
            
            var params = "?method=adsNotified"
            params += "&uid="+String(uid)
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            params += "&device_token="+deviceToken
            
            
            //params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"] as! [String:AnyObject]
                let ads = data["ads"] as? [String:AnyObject]
                let promos = ads!["d"] as? [[String:AnyObject]]
                
                if (promos == nil) {
                    return [Promo]()
                }
                
                for promo in promos! {
                    let p = createPromoFromJson(promo)
                    notified.append(p)
                }
                
            }
            
            
        } catch {
            print("Error on getUserNotified...")
        }
        
        
        
        return notified
        
    }
    
    func getUsedCoupons() -> [Promo] {
        
        var coupons = [Promo]()
        
        
        do {
            
            var params = "?method=usedCoupon"
            params += "&uid="+String(uid)
            
            
            //params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"] as! [String:AnyObject]
                let ads = data["ads"] as? [String:AnyObject]
                let promos = ads!["d"] as? [[String:AnyObject]]
                
                if (promos == nil) {
                    return [Promo]()
                }
                
                for promo in promos! {
                    let p = createPromoFromJson(promo)
                    coupons.append(p)
                }
                
            }
            
            
        } catch {
            print("Error on usedCoupon...")
        }
        
        
        
        return coupons
        
    }
    
    func tokenHandler() {
        
        
        do {
            
            
            
            
            var params = "?method=tokenHandler"
            params += "&notification_token="+notificationToken
            params += "&device_token="+deviceToken
            
            // Remove!
            //params += "&device_token="+notificationToken
            
            
            params += "&uid="+String(uid)
            params += "&os=ios"
            params += "&dev="+UIDevice.current.modelName+"|"+UIDevice.current.systemVersion
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            //print(response)
            delegate?.didSendApiMethod("tokenHandler", result: (response as AnyObject).description)
            
            
            
        }
        catch {
            delegate?.errorSendingApiMethod("tokenHandler", error: "Error on tokenHandler")
            print("Error on tokenHandler")
        }
        
        
    }
    
    func logout() {
        
        
        do {
            
            var params = "?method=logout"
            params += "&device_token="+deviceToken
            params += "&uid="+String(uid)
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            //print(response)
            delegate?.didSendApiMethod("logout", result: (response as AnyObject).description)
            
            
            
        }
        catch {
            delegate?.errorSendingApiMethod("logout", error: "Error on logout")
            print("Error on logout")
        }
        
        
    }
    
    func useCoupon(_ couponCode: String, idad: Int) {
        do {
            
            var params = "?method=useCoupon"
            //params += "&device_token="+deviceToken!
            params += "&uid="+String(uid)
            params += "&idad="+String(idad)
            params += "&couponcode="+couponCode
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            //print(response)
            delegate?.didSendApiMethod("useCoupon", result: (response as AnyObject).description)
            
            
            
        }
        catch {
            delegate?.errorSendingApiMethod("useCoupon", error: "Error on setUsersCategories")
            print("Error on tokenHandler")
        }
    }
    
    func sendNotificationConfirm(_ notificationData: [AnyHashable: Any]) {
        
        // method=adsId2user&uid=2&ids=110,140,19&timeref=1467979512&lat=42.457093&lng=14.221617&device_token=XXX
        
        do {
            
            var params = "?method=adsId2user"
            params += "&device_token="+deviceToken
            params += "&uid="+String(uid)
            params += "&ids="+String(describing: notificationData["idad"]!)
            params += "&timeref="+String(describing: notificationData["timeref"]!)
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            delegate?.didSendApiMethod("adsId2user", result: (response as AnyObject).description)
            
            
        }
        catch {
            delegate?.errorSendingApiMethod("adsId2user", error: "Error on sendNotificationConfirm")
            print("Error on tokenHandler")
        }
        
    }
    
    func companies(_ page: Int, filter: String, isFelix: Bool) -> [Company] {
        
        var companies = [Company]()
        
        do {
            
            var params = "?method=companies"
            params += "&uid="+String(uid)
            params += "&rec=20"
            params += "&page=\(page)"
            params += "&device_token="+deviceToken
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            if filter == "-1" {
                params += "&idcat=all"
            }
            else if filter == "0" {
                params += "&idcat=favorite"
            } else {
                params += "&idcat="+filter
            }
            
            if isFelix {
                params += "&mode=distance"
                params += "&partner=felix"
            }
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"] as! [String:AnyObject]
                let data = response["data"] as! [String:AnyObject]
                let comps = data["products"] as? [[String:AnyObject]]
                
                if (comps == nil) {
                    return companies
                }
                
                for comp in comps! {
                    
                    let c = Company(json: comp)
                    companies.append(c)
                    
                }
                
            }
        } catch {
            print("Error on companies")
            
            
            
            
        }
        
        return companies
    }
    
    
    func getCompanyData(_ cid: String) -> Company {
        var companies = [Company]()
        
        do {
            
            var params = "?method=companies"
            params += "&uid="+String(uid)
            params += "&rec=1"
            params += "&device_token="+deviceToken
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            params += "&idcom="+cid
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"] as! [String:AnyObject]
                let data = response["data"] as! [String:AnyObject]
                let comps = data["products"] as? [[String:AnyObject]]
                
                
                
                for comp in comps! {
                    
                    let c = Company(json: comp)
                    companies.append(c)
                    
                }
                
                
                
            }
        } catch {
            print("Error on companies")
            
            
            
            
        }
        
        return companies[0]
        
    }
    
    func getCompanyAds(_ cid: Int) -> [Promo] {
        
        var cads = [Promo]()
        
        
        do {
            
            var params = "?method=companyAds"
            params += "&idcom="+String(cid)
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            
            
            //params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"] as! [String:AnyObject]
                
                if let ads = data["ads"] as? [String:AnyObject] {
                    
                    let promos = ads["d"] as? [[String:AnyObject]]
                    for promo in promos! {
                        let p = createPromoFromJson(promo)
                        cads.append(p)
                    }
                    
                }
                
            }
            
            
        } catch {
            print("Error on getCompanyAds...")
        }
        
        
        
        return cads
        
    }
    
    func getCompanyProducts(_ cid: Int) -> [Product] {
        
        var prods = [Product]()
        
        
        do {
            
            var params = "?method=companyProducts"
            params += "&idcom="+String(cid)
            params += "&ord=lastin"
            //params += "&direction=asc"
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"] as! [String:AnyObject]
                let products = data["products"] as? [[String:AnyObject]]
                //let promos = ads!["d"] as? [[String:AnyObject]]
                
                if (products == nil) {
                    return [Product]()
                }
                
                for product in products! {
                    //print(product)
                    let p = createProductFromJson(product)
                    prods.append(p)
                }
                
            }
            
        } catch {
            print("Error on getCompanyAds...")
        }
        
        
        
        return prods
        
    }
    
    func productsByCats(_ filter: String, page: Int) -> [Product] {
        
        var prods = [Product]()
        
        
        do {
            
            var params = "?method=productsByCats"
            params += "&ord=lastin"
            params += "&rec=20"
            params += "&page=\(page)"
            if filter == "-1" {
                params += "&idcats=all"
            }
            else if filter == "0" {
                params += "&idcats=favorite"
            } else {
                params += "&idcats="+filter
            }
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"] as! [String:AnyObject]
                let products = data["products"] as? [[String:AnyObject]]
                //let promos = ads!["d"] as? [[String:AnyObject]]
                
                if (products == nil) {
                    return [Product]()
                }
                
                for product in products! {
                    //print(product)
                    let p = createProductFromJson(product)
                    prods.append(p)
                }
                
            }
            
        } catch {
            print("Error on getCompanyAds...")
        }
        
        
        
        return prods
        
    }
    
    func getAdById(_ idad: String) -> Promo {
        
        var p = Promo(pid: Int(idad)!)
        
        do {
            
            var params = "?method=getAdById"
            params += "&device_token="+deviceToken
            params += "&uid="+String(uid)
            params += "&ids="+idad
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            
            print("calling: "+apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            
            
            let response = dictionary["response"] as! [String:AnyObject]
            let rdata = response["data"] as! [String:AnyObject]
            let ads = rdata["ads"] as? [String:AnyObject]
            let promos = ads!["d"] as? [[String:AnyObject]]
            
            let promo = promos?.first
            p = createPromoFromJson(promo!)
            
            print("PROMO :"+(promo?.description)!)
            
            delegate?.didSendApiMethod("getAdById", result: (dictionary as AnyObject).description)
            
            return p
            
        }
        catch {
            delegate?.errorSendingApiMethod("getAdById", error: "Error on getAdById")
            print("Error on getAdById")
            
        }
        
        return p
        
    }
    
    func getProductById(_ idProd: String) -> Product {
        
        print("getProductById: "+idProd)
        
        var p = Product(pid: Int(idProd)!)
        
        do {
            
            var params = "?method=product"
            params += "&idproduct="+idProd
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            
            print("calling: "+apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            
            
            let response = dictionary["response"]
            let rdata = response?["data"] as! [String:AnyObject]
            let products = rdata["products"] as? [[String:AnyObject]]
            //let products = ads!["d"] as? [[String:AnyObject]]
            
            let prod = products?.first
            p = createProductFromJson(prod!)
            
            delegate?.didSendApiMethod("getProductById", result: (dictionary as AnyObject).description)
            
            return p
            
        }
        catch {
            delegate?.errorSendingApiMethod("getProductById", error: "Error on getProductById")
            print("Error on getProductById")
            
        }
        
        return p
        
    }
    
    func getAllCategories() -> [Category] {
        
        var allCats = [Category]()
        
        
        
        do {
            
            var params = "?method=categories_all"
            
            params += "&device_token="+deviceToken
            
            print("calling: "+apiAddress+params);
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                let categories = response!["data"] as? [[String: AnyObject]]
                
                for cat in categories! {
                    
                    let obj = Category(json: cat)
                    allCats.append(obj)
                    
                }
                
                
                //print(dictionary)
                
            }
        } catch {
            print("Error on getUserData")
            
            
        }
        
        return allCats
    }
    
    func getAllFilterCategories() -> [Category] {
        
        var allCats = [Category]()
        
        let all = Category()
        all.cid = -1
        all.level = 0
        all.name = "Tutte le categorie"
        
        let fav = Category()
        fav.cid = 0
        fav.level = 0
        fav.name = "Mi interessa"
        fav.selected = true
        
        allCats.append(fav)
        allCats.append(all)
        
        do {
            
            var params = "?method=categories_all"
            
            params += "&device_token="+deviceToken
            
            print("calling: "+apiAddress+params);
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                let categories = response!["data"] as? [[String: AnyObject]]
                
                for cat in categories! {
                    
                    let obj = Category(json: cat)
                    allCats.append(obj)
                    
                }
                
                
                //print(dictionary)
                
            }
        } catch {
            print("Error on getUserData")
            
            
        }
        
        return allCats
    }
    
    func claim() -> [String] {
        var claim = [String]()
        
        do {
            
            let params = "?method=claim"
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"] as! [String:AnyObject]
                
                let claimTitle = response["claim"] as! String
                let claimDesc = response["claimText"] as! String
                
                claim.append(claimTitle)
                claim.append(claimDesc)
                
                
                
            }
        } catch {
            print("Error on companies")
            
            
            
            
        }
        
        return claim
        
    }
    
    
    
    // SEARCH
    func search(_ terms: String) -> [Result] {
        
        var allResults = [Result]()
        
        do {
            
            var params = "?method=search"
            params += "&uid="+String(uid)
            params += "&terms="+terms
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                let results = response!["data"] as? [[String: AnyObject]]
                
                if results == nil {
                    return allResults
                }
                
                for result in results! {
                    
                    let obj = Result(json: result)
                    
                    if obj.type == "ad" || obj.type == "product" || obj.type == "company" {
                        allResults.append(obj)
                    }
                    
                }
                
                
                //print(dictionary)
                
            }
        } catch {
            print("Error on search")
        }
        
        return allResults
    }
    
    
    // BEACONS
    func sendBeaconData(_ major: String, minor: String, uuid: String, accuracy: String) {
        
        do {
            
            var params = "?method=sendBeaconData"
            params += "&uid="+String(uid)
            params += "&device_token="+deviceToken
            params += "&idmajor="+major
            params += "&idminor="+minor
            params += "&uuid="+uuid
            params += "&accuracy="+accuracy
            
            
            
            
            
            let data = getJSON(apiAddress+params)
            //print("Sending: "+apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                if delegate != nil {
                    delegate?.didSendApiMethod("sendBeaconData", result: response.debugDescription)
                }
                /*
                 let categories = response!["data"] as? [[String: AnyObject]]
                 
                 for cat in categories! {
                 
                 let obj = Category(json: cat)
                 allCats.append(obj)
                 
                 }
                 */
                
                
                //print(dictionary)
                
            }
        } catch {
            print("Error on basketAddProduct")
            
            
        }
        
        
    }
    
    
    
    // BASKET
    //basketAddProduct
    func basketMove(_ idp: Int, quantity: Int) {
        
        do {
            
            var params = "?method=basketMove"
            
            params += "&uid="+String(uid)
            params += "&idp="+String(idp)
            params += "&device_token="+deviceToken
            params += "&quantity="+String(quantity)
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                if delegate != nil {
                    delegate?.didSendApiMethod("basketMove", result: response.debugDescription)
                }
                
                
            }
        } catch {
            print("Error on basketAddProduct")
            
            
        }
        
        
    }
    
    func basketProductUp(_ idp: Int) {
        
        do {
            
            var params = "?method=basketProductUp"
            
            params += "&uid="+String(uid)
            params += "&idp="+String(idp)
            params += "&device_token="+deviceToken
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                if delegate != nil {
                    delegate?.didSendApiMethod("basketProductUp", result: response.debugDescription)
                }
                
                
            }
        } catch {
            print("Error on basketAddProduct")
            
            
        }
        
        
    }
    
    func basketProductDown(_ idp: Int) {
        
        do {
            
            var params = "?method=basketProductDown"
            
            params += "&uid="+String(uid)
            params += "&idp="+String(idp)
            params += "&device_token="+deviceToken
            
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                if delegate != nil {
                    delegate?.didSendApiMethod("basketProductDown", result: response.debugDescription)
                }
                
                
            }
        } catch {
            print("Error on basketProductDown")
            
            
        }
        
        
    }
    
    func basketShow(_ companyId: Int) -> Cart {
        
        var cart:Cart!
        
        do {
            
            var params = "?method=basketShow"
            
            params += "&uid="+String(uid)
            params += "&idcom="+String(companyId)
            params += "&device_token="+deviceToken
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"] as! [String:AnyObject]
                
                print("basketShow response: "+response.debugDescription)
                
                let contents = response["d"] as! [String:AnyObject]
                
                if let brands = contents["data"] as? [[String:AnyObject]] {
                
                    cart = Cart(json: brands[0])
                    
                } else {
                    return Cart()
                }
                
                if delegate != nil {
                    delegate?.didSendApiMethod("basketShow", result: response.debugDescription)
                }
                
            }
        } catch {
            print("Error on basketShow")
            
            if delegate != nil {
                delegate?.errorSendingApiMethod("basketShow", error: "Error on basketShow")
            }
            
            
        }
        
        return cart
        
        
    }
    
    func basketShowAll() -> [Cart] {
        
        var carts = [Cart]()
        
        do {
            
            var params = "?method=basketShow"
            
            params += "&uid="+String(uid)
            params += "&device_token="+deviceToken
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"] as! [String:AnyObject]
                
                print("basketShow response: "+response.debugDescription)
                
                let contents = response["d"] as! [String:AnyObject]
                
                if let brands = contents["data"] as? [[String:AnyObject]] {
                
                    for brand in brands {
                        let cart = Cart(json: brand)
                        carts.append(cart)
                    }
                    
                }
                
                if delegate != nil {
                    delegate?.didSendApiMethod("basketShow", result: response.debugDescription)
                }
                
                
            }
        } catch {
            print("Error on basketShow")
            
            if delegate != nil {
                delegate?.errorSendingApiMethod("basketShow", error: "Error on basketShowAll")
            }
            
            
        }
        
        return carts
        
        
    }
    
    
    func orders() -> [Order] {
        
        var orders = [Order]()
        
        do {
            
            var params = "?method=orders"
            
            params += "&uid="+String(uid)
            params += "&device_token="+deviceToken
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"] as! [String:AnyObject]
                
                print("orders response: "+response.debugDescription)
                
                let data = response["data"] as! [String:AnyObject]
                let O = data["O"] as! [String:AnyObject]
                
                let totalresults = O["totalresults"] as! Int
                
                if totalresults == 0 {
                    return orders
                }
                
                
                let ords = data["d"] as! [[String:AnyObject]]
                
                
                for ord in ords {
                    let o = Order(json: ord)
                    orders.append(o)
                }
                
                if delegate != nil {
                    delegate?.didSendApiMethod("orders", result: response.debugDescription)
                }
                
                
            }
        } catch {
            print("Error on orders")
            
            if delegate != nil {
                delegate?.errorSendingApiMethod("orders", error: "Error on basketShowAll")
            }
            
            
        }
        
        return orders
        
        
    }
    
    
    func shippingAddressChange(_ data: [String:String]) {
        
        do {
            
            var params = "?method=shippingAddressChange"
            params += "&uid="+String(uid)
            params += "&first_name="+data["first_name"]!
            params += "&last_name="+data["last_name"]!
            params += "&address="+data["address"]!
            params += "&zip="+data["zip"]!
            params += "&town="+data["town"]!
            params += "&province="+data["province"]!
            params += "&tel="+data["tel"]!
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            params += "&device_token="+deviceToken
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                if delegate != nil {
                    delegate?.didSendApiMethod("shippingAddressChange", result: response.debugDescription)
                }
                
            }
        } catch {
            print("Error on shippingAddressChange")
            
            if delegate != nil {
                delegate?.errorSendingApiMethod("shippingAddressChange", error: "Error...")
            }
        }
        
    }
    
    func shippingAddressGet() -> [String:AnyObject] {
        
        var sdata:[String:AnyObject]!
        
        do {
            
            var params = "?method=shippingAddressGet"
            params += "&uid="+String(uid)
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            params += "&device_token="+deviceToken
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                print(dictionary)
                
                let response = dictionary["response"]
                if let d = response!["data"] as? [String:AnyObject] {
                    
                    sdata = d
                    
                } else {
                    sdata = [String:AnyObject]()
                    
                }
                
                
                return sdata
                
            }
        } catch {
            print("Error on shippingAddressGet")
            
            if delegate != nil {
                delegate?.errorSendingApiMethod("shippingAddressGet", error: "Error...")
            }
        }
        
        return sdata
        
    }
    
    
    func basket2emailPrenotation(_ idcom: Int, message: String) -> Bool {
        
        
        do {
            
            var params = "?method=basket2emailPrenotation"
            params += "&uid="+String(uid)
            params += "&idcom="+String(idcom)
            params += "&device_token="+deviceToken
            params += "&msg="+message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if object is [String: AnyObject] {
                
                
                return true
                
            }
            
        } catch  {
            return false
        }
        
        return false
        
    }
    
    /*
    func basketShowAll() -> [Cart] {
        
        var carts = [Cart]()
        
        do {
            
            var params = "?method=basketShow"
            
            params += "&uid="+String(uid)
            params += "&device_token="+deviceToken
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"] as! [String:AnyObject]
                
                print("basketShow response: "+response.debugDescription)
                
                let contents = response["d"] as! [String:AnyObject]
                
                if let brands = contents["data"] as? [[String:AnyObject]] {
                    
                    for brand in brands {
                        let cart = Cart(json: brand)
                        carts.append(cart)
                    }
                    
                }
                
                if delegate != nil {
                    delegate?.didSendApiMethod("basketShow", result: response.debugDescription)
                }
                
                
            }
        } catch {
            print("Error on basketShow")
            
            if delegate != nil {
                delegate?.errorSendingApiMethod("basketShow", error: "Error on basketShowAll")
            }
            
            
        }
        
        return carts
        
        
    }
    */
    
    
    func ranking(limit: Int) -> [PioPlayer] {
        
        var players = [PioPlayer]()
        
        do {
            
            let date = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            
            
            var params = "?method=usersParade"
            params += "&uid="+String(uid)
            params += "&device_token="+deviceToken
            params += "&rec="+String(limit)
            params += "&month="+String(month)
            params += "&year="+String(year)
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                
                let response = dictionary["response"] as! [String:AnyObject]
                let data = response["data"] as! [String:AnyObject]
                let d = data["d"] as! [[String:AnyObject]]
                
                for obj in d {
                    let player = PioPlayer(json: obj)
                    players.append(player)
                }
                //crash
                
                let you = data["you"] as? [String:AnyObject]
                
                PioUser.sharedUser.rankData = you
            }
            
        } catch  {
            if delegate != nil {
                delegate?.errorSendingApiMethod("usersParade", error: "ERROR in usersParade")
            }
        }
        
        return players
        
    }
    
    
    
    
    func home(_ page: Int, searchTerm: String?, idcat: String) -> [String:AnyObject] {
        let empyResult:[String:AnyObject] = [:]
        
        do {
            
            var params = "?method=home"
            params += "&uid="+String(uid)
            params += "&device_token="+deviceToken
            params += "&page="+String(page)
            params += "&lat="+String(PioUser.sharedUser.location.coordinate.latitude)
            params += "&lng="+String(PioUser.sharedUser.location.coordinate.longitude)
            if searchTerm != nil {
                params += "&idcat="+idcat
                params += "&search="+searchTerm!
            } else {
                params += "&idcat=favorite"
            }
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            /*
             params += "&askall=1"
             params += "&device_token="+deviceToken
             */
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"] as! [String:AnyObject]
                //print(response.debugDescription)
                return response
                
            }
            
        } catch  {
            if delegate != nil {
                delegate?.errorSendingApiMethod("signupMissing", error: "ERROR in signupMissing")
            }
        }
        
        return empyResult
    }
    
    func getGooglePlaces() -> [PioPlace] {
        
        var result = [PioPlace]()
        
        do {
            
            //40.379031, 15.539905
            
            var params = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+String(PioUser.sharedUser.location.coordinate.latitude)+","+String(PioUser.sharedUser.location.coordinate.longitude)
            params += "&radius=5000"
            params += "&language=it"
            params += "&type=museum|art_gallery|church"
            params += "&key=AIzaSyDRV45yi1TJZDx3rCNe5S-9qmRy3AtonPI"
            
            
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            
            print(params)
            
            let data = getJSON(params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let results = dictionary["results"] as! [[String:AnyObject]]
                //print(response.debugDescription)
                
                for r in results {
                    let p = PioPlace(json: r)
                    result.append(p)
                }
                
                return result
                
            }
            
        } catch  {
            print("Error on getGooglePlaces...")
        }
        
        return result
        
        
    }
    
    func getPoiDetails(_ pid: String) -> [String:AnyObject] {
        
        let empyResult:[String:AnyObject] = [:]
        
        do {
            
            //40.379031, 15.539905
            
            var params = "https://maps.googleapis.com/maps/api/place/details/json?placeid="+pid
            params += "&language=it"
            params += "&key=AIzaSyDRV45yi1TJZDx3rCNe5S-9qmRy3AtonPI"
            
            
            //params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            
            print(params)
            
            let data = getJSON(params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let result = dictionary["result"] as! [String:AnyObject]
                return result
                
            }
            
        } catch  {
            print("Error on getGooglePlaces...")
        }
        
        return empyResult
        
    }
    
    func createPromoFromJson(_ promo: [String:AnyObject]) -> Promo {
        let idad = Int(promo["idad"] as! String)
        
        let p = Promo(pid: idad!)
        p.brandId = promo["idcom"]?.intValue
        p.desc = promo["description"] as? String
        p.imagePath = promo["image"] as? String
        p.prodName = promo["products"] as? String
        p.prodSpecs = promo["catText"] as? String
        p.title = promo["title"] as? String
        
        p.viewedCount = promo["views"] as? String
        p.brandName = promo["brandname"] as? String
        p.address = promo["address"] as? String
        p.catHuman = promo["catText"] as? String
        p.distanceHuman = promo["distanceHuman"] as? String
        p.youtube = promo["youtube"] as? String
        p.youtubePreview = promo["youtubeImg"] as? String
        p.link = promo["link"] as? String
        p.attachment = promo["attachment"] as? String
        p.cimage = promo["companylogo"] as? String
        p.couponCode = promo["couponcode"] as? String
        p.usedCoupon = promo["usedCoupon"]?.intValue
        
        let date = Date(timeIntervalSince1970: (promo["expiration"]?.doubleValue)!)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MMM YYYY"
        let dateString = dayTimePeriodFormatter.string(from: date)
        p.expirationHuman = dateString
        
        if (promo["interesteduser"]?.intValue)! > 0 {
            p.liked = true
        } else {
            p.liked = false
        }
        
        p.lat = promo["lat"]?.doubleValue
        p.lon = promo["lng"]?.doubleValue
        
        
        
        return p
    }
    
    func createProductFromJson(_ product: [String:AnyObject]) -> Product {
        
        
        let pid = Int(product["idp"] as! String)
        
        let p = Product(pid: pid!)
        
        p.name = product["name"] as? String
        p.idCom = product["idcom"]?.intValue
        p.descShort = product["descriptionShort"] as? String
        p.descLong = product["description"] as? String
        p.price = product["priceSellVatIncluded"] as? String
        p.initialPrice = product["priceOff"] as? String
        p.companyName = product["brandname"] as? String
        p.category = product["catText"] as? String
        p.hashtags = product["hashtags"] as? String
        
        
        
        if p.initialPrice == nil {
            p.initialPrice = "0"
        }
        
        let iniP = Double(p.initialPrice)
        let finP = Double(p.price)
        
        p.priceOff = String(iniP!-finP!)
        
        
        p.priceUnit = product["priceUnit"] as? String
        p.discountPercent = product["scontoPercent"] as? String
        p.image = product["imgpath"] as? String
        p.quantity = product["quantity"]?.intValue
        p.available = product["quantityAvailable"]?.intValue
        
        p.companyEmail = product["where"]?["email"] as? String
        p.companyAddress = product["where"]?["addressloc"] as? String
        
        return p
    }
    
    
    // BRAINTREE
    func getPaypalClientTokenFake() {
        
        let clientTokenURL = URL(string: "http://www.crgs.it/pionear/api.php?method=getPaypalClientToken")!
        var clientTokenRequest = URLRequest(url: clientTokenURL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        
        URLSession.shared.dataTask(with: clientTokenRequest, completionHandler: { (data, response, error) -> Void in
            // TODO: Handle errors
            
            if error == nil {
                let clientToken = String(data: data!, encoding: String.Encoding.utf8)
                
                if self.delegate != nil {
                    self.delegate?.didSendApiMethod("getPaypalClientToken", result: clientToken!)
                }
            } else {
                print("Braintree error: "+error.debugDescription)
            }
            
        }) .resume()
        //return clientToken
    }
    
    func paypalGetClientToken(_ idcom: Int) -> String {
        
        var token = ""
        
        
        do {
            
            var params = "?method=paypalGetClientToken"
            params += "&idcom="+String(idcom)
            params += "&device_token="+deviceToken
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                let res = dictionary["response"] as! [String:AnyObject]
                print(res.debugDescription)
                
                token = res["clientToken"] as! String
                return token
                
            }
            
        } catch  {
            if delegate != nil {
                delegate?.errorSendingApiMethod("paypalGetClientToken", error: "ERROR in paypalGetClientToken")
            }
        }
        
        return token
        
        
    }
    
    let sandbox = false
    
    func getDhlRate(_ idcom: Int) -> [String:AnyObject] {
        var rate = [String:AnyObject]()
        
        
        do {
            
            var params = "?method=getDhlRate"
            params += "&idcom="+String(idcom)
            params += "&uid="+String(uid)
            params += "&device_token="+deviceToken
            
            if sandbox {
                params += "&sandbox=1"
            }
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                rate = dictionary["response"] as! [String:AnyObject]
                print("getDhlRate: "+rate.debugDescription)
                
                return rate
                
            }
            
        } catch  {
            if delegate != nil {
                delegate?.errorSendingApiMethod("getDhlRate", error: "ERROR in getDhlRate")
            }
        }
        
        return rate
    }
    
    func autosuggest(_ string: String) -> [[String:AnyObject]] {
        let result = [[String:AnyObject]]()
        do {
            
            var params = "?method=autosuggest"
            params += "&uid="+String(uid)
            params += "&terms="+string
            params = params.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                guard let response = dictionary["response"] as? [String:AnyObject] else {
                    return result
                }
                
                
                
                return response["data"] as! [[String:AnyObject]]
                
            }
            
        } catch  {
            
        }
        
        return result
    }
    
    func payPalTrans(_ paymentMethodNonce: String, amount: String, rateId: Int, idcom: Int) -> [String:AnyObject] {
        
        var res:[String:AnyObject]!
        
        
        do {
            
            var params = "?method=payPalTrans"
            params += "&uid="+String(uid)
            params += "&payment_method_nonce="+paymentMethodNonce
            params += "&amount="+amount
            params += "&id_rate="+String(rateId)
            params += "&idcom="+String(idcom)
            params += "&device_token="+deviceToken
            
            if sandbox {
                params += "&sandbox=1"
            }
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                res = dictionary["response"] as! [String:AnyObject]
                print(res.debugDescription)
                
                if delegate != nil {
                   delegate?.didSendApiMethod("payPalTrans", result: res.debugDescription)
                }
                
                return res
                
            }
            
        } catch  {
            if delegate != nil {
                delegate?.errorSendingApiMethod("payPalTrans", error: "ERROR in payPalTrans")
            }
        }
        
        return res
        
    }
    
    func sendFakePOST(_ data1: String, data2: String) {
        
        let paymentURL = URL(string: apiAddress)!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "method=paypalGetClientToken&idcom=1&format=json".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            // TODO: Handle success or failure
            
            if error == nil {
                let response = String(data: data!, encoding: String.Encoding.utf8)
                print("postNonceToServer success: "+response!)
            } else {
                print("postNonceToServer error: "+error.debugDescription)
            }
            
            
            }) .resume()
    }
    
    
    
    func checkApiServer() -> Bool {
        
        
        
        
        
        return true
        
    }
    
    func getJSON(_ urlToRequest: String) -> Data {
        
        return (try! Data(contentsOf: URL(string: urlToRequest)!))
    }
    
    func downloadedFrom(_ imageView:UIImageView, link:String, mode: UIViewContentMode, shadow: Bool) {
        
        downloadedFrom(imageView, link: link, mode: mode, shadow: shadow, border: false)
        
        
    }
    
    func downloadedFrom(_ imageView:UIImageView, link:String, mode: UIViewContentMode, shadow: Bool, border: Bool) {
        guard
            let url = URL(string: link)
            else {return}
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    DispatchQueue.main.async { () -> Void in
                        
                        imageView.image = UIImage(named: "pioapp_80_x1")
                        UIView.animate(withDuration: 0.14, animations: {
                            imageView.alpha = 1
                        })
                    }
                    return
                }
            DispatchQueue.main.async { () -> Void in
                
                imageView.image = image
                
                imageView.contentMode = mode
                imageView.clipsToBounds = true
                
                if shadow {
                    //let shadowPath = UIBezierPath(rect: imageView.bounds).CGPath
                    
                    
                    
                    imageView.layer.shadowColor = UIColor.black.cgColor
                    imageView.layer.shadowOpacity = 0.3
                    imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
                    //imageView.layer.shadowPath = shadowPath
                    //imageView.layer.shouldRasterize = true
                    
                    imageView.layer.masksToBounds = false
                    
                }
                
                if border {
                    
                    imageView.layer.borderColor = Color.primary.cgColor
                    imageView.layer.borderWidth = 1
                    
                }
                
                
                UIView.animate(withDuration: 0.14, animations: {
                    imageView.alpha = 1
                    
                })
            }
        }).resume()
    }
    
    
    
    
    
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

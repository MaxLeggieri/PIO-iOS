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


protocol WebApiDelegate {
    func didSendApiMethod(method: String, result: String)
    func errorSendingApiMethod(method: String, error: String)
}

class WebApi {
    
    static let sharedInstance = WebApi()
    
    var delegate:WebApiDelegate?
    
    let apiAddress = "http://www.pioalert.com/api/"
    var isLogged = false
    var isProfiled = false
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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func sendFbUserData(fbJson: AnyObject) {
        
        
        do {
            
            let json = ["method":"sendFbUserData",
                        "device_token":deviceToken,
                        "fbUserData":fbJson]
            
            print(json)
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            
            // create post request
            let url = NSURL(string: apiAddress)!
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = jsonData
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error != nil{
                    print("Error -> \(error)")
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    
                    print("Result -> \(result)")
                    
                    let response = result!["response"]
                    
                    self.uid = response!["uid"]!!.integerValue
                    NSUserDefaults.standardUserDefaults().setInteger(self.uid, forKey: "uid")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    print("UID: "+String(self.uid))
                    
                    
                    self.isLogged = true
                    self.delegate?.didSendApiMethod("sendFbUserData", result: (result?.description)!)
                    
                    
                } catch {
                    
                    self.isLogged = false
                    self.delegate?.errorSendingApiMethod("sendFbUserData", error: "Error on sendFbUserData")
                    print("Error -> \(error)")
                }
            }
            
            task.resume()
            
            
        } catch {
            print(error)
        }
        
    }
    
    func sendGoogleUserData(user: GIDGoogleUser) {
        do {
            
            let json = ["method":"sendGoogleUserData",
                        "displayName":user.profile.name,
                        "email":user.profile.email,
                        "id":user.userID,
                        "idToken":user.authentication.idToken,
                        "image":user.profile.imageURLWithDimension(60).absoluteString,
                        "serverAuthCode":user.authentication.accessToken]
                
            //print(json)
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            
            // create post request
            let url = NSURL(string: apiAddress)!
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = jsonData
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error != nil{
                    print("Error -> \(error)")
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    
                    
                    
                    
                    let response = result!["response"]
                    //print("Result -> \(response)")
                    
                    self.uid = response!["uid"]!!.integerValue
                    NSUserDefaults.standardUserDefaults().setInteger(self.uid, forKey: "uid")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    //print("UID: "+String(self.uid))
                    
                    self.isLogged = true
                    self.delegate?.didSendApiMethod("sendGoogleUserData", result: (result?.description)!)
                    
                    
                } catch {
                    
                    self.isLogged = false
                    self.delegate?.errorSendingApiMethod("sendGoogleUserData", error: "Error on sendGoogleUserData")
                    //print("Error -> \(error)")
                }
            }
            
            task.resume()
            
            
        } catch {
            print(error)
        }
    }
    
    func setUsersCategories(cats: String) -> Bool {
        
        
        do {
            
            print(cats)
            
            var params = "?method=ucategory_on"
            params += "&device_token="+deviceToken
            params += "&uid="+String(uid)
            params += "&idCat="+cats
            
            
            print("calling: "+apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            
            try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
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
    
    func getCategoryAds(cat: Int) -> [Promo] {
        
        var catPromos = [Promo]()
        
        
        do {
            
            var params = "?method=getCategoryAds"
            params += "&idcat="+String(cat)
            params += "&uid="+String(uid)
            params += "&lat="+String(appDelegate.currentLocation!.coordinate.latitude)
            params += "&lng="+String(appDelegate.currentLocation!.coordinate.longitude)
            params += "&maxdist="+String(NSUserDefaults.standardUserDefaults().integerForKey("maxDistanceFromAds"))
            params += "&format=json"
            params += "&device_token="+deviceToken
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                // JSONObject response = new JSONObject(result).getJSONObject("response");
                // JSONArray data = response.getJSONObject("data").getJSONObject("ads").getJSONArray("d");
                
                //print(dictionary)
                
                
                let response = dictionary["response"]
                let data = response!["data"]
                let ads = data!!["ads"] as? [String:AnyObject]
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
    
    func getUserAds() -> [Promo] {
        
        var catPromos = [Promo]()
        
        
        do {
            
            var params = "?method=ads2user"
            params += "&uid="+String(uid)
            params += "&lat="+String(appDelegate.currentLocation!.coordinate.latitude)
            params += "&lng="+String(appDelegate.currentLocation!.coordinate.longitude)
            params += "&maxdist="+String(NSUserDefaults.standardUserDefaults().integerForKey("maxDistanceFromAds"))
            params += "&format=json"
            params += "&catlev=3"
            params += "&device_token="+deviceToken
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                // JSONObject response = new JSONObject(result).getJSONObject("response");
                // JSONArray data = response.getJSONObject("data").getJSONObject("ads").getJSONArray("d");
                
                //print(dictionary)
                
                
                let response = dictionary["response"]
                let data = response!["data"]
                let ads = data!!["ads"] as? [String:AnyObject]
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
    
    func likeAd(liked: Bool, idad: Int) {
        
        let method = liked ? "like" : "unlike"
        
        do {
            
            print("notificationToken: "+notificationToken)
            
            var params = "?method="+method
            params += "&uid="+String(uid)
            params += "&idad="+String(idad)
            params += "&lat="+String(appDelegate.currentLocation!.coordinate.latitude)
            params += "&lng="+String(appDelegate.currentLocation!.coordinate.longitude)
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            //print(response)
            delegate?.didSendApiMethod(method, result: response.description)
            
            
            
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
            params += "&lat="+String(appDelegate.currentLocation!.coordinate.latitude)
            params += "&lng="+String(appDelegate.currentLocation!.coordinate.longitude)
            
            
            //params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"]
                let ads = data!!["ads"] as? [String:AnyObject]
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
            params += "&lat="+String(appDelegate.currentLocation!.coordinate.latitude)
            params += "&lng="+String(appDelegate.currentLocation!.coordinate.longitude)
            params += "&device_token="+deviceToken
            
            
            //params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"]
                let ads = data!!["ads"] as? [String:AnyObject]
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
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"]
                let ads = data!!["ads"] as? [String:AnyObject]
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
    
    func sendDeviceToken() {
        
        
        do {
            
            print("notificationToken: "+notificationToken)
            
            
            
            var params = "?method=tokenHandler"
            params += "&notification_token="+notificationToken
            params += "&device_token="+deviceToken
            
            // Remove!
            //params += "&device_token="+notificationToken
            
            
            params += "&uid="+String(uid)
            params += "&os=ios"
            params += "&dev="+UIDevice.currentDevice().modelName+"|"+UIDevice.currentDevice().systemVersion
            params += "&lat="+String(appDelegate.currentLocation!.coordinate.latitude)
            params += "&lng="+String(appDelegate.currentLocation!.coordinate.longitude)
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            //print(response)
            delegate?.didSendApiMethod("tokenHandler", result: response.description)
            
            
            
        }
        catch {
            delegate?.errorSendingApiMethod("tokenHandler", error: "Error on setUsersCategories")
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
            let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            //print(response)
            delegate?.didSendApiMethod("logout", result: response.description)
            
            
            
        }
        catch {
            delegate?.errorSendingApiMethod("logout", error: "Error on logout")
            print("Error on logout")
        }
        
        
    }
    
    func useCoupon(couponCode: String, idad: Int) {
        do {
            
            var params = "?method=useCoupon"
            //params += "&device_token="+deviceToken!
            params += "&uid="+String(uid)
            params += "&idad="+String(idad)
            params += "&couponcode="+couponCode
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            //print(response)
            delegate?.didSendApiMethod("useCoupon", result: response.description)
            
            
            
        }
        catch {
            delegate?.errorSendingApiMethod("useCoupon", error: "Error on setUsersCategories")
            print("Error on tokenHandler")
        }
    }
    
    func sendNotificationConfirm(notificationData: [NSObject:AnyObject]) {
        
        // method=adsId2user&uid=2&ids=110,140,19&timeref=1467979512&lat=42.457093&lng=14.221617&device_token=XXX
        
        do {
            
            var params = "?method=adsId2user"
            params += "&device_token="+deviceToken
            params += "&uid="+String(uid)
            params += "&ids="+String(notificationData["idad"]!)
            params += "&timeref="+String(notificationData["timeref"]!)
            params += "&lat="+String(appDelegate.currentLocation!.coordinate.latitude)
            params += "&lng="+String(appDelegate.currentLocation!.coordinate.longitude)
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            delegate?.didSendApiMethod("adsId2user", result: response.description)
            
            
        }
        catch {
            delegate?.errorSendingApiMethod("adsId2user", error: "Error on sendNotificationConfirm")
            print("Error on tokenHandler")
        }
        
    }
    
    func getCompanyData(cid: Int) -> Company {
        print("company id: \(cid)")
        let c = Company(cid: cid)
        
        do {
            
            var params = "?method=getCompanyData"
            params += "&idcom="+String(cid)
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            
            print("calling: "+apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            
            let response = dictionary["response"]
            let rdata = response!!["data"]
            
            
            //c.officialName = rdata!!["officialname"]
            c.officialName = rdata!!["officialname"] as! String
            c.brandName = rdata!!["brandname"] as! String
            c.phone = rdata!!["phone"] as! String
            c.email = rdata!!["email"] as! String
            c.image = rdata!!["image"] as! String
            c.description = rdata!!["description"] as! String

            delegate?.didSendApiMethod("getCompanyData", result: dictionary.description)
            
            return c
            
        }
        catch {
            delegate?.errorSendingApiMethod("getCompanyData", error: "Error on getCompanyData")
            print("Error on getCompanyData")
            
        }
        
        return c
        
    }
    
    func getCompanyAds(cid: Int) -> [Promo] {
        
        var cads = [Promo]()
        
        
        do {
            
            var params = "?method=companyAds"
            params += "&idcom="+String(cid)
            params += "&lat="+String(appDelegate.currentLocation!.coordinate.latitude)
            params += "&lng="+String(appDelegate.currentLocation!.coordinate.longitude)
            
            
            //params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"]
                let ads = data!!["ads"] as? [String:AnyObject]
                let promos = ads!["d"] as? [[String:AnyObject]]
                
                if (promos == nil) {
                    return [Promo]()
                }
                
                for promo in promos! {
                    let p = createPromoFromJson(promo)
                    cads.append(p)
                }
                
            }
            
            
        } catch {
            print("Error on getCompanyAds...")
        }
        
        
        
        return cads
        
    }
    
    func getCompanyProducts(cid: Int) -> [Product] {
        
        var prods = [Product]()
        
        
        do {
            
            var params = "?method=companyProducts"
            params += "&idcom="+String(cid)
            params += "&ord=lastin"
            //params += "&direction=asc"
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            print(apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                
                let response = dictionary["response"]
                let data = response!["data"]
                let products = data!!["products"] as? [[String:AnyObject]]
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
    
    func getAdById(idad: String) -> Promo {
        
        var p = Promo(pid: Int(idad)!)
        
        do {
            
            var params = "?method=getAdById"
            params += "&device_token="+deviceToken
            params += "&uid="+String(uid)
            params += "&ids="+idad
            params += "&lat="+String(appDelegate.currentLocation!.coordinate.latitude)
            params += "&lng="+String(appDelegate.currentLocation!.coordinate.longitude)
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            
            print("calling: "+apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            
            let response = dictionary["response"]
            let rdata = response!!["data"]
            let ads = rdata!!["ads"] as? [String:AnyObject]
            let promos = ads!["d"] as? [[String:AnyObject]]
            
            let promo = promos?.first
            p = createPromoFromJson(promo!)
            
            print("PROMO :"+(promo?.description)!)
            
            delegate?.didSendApiMethod("getAdById", result: dictionary.description)
            
            return p
            
        }
        catch {
            delegate?.errorSendingApiMethod("getAdById", error: "Error on getAdById")
            print("Error on getAdById")
            
        }
        
        return p
        
    }
    
    func getProductById(idProd: String) -> Product {
        
        print("getProductById: "+idProd)
        
        var p = Product(pid: Int(idProd)!)
        
        do {
            
            var params = "?method=product"
            params += "&idproduct="+idProd
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            
            print("calling: "+apiAddress+params)
            
            let data = getJSON(apiAddress+params)
            let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            
            let response = dictionary["response"]
            let rdata = response!!["data"]
            let products = rdata!!["products"] as? [[String:AnyObject]]
            //let products = ads!["d"] as? [[String:AnyObject]]
            
            let prod = products?.first
            p = createProductFromJson(prod!)
            
            print("PROMO :"+(prod?.description)!)
            
            delegate?.didSendApiMethod("getProductById", result: dictionary.description)
            
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
            
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
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
    
    
    // SEARCH
    func search(terms: String) -> [Result] {
        
        var allResults = [Result]()
        
        do {
            
            var params = "?method=search"
            params += "&uid="+String(uid)
            params += "&terms="+terms
            
            params = params.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
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
    
    // BASKET
    func basketAddProduct(idp: Int) {
        
        do {
            
            var params = "?method=basketAddProduct"
            
            params += "&uid="+String(uid)
            params += "&idp="+String(idp)
            
            
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                if delegate != nil {
                    delegate?.didSendApiMethod("basketAddProduct", result: response.debugDescription)
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
    
    func basketShow(companyId: Int) -> Cart {
        
        var cart:Cart!
        
        do {
            
            var params = "?method=basketShow"
            
            params += "&uid="+String(uid)
            params += "&idcom="+String(companyId)
            
            
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                let response = dictionary["response"]
                if delegate != nil {
                    delegate?.didSendApiMethod("basketAddProduct", result: response.debugDescription)
                }
                
                let carts = response!["data"] as? [[String: AnyObject]]
                
                cart = Cart(json: carts![0])
                
                
                //print(dictionary)
                
            }
        } catch {
            print("Error on basketAddProduct")
            
            
        }
        
        return cart
        
        
    }
    
    func signupMissing() -> [String:AnyObject] {
        
        let empyResult:[String:AnyObject] = [:]
        
        do {
            
            var params = "?method=signupMissing"
            params += "&uid="+String(uid)
            params += "&askall=1"
            
            let data = getJSON(apiAddress+params)
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let dictionary = object as? [String: AnyObject] {
                
                
                
                let response = dictionary["response"] as! [String:AnyObject]
                print(response.debugDescription)
                return response
                
            }
            
        } catch  {
            if delegate != nil {
                delegate?.errorSendingApiMethod("signupMissing", error: "ERROR in signupMissing")
            }
        }
        
        return empyResult
        
    }
    
    func createPromoFromJson(promo: [String:AnyObject]) -> Promo {
        let idad = promo["idad"]?.integerValue
        
        let p = Promo(pid: idad!)
        p.brandId = promo["idcom"]?.integerValue
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
        p.link = promo["link"] as? String
        p.attachment = promo["attachment"] as? String
        p.cimage = promo["companylogo"] as? String
        p.couponCode = promo["couponcode"] as? String
        p.usedCoupon = promo["usedCoupon"]?.integerValue
        
        if promo["interesteduser"]?.integerValue > 0 {
            p.liked = true
        } else {
            p.liked = false
        }
        
        p.lat = promo["lat"]?.doubleValue
        p.lon = promo["lng"]?.doubleValue
        
        
        
        return p
    }
    
    func createProductFromJson(product: [String:AnyObject]) -> Product {
        
        //print("createProductFromJson: "+product.debugDescription)
        
        let pid = product["idp"]?.integerValue
        
        let p = Product(pid: pid!)
        
        p.name = product["name"] as? String
        p.idCom = product["idcom"]?.integerValue
        p.descShort = product["descriptionShort"] as? String
        p.descLong = product["description"] as? String
        p.price = product["priceSellVatIncluded"] as? String
        p.initialPrice = product["priceOff"] as? String
        
        if p.initialPrice == nil {
            p.initialPrice = "0"
        }
        p.priceUnit = product["priceUnit"] as? String
        p.discountPercent = product["scontoPercent"] as? String
        p.image = product["imgpath"] as? String
        p.quantity = product["quantityAvailable"]?.integerValue
        
        return p
    }
    
    
    // BRAINTREE
    func getPaypalClientToken() {
        
        let clientTokenURL = NSURL(string: "http://www.crgs.it/pionear/api.php?method=getPaypalClientToken")!
        let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        
        NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            
            if error == nil {
                let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
                
                if self.delegate != nil {
                    self.delegate?.didSendApiMethod("getPaypalClientToken", result: clientToken!)
                }
            } else {
                print("Braintree error: "+error.debugDescription)
            }
            
        }.resume()
        //return clientToken
    }
    
    
    func sendFakePOST(data1: String, data2: String) {
        
        let paymentURL = NSURL(string: apiAddress)!
        let request = NSMutableURLRequest(URL: paymentURL)
        request.HTTPBody = "method=paypalGetClientToken&idcom=1&format=json".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            
            if error == nil {
                let response = String(data: data!, encoding: NSUTF8StringEncoding)
                print("postNonceToServer success: "+response!)
            } else {
                print("postNonceToServer error: "+error.debugDescription)
            }
            
            
            }.resume()
    }
    
    
    
    func checkApiServer() -> Bool {
        
        
        
        
        
        return true
        
    }
    
    func getJSON(urlToRequest: String) -> NSData {
        
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    
    func downloadedFrom(imageView:UIImageView, link:String, mode: UIViewContentMode, shadow: Bool) {
        guard
            let url = NSURL(string: link)
            else {return}
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else {
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        
                        imageView.image = UIImage(named: "pioapp_80_x1")
                        UIView.animateWithDuration(0.14, animations: {
                            imageView.alpha = 1
                        })
                    }
                    return
                }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                imageView.image = image
                
                imageView.contentMode = mode
                imageView.clipsToBounds = true
                
                if shadow {
                    //let shadowPath = UIBezierPath(rect: imageView.bounds).CGPath
                    
                    
                    
                    imageView.layer.shadowColor = UIColor.blackColor().CGColor
                    imageView.layer.shadowOpacity = 0.4
                    imageView.layer.shadowOffset = CGSizeMake(0, 2)
                    //imageView.layer.shadowPath = shadowPath
                    //imageView.layer.shouldRasterize = true
                    
                    imageView.layer.masksToBounds = false
                    
                }
                
                
                UIView.animateWithDuration(0.14, animations: {
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
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
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

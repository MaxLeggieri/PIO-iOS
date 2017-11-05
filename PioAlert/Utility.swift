//
//  Utility.swift
//  PioAlert
//
//  Created by LiveLife on 21/12/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    
    static let sharedInstance = Utility()
    
    var homeController:HomeController!
    
    func startImageZoomController(sender: UIImageView, parent: UIViewController) {
        let storyboard = UIStoryboard(name: "Virgi", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "fullscreenImageController") as! ImageFullscreenController
        
        //let subview = sender// as! UIImageView
        
        controller.image = sender.image
        parent.present(controller, animated: true, completion: nil)
    }
    
    func addFullscreenTouch(_ imageView: UIImageView, selector: Selector, target: AnyObject) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: target, action:selector)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func getOrderStatus(_ order: Order, time: Int) -> Int {
        
        var res = 0
        
        /*
        var createdArr = order.createdHuman.components(separatedBy: " ")
        let created = createdArr[0]+" "+createdArr[1]
        
        var deliveryArr = order.deliveryTimeHuman.components(separatedBy: " ")
        let delivery = deliveryArr[0]+" "+deliveryArr[1]
        
        var cutoffArr = order.cutoffTimeHuman.components(separatedBy: " ")
        let cutoff = cutoffArr[0]+" "+cutoffArr[1]
        */
        
        let deliveryDayStart = order.deliveryTime - (3600*16)
        if time < order.cutoffTime {
            res = 1
        }
        else if time > order.cutoffTime && time < deliveryDayStart {
            res = 2
        }
        else {
            
            if time > order.deliveryTime {
                res = 4
            } else {
                res = 3
            }
            
        }
        
        return res
    }
    
    func addBottomBorder(view: UIView) {
        let bb = CALayer()
        bb.backgroundColor = UIColor(colorLiteralRed: 0.847, green: 0.847, blue: 0.847, alpha: 1).cgColor
        bb.frame = CGRect(x: 0, y: view.frame.size.height-1, width: view.frame.size.width, height: 1)
        view.layer.addSublayer(bb)
    }
    
    func formatPrice(price: Double) -> String {
        return String(format: "€ %.2f", price)
    }
    
    func showAlert(target: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        target.present(alert, animated: true, completion: nil)
    }
    
    func addShadowToView(view: UIView, cornerRadius: CGFloat) {
        
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        
    }
    
    
    func showSimpleAlert(title: String, message: String, sender: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(cancelAction)
        sender.present(alertController, animated: true, completion: nil)
        
    }
    
    var loadingView:UIView!
    
    func toggleLoadingView(visible: Bool, parent: UIViewController) {
        
        
        if !visible && loadingView != nil {
            loadingView.removeFromSuperview()
            loadingView = nil
            return
        }
        
        
        
        
        let size = parent.view.frame.size
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.startAnimating()
        indicator.center = loadingView.center
        loadingView.addSubview(indicator)
        
        parent.view.addSubview(loadingView)
        
        
        
    }
}

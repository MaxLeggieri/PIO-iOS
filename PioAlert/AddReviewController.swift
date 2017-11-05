//
//  AddReviewController.swift
//  PioAlert
//
//  Created by Max L. on 22/10/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import Cosmos
enum ReviewType: String {
    case companyReview
    case promoReview
    case productReview
}

class AddReviewController: UIViewController, UITextViewDelegate {

    var product:Product!
    var promo:Promo!
    var company:Company!
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var rating:CosmosView!
    @IBOutlet weak var comment:UITextView!
    var reviewType:ReviewType!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // this code snippet will observe the hiding of keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
        titleLabel.text = "Scrivi una recensione"
        comment.delegate = self
        
        let g = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(g)
    }
    
    func hideKeyboard(sender: UITapGestureRecognizer) {
        comment.resignFirstResponder()
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraint(notification,show: true)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraint(notification,show: false)
    }
    
    func updateBottomLayoutConstraint(_ notification: NSNotification, show: Bool) {
        
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        var frame = self.view.frame
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if show {
            frame.origin.y -= keyboardEndFrame.size.height
        } else {
            frame.origin.y = 0
        }
        UIView.animate(withDuration: animationDuration) {
            self.view.frame = frame
        }
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch reviewType {
        case .productReview:
            name.text = product.name
            WebApi.sharedInstance.downloadedFrom(image, link: "https://www.pioalert.com"+product.image, mode: .scaleAspectFit, shadow: true)

            break
        case .companyReview:
            name.text = company.officialName
            WebApi.sharedInstance.downloadedFrom(image, link: "https://www.pioalert.com"+company.image, mode: .scaleAspectFit, shadow: true)

            break
            
        case .promoReview:
            name.text = promo.title
            WebApi.sharedInstance.downloadedFrom(image, link: "https://www.pioalert.com"+promo.cimage, mode: .scaleAspectFit, shadow: true)

            break
            
        default:
            break
        }

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    
    
    @IBAction func sendReview() {
        
        comment.resignFirstResponder()
        
        if let commentText = comment.text, !commentText.isEmpty && commentText != "Scrivi qui la tua recensione..."{
            switch reviewType {
            case .productReview:
                if WebApi.sharedInstance.setRating(elementType: "product", elementId: product.pid, rating: rating.rating, comment: commentText) {
                    showAlert()
                }
                
                break
            case .companyReview:
                if WebApi.sharedInstance.setRating(elementType: "location", elementId: company.locations[0].idLoc, rating: rating.rating, comment: commentText) {
                    showAlert()
                }
                
                break
                
            case .promoReview:
                if WebApi.sharedInstance.setRating(elementType: "ad", elementId: promo.promoId, rating: rating.rating, comment: commentText) {
                    showAlert()
                }
                
                break
            default:
                break
            }
        }
        else {
            let alertController = UIAlertController(title: "Sorry!", message: "Aggiungi commento.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
            })
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            

        }
        
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Grazie!", message: "Abbiamo ricevuto la tua recensione.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)

    }
    
    @IBAction func close() {
        
        dismiss(animated: true, completion: nil)
        
    }

}

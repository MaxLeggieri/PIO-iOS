//
//  ReviewController.swift
//  PioAlert
//
//  Created by Max L. on 22/10/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
enum GetReviewType: String {
    case companyReview
    case promoReview
    case productReview
}

class ReviewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var titleLabel:UILabel!
    
    var product:Product!
    var promo:Promo!
    var company:Company!
    var getReviewType:GetReviewType!

    var reviews = [Review]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        titleLabel.text = product.name
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        switch getReviewType {
        case .productReview:
            reviews = WebApi.sharedInstance.getRatings(elementId: product.pid, elementType: "product")

            break
        case .companyReview:
            reviews = WebApi.sharedInstance.getRatings(elementId: company.locations[0].idLoc, elementType: "location")

            break
            
        case .promoReview:
            reviews = WebApi.sharedInstance.getRatings(elementId: promo.promoId, elementType: "ad")

            break
            
        default:
            break
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 131
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewViewCell
        
        let r = reviews[indexPath.row]
        
        cell.name.text = r.userName
        cell.cosmosView.rating = r.rating
        WebApi.sharedInstance.downloadedFrom(cell.uimage, link: r.userImage, mode: .scaleAspectFill, shadow: false)
        cell.uimage.alpha = 0
        cell.comment.text = r.comment
        
        
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let r = reviews[indexPath.row]
        
        if WebApi.sharedInstance.reportAbuse(review: r) {
            let alertController = UIAlertController(title: "Segnala recensione", message: "Vuoi davvero segnalare la recensione di "+r.userName+": "+r.comment, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Annulla", style: .cancel)
            let reportAction = UIAlertAction(title: "SEGNALA", style: .destructive, handler: {
                action in
                
                alertController.dismiss(animated: true, completion: nil)
                Utility.sharedInstance.showSimpleAlert(title: "Grazie!", message: "Abbiamo inviato la tua segnalazione", sender: self)
                
            })
            alertController.addAction(cancelAction)
            alertController.addAction(reportAction)
            present(alertController, animated: true, completion: nil)
        } else {
            Utility.sharedInstance.showSimpleAlert(title: "Attenzione", message: "Si è verificato un errore, si prega di riprovare", sender: self)
        }
    }

}

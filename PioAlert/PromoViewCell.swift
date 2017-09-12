//
//  MiInteressaViewCell.swift
//  MenoPercento
//
//  Created by LiveLife on 21/05/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class PromoViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var pimage: UIImageView!
    @IBOutlet weak var prod_name: UILabel!
    @IBOutlet weak var cellContent: UIView!
    @IBOutlet weak var likeButton:UIButton!
    
    
    //@IBOutlet weak var likeButton: LikeButton!
    
    @IBOutlet weak var distanceLabel:UILabel!
    @IBOutlet weak var timeLabel:UILabel!
    
    var promo:Promo!
    var parent:PromoController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        // Expand the view
    }
    
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(rect: pimage.bounds).cgPath
        pimage.layer.masksToBounds = false
        pimage.layer.shadowColor = UIColor.black.cgColor
        pimage.layer.shadowOpacity = 0.4
        pimage.layer.shadowOffset = CGSize(width: 0, height: 1)
        pimage.layer.shadowPath = shadowPath
        pimage.layer.shouldRasterize = true
    }
    
    @IBAction func likeAd(_ sender: UIButton) {
        
        
        if sender.tag == 1 {
            sender.tag = 0
            sender.setImage(UIImage(named: "icon-like"), for: .normal)
            let q = DispatchQueue.global(qos: .background)
            q.async {
                WebApi.sharedInstance.likeAd(false, idad: self.promo.promoId)
            }
            
        } else {
            sender.tag = 1
            sender.setImage(UIImage(named: "icon-like-attivo"), for: .normal)
            let q = DispatchQueue.global(qos: .background)
            q.async {
                WebApi.sharedInstance.likeAd(true, idad: self.promo.promoId)
            }
        }
        
    }
    
    @IBAction func shareAd(_ sender: UIButton) {
        let textToShare = promo.title
        
        let urlString = "https://www.pioalert.com/sharead/?idad="+String(promo.promoId)+"&uid="+String(WebApi.sharedInstance.uid)
        
        if let myWebsite = URL(string: urlString) {
            let objectsToShare = [textToShare ?? "Guarda questa promo su PIO", myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender
            parent.present(activityVC, animated: true, completion: nil)
        }
        
    }
}

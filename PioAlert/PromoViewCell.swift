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
    @IBOutlet weak var likeButton: LikeButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        // Expand the view
    }
    
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(rect: pimage.bounds).CGPath
        pimage.layer.masksToBounds = false
        pimage.layer.shadowColor = UIColor.blackColor().CGColor
        pimage.layer.shadowOpacity = 0.4
        pimage.layer.shadowOffset = CGSizeMake(0, 2)
        pimage.layer.shadowPath = shadowPath
        pimage.layer.shouldRasterize = true
    }
}

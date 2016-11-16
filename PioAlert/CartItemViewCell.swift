//
//  CartItemViewCell.swift
//  PioAlert
//
//  Created by LiveLife on 12/10/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class CartItemViewCell: UITableViewCell {

    
    @IBOutlet weak var pName:UILabel!
    @IBOutlet weak var pPrice:UILabel!
    @IBOutlet weak var pTotal:UILabel!
    @IBOutlet weak var pQuantity:UILabel!
    @IBOutlet weak var pChangeButton:UIButton!
    @IBOutlet weak var pImage:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

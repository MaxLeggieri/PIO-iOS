//
//  CartCell.swift
//  PioAlert
//
//  Created by LiveLife on 26/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {

    
    
    @IBOutlet weak var prodImage:UIImageView!
    @IBOutlet weak var prodName:UILabel!
    @IBOutlet weak var prodQuantity:UILabel!
    @IBOutlet weak var prodSubTotal:UILabel!
    @IBOutlet weak var modifyButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    

}

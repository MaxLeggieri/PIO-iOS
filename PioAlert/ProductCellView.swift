//
//  ProductCellView.swift
//  PioAlert
//
//  Created by LiveLife on 05/09/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class ProductCellView: UITableViewCell {
    
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var desc:UILabel!
    @IBOutlet weak var price:UILabel!
    @IBOutlet weak var initialPrice:UILabel!
    @IBOutlet weak var pimage:UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

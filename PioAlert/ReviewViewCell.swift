//
//  ReviewViewCell.swift
//  PioAlert
//
//  Created by Max L. on 22/10/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import Cosmos

class ReviewViewCell: UITableViewCell {

    
    
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var cosmosView:CosmosView!
    @IBOutlet weak var uimage:UIImageView!
    @IBOutlet weak var comment:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ResultCell.swift
//  PioAlert
//
//  Created by LiveLife on 14/11/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var rImage:UIImageView!
    @IBOutlet weak var rTitle:UILabel!
    @IBOutlet weak var rSubtitle:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

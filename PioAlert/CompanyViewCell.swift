//
//  CompanyViewCell.swift
//  PioAlert
//
//  Created by LiveLife on 29/12/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class CompanyViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var descLabel:UILabel!
    @IBOutlet weak var distanceLabel:UILabel!
    @IBOutlet weak var companyImage:UIImageView!
    @IBOutlet weak var container:UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}

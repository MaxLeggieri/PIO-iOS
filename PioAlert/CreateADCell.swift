//
//  CreateADCell.swift
//  PioAlert
//
//  Created by LiveLife on 05/09/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class CreateADCell: UITableViewCell {
    
    @IBOutlet weak var detailsTextField:UITextField!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var squarBoxButton:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        squarBoxButton.layer.cornerRadius = 5.0
        squarBoxButton.clipsToBounds = true
        squarBoxButton.layer.borderColor = UIColor.gray.cgColor
        squarBoxButton.layer.borderWidth = 1.5
        // Initialization code
    }

}

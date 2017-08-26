//
//  PrivacyCell.swift
//  PioAlert
//
//  Created by LiveLife on 27/04/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class PrivacyCell: UITableViewCell {

    @IBOutlet weak var consentGeoButton:UIButton!
    @IBOutlet weak var consentDataButton:UIButton!
    
    @IBOutlet weak var readGeneralButton:UIButton!
    @IBOutlet weak var readPrivacyButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        consentGeoButton.tag = 1
        consentDataButton.tag = 2
        readGeneralButton.tag = 3
        readPrivacyButton.tag = 4
        
        // Initialization code
    }

    @IBAction func toggleConsent(_ sender: UIButton) {
        if sender.tag == 1 {
            if sender.isSelected {
                sender.isSelected = false
            } else {
                sender.isSelected = true
            }
            PioUser.sharedUser.setGeoConsent(sender.isSelected)
        }
        else if sender.tag == 2 {
            if sender.isSelected {
                sender.isSelected = false
            } else {
                sender.isSelected = true
            }
            PioUser.sharedUser.setDataConsent(sender.isSelected)
        }
        else if sender.tag == 3 {
            if sender.isSelected {
                sender.isSelected = false
            } else {
                sender.isSelected = true
            }
            PioUser.sharedUser.setReadGeneral(read: sender.isSelected)
        }
        else if sender.tag == 4 {
            if sender.isSelected {
                sender.isSelected = false
            } else {
                sender.isSelected = true
            }
            PioUser.sharedUser.setReadPrivacy(read: sender.isSelected)
        }
        
        
    }

}

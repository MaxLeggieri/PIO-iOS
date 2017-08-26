//
//  RoundBorderView.swift
//  PioAlert
//
//  Created by LiveLife on 27/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

@IBDesignable open class RoundBorderView: UIView {

    @IBInspectable var hasShadow: Bool = true {
        
        didSet {
            addShadow(add: hasShadow)
        }
        
    }
    
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        
        didSet {
            layer.cornerRadius = cornerRadius
        }
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius
        addShadow(add: hasShadow)
        clipsToBounds = false
    }
    
    func addShadow(add: Bool) {
        if add {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.3
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
        } else {
            self.layer.shadowColor = UIColor.clear.cgColor
        }
    }

}

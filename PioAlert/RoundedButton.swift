//
//  RoundedButton.swift
//  PioAlert
//
//  Created by LiveLife on 14/12/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

@IBDesignable open class RoundedButton: UIButton {

    @IBInspectable var hasShadow: Bool = false {
        didSet {
            if hasShadow {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOffset = CGSize(width: 1, height: 1)
                layer.shadowOpacity = 0.3
                clipsToBounds = false
            }
        }
    }
    
    @IBInspectable var buttonBackgroundColor: UIColor = UIColor.clear {
        
        didSet {
           backgroundColor = buttonBackgroundColor
        }
    
    }
    
    @IBInspectable var hasBorder: Bool = false {
        
        didSet {
            setBorder(hasBorder, color: borderColor)
        }
        
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            setBorder(hasBorder, color: borderColor)
        }
    }
    
    
    @IBInspectable var textColor: UIColor? {
        
        didSet {
            setTitleColor(textColor, for: .normal)
        }
        
    }

    @IBInspectable var isBold: Bool = true {
        
        didSet {
            if isBold {
                titleLabel?.font = UIFont(name: "Lato-Bold", size: 17)
            } else {
                titleLabel?.font = UIFont(name: "Lato-Medium", size: 17)
            }
        }
        
    }

    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 0.5 * bounds.size.height
        if textColor != nil {
            setTitleColor(textColor, for: .normal)
        } else {
            setTitleColor(UIColor.white, for: .normal)
        }
        backgroundColor = buttonBackgroundColor
        setBorder(hasBorder, color: UIColor.clear)
        clipsToBounds = false
    }
    
    
    open func setBorder(_ border: Bool, color: UIColor) {
        if border {
            layer.borderWidth = 1
            layer.borderColor = color.cgColor
        }
    }
    

}

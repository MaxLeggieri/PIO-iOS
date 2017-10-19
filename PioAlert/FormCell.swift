//
//  FormCell.swift
//  PioAlert
//
//  Created by LiveLife on 02/11/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

public enum FormCellType : Int {
    
    case `default`
    case date
    case email
    
}

class FormCell: UITableViewCell {
    
    
    @IBOutlet weak var formTextField:UITextField!
    
    var cellType = FormCellType.default
    var dataIsValid = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        formTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        /*
        if cellType == FormCell.FormCellTypeDate {
            
            formTextField.placeholder = "Formato 31/12/2000"
            formTextField.keyboardType = .NumberPad
            
        }
        else if cellType == FormCell.FormCellTypeEmail {
            
            formTextField.placeholder = "Il tuo indirizzo mail"
            formTextField.keyboardType = .EmailAddress
            
        }
        */
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    var lastT = ""
    
    
    func textFieldChanged() {
        
        if cellType == .date {
            var final = [Character]()
            let t = formTextField.text?.replacingOccurrences(of: "/", with: "")
            
            if lastT == t {
                return
            }
            
            var index = 0
            for l in (t?.characters)! {
                if l == "/" {
                    continue
                }
                final.append(l)
                index += 1
                if index == 2 || index == 4 {
                    final.append("/")
                }
                
                if final.count > 10 {
                    final.removeLast()
                }
            }
            
            lastT = t!
            formTextField.text = String(final)
            
            if isValidDate(formTextField.text!) {
                self.accessoryType = .checkmark
                dataIsValid = true
            } else {
                self.accessoryType = .none
                dataIsValid = false
            }
            
        }
        else if cellType == .email {
            if isValidEmail(formTextField.text!) {
                self.accessoryType = .checkmark
                dataIsValid = true
            } else {
                self.accessoryType = .none
                dataIsValid = false
            }
        }
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidDate(_ text: String) -> Bool {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        let date = formatter.date(from: text)
        
        return date != nil && text.lengthOfBytes(using: String.Encoding.utf8) == 10
        
    }
}

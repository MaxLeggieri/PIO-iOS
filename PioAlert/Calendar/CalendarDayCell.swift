//
//  CalendarDayCell.swift
//  Pio
//
//  Created by Suresh Jagnani on 03/10/17.
//  Copyright © 2017 iAppS. All rights reserved.
//

import UIKit

class CalendarDayCell: UICollectionViewCell{

    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var outerView : UIView!
    @IBOutlet weak var dotView : UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    func setDateCell( date : Date, isBoarder : Bool, workingDay : String, isServiceType : Bool) {

        //print("d:",Date())
        if isServiceType == true {
            let array = workingDay.components(separatedBy: ",")
            for number in array {
                let workingInt = Int(number)! + 1
                let dateInt = date.getWeekday()
                if workingInt == dateInt {
                    print(String(describing: date))
                    self.isUserInteractionEnabled = true
                    break
                    
                }
                else {
                    self.isUserInteractionEnabled = false
                }
                
            }
        }

        
        if date == Date() {
            self.dotView.isHidden = false
        }
        else {
            self.dotView.isHidden = true
        }
        self.dateLabel.text  = String(date.day)
        self.outerView.backgroundColor = UIColor.clear
        setOuterBoarder(color: UIColor.clear, isBoarder: isBoarder, isDisable: self.isUserInteractionEnabled)
    }

    fileprivate func setOuterBoarder(color : UIColor , isBoarder : Bool , isDisable : Bool) {
       
        if (isBoarder) {
            outerView.layer.cornerRadius = outerView.frame.size.width / 2
            outerView.backgroundColor = UIColor.purple
            self.dateLabel.textColor = UIColor.white
            
        } else {
            outerView.layer.cornerRadius = 0.0
            outerView.backgroundColor = UIColor.clear
            self.dateLabel.textColor = isDisable ?   UIColor.black : UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.4)
            
        }
        
    }
    
}

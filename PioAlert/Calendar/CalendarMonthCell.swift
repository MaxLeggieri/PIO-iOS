//
//  CalendarDayCell.swift
//  Pio
//
//  Created by Suresh Jagnani on 03/10/17.
//  Copyright © 2017 iAppS. All rights reserved.
//

import UIKit

protocol CalendarMonthCellDelegate : class {
    func setHeightOfView( height : CGFloat)
    func selectedDate( date : Date)
    //func getListOfWorkout(date : Date) -> [Workout]?
}

class CalendarMonthCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var monthCollectionView : UICollectionView!
    weak var delegate : CalendarMonthCellDelegate!
    var workingDay : String?
    var serviceType : Bool?
    var dateList = [AnyObject]()
    var selectedDate : Date?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.monthCollectionView.register(UINib(nibName: "CalendarDayCell", bundle: nil), forCellWithReuseIdentifier: "CalendarDayCell")
        self.monthCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
    }

    
    //MARK: Collection View Delegate and DataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count = self.dateList.count
        if count > 0 {
            return count
        }
        
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
        
        cell.outerView.isHidden = true
        if self.dateList.count > indexPath.row {
            let date = self.dateList[indexPath.row]
            if date is Date {
                let isBoarder = selectedDate == date as? Date ? true : false
                cell.outerView.isHidden = false
//                let workouts = self.delegate?.getListOfWorkout(date: date as! Date)
                cell.setDateCell(date: date as! Date, isBoarder : isBoarder, workingDay: self.workingDay!, isServiceType: serviceType!)
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = self.dateList[indexPath.row]
        if date is Date {
            self.delegate?.selectedDate(date: date as! Date)
            selectedDate = date as? Date
            collectionView.reloadData()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.monthCollectionView.frame.size.width/7.0
        return CGSize(width: floor(width), height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0.0
    }
    
    //MARK: - Other Functions
    func reloadMonthCalendar(date : Date, selectedDate : Date?)
    {
        self.selectedDate = selectedDate
        self.getMonthDateList(date: date)
        self.monthCollectionView.reloadData()        
        DispatchQueue.main.async {
            var row = self.dateList.count / 7
            if self.dateList.count % 7 > 0 {
                row += 1
            }
            let width = self.monthCollectionView.frame.size.width/7.0
            let height = ceil(width)  * CGFloat(row)
            self.delegate?.setHeightOfView(height: height)
            self.layoutIfNeeded()
        }
    }
    
    func getMonthDateList(date : Date)
    {
        self.dateList.removeAll()
        let weekday = date.weekday
        
        for _ in (1..<weekday).reversed()  {
            self.dateList.append(NSNull())
        }
        
        let numberofDaysInMonth = date.daysInMonth
        for index in 0..<numberofDaysInMonth {
            let day = date.plus(days: index)
            self.dateList.append(day as AnyObject)
        }
    }

}

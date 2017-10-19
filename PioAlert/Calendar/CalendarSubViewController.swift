//
//  CalendarSubViewController.swift
//  Pio
//
//  Created by Suresh Jagnani on 03/10/17.
//  Copyright © 2017 iAppSolution Technology Inc. All rights reserved.
//

import UIKit

protocol CalendarSubViewDelegate : class {
    func setHeightOfView( height : CGFloat);
    func changeMonth(month : String, year : String)
    func selectedDate( date : Date)

}

class CalendarSubViewController:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CalendarMonthCellDelegate {
    
    @IBOutlet weak var monthLabel : UILabel!
    @IBOutlet weak var calendarCollectionView : UICollectionView!
    @IBOutlet weak var monthViewHeight : NSLayoutConstraint!
    var  workingDay : String!
    var  isServiceType : Bool!
    weak var delegate : CalendarSubViewDelegate!
    let minDateOfCalendar : Date = Date.parse(dateString: "2016-06-01", format: "yyyy-MM-dd")
    let maxDateOfCalendar : Date = Date.parse(dateString: "2022-06-01", format: "yyyy-MM-dd")
    var currentIndex : Int = 0
    var selectedDate : Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let parent = self.parent {
            guard parent is ProductViewController else { return }
                DispatchQueue.main.async {
                    self.setCurrentMonth()
                }
            }
      }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Setup Screen
    func setupScreen() {
        self.calendarCollectionView.register(UINib(nibName: "CalendarMonthCell", bundle: nil), forCellWithReuseIdentifier: "CalendarMonthCell")
    }
    
    func setupCalendar(animation : Bool)
    {
        let indexPath = IndexPath(row: self.currentIndex, section: 0)
        self.calendarCollectionView.layoutIfNeeded()
        self.calendarCollectionView.scrollToItem(at: indexPath, at: .left , animated: animation)
        self.calendarCollectionView.reloadData()
    }
    
    
    func setMonthViewHeight( height : CGFloat)  {
            self.monthViewHeight.constant = height
            self.view.layoutIfNeeded()
            let fullHeight =  height + self.calendarCollectionView.frame.origin.y
            self.delegate?.setHeightOfView(height: fullHeight)
    }
    
    //MARK: - Actions
    @IBAction func nextButtonAction(sender : UIButton) {
      
        self.setNextMonth()
    }
    
    @IBAction func previousButtonAction(sender : UIButton) {
        self.setPreviousMonth()
    }
    
    //MARK: - Other Functions
    func setCurrentMonth()  {
        
        let month = Date.monthsBetween(date1: minDateOfCalendar, date2: Date())
        self.currentIndex = month
        self.setupCalendar(animation: false)
        
    }
    
    func setNextMonth()  {
        self.currentIndex += 1
        
        let maxMonth = Date.monthsBetween(date1: minDateOfCalendar , date2: maxDateOfCalendar)
        if self.currentIndex > maxMonth - 1 {
            self.currentIndex = maxMonth - 1
        }
        self.setupCalendar(animation: true)
        let date = minDateOfCalendar.plus(months: UInt(self.currentIndex))
        self.delegate?.changeMonth(month: String(date.month), year: String(date.year))
    }
    
    func setPreviousMonth()  {
        self.currentIndex -= 1
        if self.currentIndex < 0 {
            self.currentIndex = 0
        }
        
        self.setupCalendar(animation: true)
        let date = minDateOfCalendar.plus(months: UInt(self.currentIndex))
        self.delegate?.changeMonth(month: String(date.month), year: String(date.year))
    }
    
    func setMonthTitle()  {
       let month = minDateOfCalendar.plus(months: UInt(self.currentIndex)).toString(format: "MMMM yyyy")
        self.monthLabel.text = month
    }
    
    func setSelectedDate(date : Date?)  {
        selectedDate = date
        reloadMonth()
    }
    
    func reloadMonth()  {
        self.calendarCollectionView.reloadData()
    }
    //MARK: - Collection View Delegate
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Date.monthsBetween(date1: minDateOfCalendar , date2: maxDateOfCalendar)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarMonthCell", for: indexPath) as! CalendarMonthCell
        let date = minDateOfCalendar.plus(months: UInt(self.currentIndex))
        
        cell.workingDay = workingDay
        cell.serviceType = isServiceType
        cell.reloadMonthCalendar(date:date, selectedDate: selectedDate)
        cell.delegate = self
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.calendarCollectionView.frame.size.width

        //Calculate Height
        let date = minDateOfCalendar.plus(months: UInt(self.currentIndex))
        let count = (date.daysInMonth + date.weekday - 1)
        var numberOfRows = count / 7
        if(count % 7 > 0) {
            numberOfRows += 1
        }
        let height =  ceil(width/7.0) * CGFloat(numberOfRows)
        return CGSize(width: width, height: height)
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
    
    //MARK: - Calender Month Cell
    func setHeightOfView( height : CGFloat)
    {
        self.setMonthViewHeight(height : height + 10)
        self.setMonthTitle()
    }

    func selectedDate( date : Date)
    {
        self.delegate?.selectedDate(date: date)
    }
    
    
//    func isToday() -> Bool {
//        return self.isDateSameDay(Date())
//    }
    

//    func getListOfWorkout(date : Date) -> [Workout]? {
//        return self.delegate?.getListOfWorkout(date: date)
//    }

    
}

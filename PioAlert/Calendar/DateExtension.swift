//
//  DateExtension.swift
//  Pio
//
//  Created by Suresh Jagnani on 8/10/17.
//  Copyright © 2017 iAppS. All rights reserved.
//

import Foundation

extension Date {
    public func plus(seconds s: UInt) -> Date {
        return self.addComponentsToDate(seconds: Int(s), minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minus(seconds s: UInt) -> Date {
        return self.addComponentsToDate(seconds: -Int(s), minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plus(minutes m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: Int(m), hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minus(minutes m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: -Int(m), hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plus(hours h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minus(hours h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: -Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plus(days d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: Int(d), weeks: 0, months: 0, years: 0)
    }
    
    public func minus(days d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: -Int(d), weeks: 0, months: 0, years: 0)
    }
    
    public func plus(weeks w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: Int(w), months: 0, years: 0)
    }
    
    public func minus(weeks w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: -Int(w), months: 0, years: 0)
    }
    
    public func plus(months m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: Int(m), years: 0)
    }
    
    public func minus(months m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: -Int(m), years: 0)
    }
    
    public func plus(years y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: Int(y))
    }
    
    public func minus(years y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: -Int(y))
    }
    
    fileprivate func addComponentsToDate(seconds sec: Int, minutes min: Int, hours hrs: Int, days d: Int, weeks wks: Int, months mts: Int, years yrs: Int) -> Date {
        var dc = DateComponents()
        dc.second = sec
        dc.minute = min
        dc.hour = hrs
        dc.day = d
        dc.weekOfYear = wks
        dc.month = mts
        dc.year = yrs
        return Calendar.current.date(byAdding: dc, to: self as Date)!
    }
    
    public func midnightUTCDate() -> Date {
        var dc: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self as Date)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        dc.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar.current.date(from: dc)!
    }
    
    public func midnightDate() -> Date {
        var dc: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self as Date)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        return Calendar.current.date(from: dc)!
    }
    
    public static func secondsBetween(date1 d1:Date, date2 d2:Date) -> Int {
        let dc = Calendar.current.dateComponents([.second], from: d1, to: d2)
        return dc.second!
    }
    
    public static func minutesBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.minute], from: d1, to: d2)
        return dc.minute!
    }
    
    public static func hoursBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.hour], from: d1, to: d2)
        return dc.hour!
    }
    
    public static func daysBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.day], from: d1, to: d2)
        return dc.day!
    }
    
    public static func weeksBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.weekOfYear], from: d1, to: d2)
        return dc.weekOfYear!
    }
    
    public static func monthsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.month], from: d1, to: d2)
        return dc.month!
    }
    
    public static func yearsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.year], from: d1, to: d2)
        return dc.year!
    }
    
    //MARK- Comparison Methods
    
    public func isGreaterThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }
    
    public func isLessThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedAscending)
    }
    
    //MARK- Computed Properties
    
    public var day: UInt {
        return UInt(Calendar.current.component(.day, from: self as Date))
    }
    
    public var month: UInt {
        return UInt(NSCalendar.current.component(.month, from: self as Date))
    }
    
    public var year: UInt {
        return UInt(NSCalendar.current.component(.year, from: self as Date))
    }
    
    public var hour: UInt {
        return UInt(NSCalendar.current.component(.hour, from: self as Date))
    }
    
    public var minute: UInt {
        return UInt(NSCalendar.current.component(.minute, from: self as Date))
    }
    
    public var second: UInt {
        return UInt(NSCalendar.current.component(.second, from: self as Date))
    }
    
    public var weekday: UInt {
        return UInt(NSCalendar.current.component(.weekday, from: self as Date))
    }
    
    public var daysInMonth: UInt {
        let range = NSCalendar.current.range(of: .day, in: .month, for: self as Date)
        return UInt(range!.count)
    }
    

    //MARK- Compute Date as String
    public func toString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self as Date)
    }
    
    //MARK: Class Functions
    static func parse(dateString: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: dateString)!
    }
    
    //MARK: Class Functions
    static func parseDate(date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    


    
    func isSunday() -> Bool
    {
        return (self.getWeekday() == 1)
    }
    
    func isMonday() -> Bool
    {
        return (self.getWeekday() == 2)
    }
    
    func isTuesday() -> Bool
    {
        return (self.getWeekday() == 3)
    }
    
    func isWednesday() -> Bool
    {
        return (self.getWeekday() == 4)
    }
    
    func isThursday() -> Bool
    {
        return (self.getWeekday() == 5)
    }
    
    func isFriday() -> Bool
    {
        return (self.getWeekday() == 6)
    }
    
    func isSaturday() -> Bool
    {
        return (self.getWeekday() == 7)
    }
    
    func getWeekday() -> Int {
        let calendar = Calendar.current
        return (calendar as NSCalendar).components( .weekday, from: self).weekday!
    }


}

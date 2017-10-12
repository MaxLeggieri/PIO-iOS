//
//  ProductViewController.swift
//  PioAlert
//
//  Created by LiveLife on 25/07/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit
import MessageUI

class ProductViewController: UIViewController,MFMailComposeViewControllerDelegate, CalendarSubViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var navTitle:UILabel!
    @IBOutlet weak var prodTitle:UILabel!
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var finalPrice:UILabel!
    @IBOutlet weak var initialPrice:UILabel!
    @IBOutlet weak var priceOff:UILabel!
    @IBOutlet weak var availability:UILabel!
    @IBOutlet weak var companyName:UILabel!
    @IBOutlet weak var companyAddress:UILabel!
    @IBOutlet weak var prodDesc:UILabel!
    
    @IBOutlet weak var pickerView:UIPickerView?
    @IBOutlet weak var datePicker:UIDatePicker?
    @IBOutlet weak var checkInTextField:UITextField?
    @IBOutlet weak var checkOutTextFiled:UITextField?
    @IBOutlet weak var roomTextField:UITextField?
    @IBOutlet weak var guestTextField:UITextField?
    @IBOutlet weak var childerTextFiled:UITextField?
    @IBOutlet weak var datePickerToolBar:UIToolbar?
    @IBOutlet weak var checkInLabel:UILabel?
    @IBOutlet weak var checkOutLabel:UILabel?
    @IBOutlet weak var bookingView:UIView?

    @IBOutlet weak var bookingViewHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var calendarViewHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var calendarView : UIView?

    var pickerDataSource = Array<Any>()
    var  checkInDate : Date?
    var  checkoutDate : Date?

    var checkInDateString:String?
    var checkOutDateString:String?
    var quantity:String?

    var calendarSubView : CalendarSubViewController!
    var selectedDate : Date?
    var selectedIndex : Int?
    var month : String = ""
    var year : String = ""

    var isCalendarOpen : Bool = false
    var tapCount : Int = 0
    var selectedRow : Int = 0
    
    var product:Product!

    override func viewDidLoad() {
        super.viewDidLoad()

        navTitle.text = product.companyName
        prodTitle.text = product.name
        finalPrice.text = "€ "+product.price
        datePicker?.minimumDate = Date()
        //initialPrice.text = "€ "+product.initialPrice
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "€ "+product.initialPrice)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        initialPrice.attributedText = attributeString
        
        if product.initialPrice == "0" {
            initialPrice.isHidden = true
            priceOff.isHidden = true
        } else {
            initialPrice.isHidden = false
        }
        
        priceOff.text = "Risparmi € "+product.priceOff
        availability.text = String(product.available)+" unità"
        companyName.text = product.companyName
        companyAddress.text = product.companyAddress
        prodDesc.text = product.descLong
        print("calendar %@",product.calendarType ?? "")
        
        if product.calendarType == "1" {
            
        }
        else if product.calendarType == "2" {
            checkInLabel?.text = "Giorno"
            checkOutLabel?.text = "Ora"
            
            self.pickerView?.dataSource = self
            self.pickerView?.delegate = self
            
            let fromTimeSecond = secondsToHoursMinutesSeconds(timeString: product.fromTime!)
            
            let toTimeSecond = secondsToHoursMinutesSeconds(timeString: product.toTime!)
            
            
            let interval = 1800
            let sequence = stride(from: fromTimeSecond, to: toTimeSecond, by: interval)
            
            for element in sequence {
                // do stuff
                print(element)
                pickerDataSource.append(element)
            }
            
            selectedRow = 0
        }
        else {
            bookingViewHeightConstraint?.constant = 0
            checkInTextField?.isHidden = true
            checkOutTextFiled?.isHidden = true
            checkInLabel?.isHidden = true
            checkOutLabel?.isHidden = true
            bookingView?.isHidden = true
        }

        
        self.calendarSubView = self.childViewControllers.first as! CalendarSubViewController
        self.calendarSubView.isServiceType = product.calendarType == "2" ? true : false
        self.calendarSubView.delegate = self
        self.calendarView?.isHidden = true
        self.calendarSubView.workingDay = product.workingDays
        self.checkInTextField?.layer.borderWidth = 1.0
        self.checkInTextField?.layer.cornerRadius = 4.0
        self.checkInTextField?.layer.borderColor = UIColor.lightGray.cgColor
        
        self.checkOutTextFiled?.layer.borderWidth = 1.0
        self.checkOutTextFiled?.layer.cornerRadius = 4.0
        self.checkOutTextFiled?.layer.borderColor = UIColor.lightGray.cgColor

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            DispatchQueue.main.async {
                self.selectedIndex = -1
                let date = Date()
                self.getCalendarWorkout(month: String(date.month), year: String(date.year))
            }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        WebApi.sharedInstance.downloadedFrom(image, link: "https://www.pioalert.com"+product.image, mode: .scaleAspectFit, shadow: true)
        
        Utility.sharedInstance.addFullscreenTouch(image, selector: #selector(showImageFullscreen), target: self)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissProduct(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func showImageFullscreen(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        Utility.sharedInstance.startImageZoomController(sender: imageView, parent: self)
    }

    @IBAction func sendEmail(sender: AnyObject) {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        var rec = [String]()
        rec.append("feedback@pioalert.com")
        if product.companyEmail != "arnaldoguido@email.com" {
            rec.append(product.companyEmail)
        }
        mailVC.setToRecipients(rec)
        mailVC.setSubject("Richiesta informazioni su: "+product.name)
        
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addToCart(sender: UIButton) {
        
        if (product.calendarType == "1" || product.calendarType == "2" ) {
            
            if product.calendarType == "1" {
                if (checkInDateString != "" && quantity != "") {
                WebApi.sharedInstance.basketMoveCalendar(product.pid, quantity: quantity!, calendarType: product.calendarType!, calendarTime : checkInDateString!)

                }

            }
            else if product.calendarType == "2" {
                if (checkInTextField?.text != "" && checkInTextField?.text != "") {
                    
                    let checkOut = self.checkOutTextFiled?.text!
                    
                    let checkIn = self.checkInTextField?.text!

                    let time = "\(checkOut!):00"
                    
                    let dateString = "\(checkIn!) \(time)"
                    
                    
                    let date = Date.parse(dateString: dateString,format: "dd-MM-yyyy HH:mm:ss")
                    let timeStamp =  date.timeIntervalSince1970
                    
                    let timeStampString = String(timeStamp)
                    WebApi.sharedInstance.basketMoveCalendar(product.pid, quantity: "1", calendarType: product.calendarType!, calendarTime : timeStampString)
                    
                }

            }
            
            self.performSegue(withIdentifier: "showCartFromProduct", sender: self)

        }
        else  {
            WebApi.sharedInstance.basketMove(product.pid, quantity: 1)
            
            self.performSegue(withIdentifier: "showCartFromProduct", sender: self)

        }
    }
    
    @IBAction func toolBarDoneButton(sender: UIButton) {
        self.view.endEditing(true)
        if self.datePicker?.tag == 2 {
            let time = showTimeinPicker(seconds: pickerDataSource[selectedRow] as! Int)
            self.checkOutTextFiled?.text = time
            
            /*
            checkoutDate = self.datePicker?.date
            let timeStamp =  self.datePicker?.date.timeIntervalSince1970
            
            let calendar = Calendar.current
            let timeDifference = calendar.dateComponents([.day,.hour, .minute], from: checkInDate!, to: checkoutDate!)
            checkOutDateString = String(timeStamp!)

            if (timeDifference.day! > 0) {
                quantity = String(describing: timeDifference.day)
                
            }
            else {
                let alert = UIAlertController(title: "Alert", message: "checkOut date is small then checkIn not allow", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            */
        }

    }
    
    //MARK: - Calendar Delegate
    func setHeightOfView( height : CGFloat)
    {
        self.calendarViewHeightConstraint?.constant = height
        self.view.layoutIfNeeded()
    }
    
    func changeMonth(month : String, year : String)
    {
        getCalendarWorkout(month: month, year: year)
    }
    
    func selectedDate( date : Date)
    {
        selectedDate = date
        self.calendarView?.isHidden = true

        if self.datePicker?.tag == 1 {
            self.checkInTextField?.text = Date.parseDate(date: date,format: "dd-MM-yyyy")
            let timeStamp =  selectedDate?.timeIntervalSince1970
            checkInDate = selectedDate
            checkInDateString = String(timeStamp!)
            
            
        }
        else {
            self.checkOutTextFiled?.text = Date.parseDate(date: date,format: "yyyy-MM-dd")
            checkoutDate = selectedDate
            let timeStamp =  selectedDate?.timeIntervalSince1970
            checkOutDateString = String(timeStamp!)
        }
        
        if checkInDate != nil && checkoutDate != nil {
            
            let calendar = Calendar.current
            let timeDifference = calendar.dateComponents([.day,.hour, .minute], from: checkInDate!, to: checkoutDate!)
            
            if (timeDifference.day! > 0) {
                quantity = String(describing: timeDifference.day)
                
            }
            else {
                let alert = UIAlertController(title: "Alert", message: "checkOut date is small then checkIn not allow", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

    }
    
    func getCalendarWorkout(month : String, year : String)
    {
   
    }
    
    //MARK:- TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (product.calendarType == "1") {
            
            if textField == self.checkInTextField {
                self.datePicker?.tag = 1
                self.calendarView?.isHidden = false
            }
            
            else if textField == self.checkOutTextFiled {
                self.datePicker?.tag = 2
                self.calendarView?.isHidden = false
                
            }


        }
        else if (product.calendarType == "2") {
            if textField == self.checkInTextField {
                self.datePicker?.tag = 1
                self.calendarView?.isHidden = false

            }
            else {
                self.datePicker?.tag = 2
                textField.inputView = self.pickerView
                textField.inputAccessoryView = self.datePickerToolBar
                self.pickerView?.reloadAllComponents()
                return true
            }

        }

        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    //MARK:- Picker Delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;

    }
    
    // Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let time = showTimeinPicker(seconds: pickerDataSource[row] as! Int)
        return time

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    
    //MARK:- Other Function
    func showTimeinPicker (seconds : Int) -> (String) {
        
        let hour = String(seconds / 3600)
        var min =  String((seconds % 3600) / 60)
        if min == "0" {
            min = "00"
        }
        return String("\(hour):\(min)")
    }
    
    func secondsToHoursMinutesSeconds (timeString : String) -> (Int) {
        let array = timeString.components(separatedBy: ":")
        let hour = Int(array[0])! * 3600
        let min = Int(array[1])! * 60
        
        return hour +  min
    }

    //MARK:- Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCartFromProduct" {
            let vc = segue.destination as! CartViewController
            vc.comId = product.idCom
        }
    }

}

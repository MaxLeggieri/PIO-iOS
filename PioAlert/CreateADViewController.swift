//
//  CreateADViewController.swift
//  PioAlert
//
//  Created by Suresh on 16/10/17.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class CreateADViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, WebApiDelegate {
    
    

    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var pickerView:UIPickerView?
    @IBOutlet weak var datePicker:UIDatePicker?
    @IBOutlet weak var datePickerToolBar:UIToolbar?
    
    @IBOutlet weak var titleLabel:UILabel!
    
    var params = Dictionary<String, Any>()
    var companyDict = [String:Any]()
    var selectedRow: Int!
    var coupons = Array<Any>()
    var allCat = [Category]()
    
    let raykm = [1,5,10,30,50,75,100]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        WebApi.sharedInstance.delegate = self
        companyDict = PioUser.sharedUser.companyDict
        allCat = WebApi.sharedInstance.getAllCategories()

        titleLabel.text = PioUser.sharedUser.companyDict["brandname"] as? String
        // Do any additional setup after loading the view.
        
        print(PioUser.sharedUser.companyDict.debugDescription)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // this code snippet will observe the hiding of keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        params["expiration"] = Date().timeIntervalSince1970+2592000
        params["raykm"] = "100"
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraint(notification,show: true)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraint(notification,show: false)
    }
    
    func updateBottomLayoutConstraint(_ notification: NSNotification, show: Bool) {
        
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        var inset = tableView.contentInset
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: animationDuration) {
            if show {
                inset.bottom = keyboardEndFrame.size.height
            } else {
                inset.bottom = 0
            }
            self.tableView.contentInset = inset
        }
        
        
    }
    
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var logoutButton:UIButton!
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func logout(_ sender: UIButton) {
        PioUser.sharedUser.setCompanyLogged(false)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 170
        }
        else if indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 8 || indexPath.row == 9 || indexPath.row == 11  {
        
            return 0
        }
        else {
            return 85

        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateADImageViewCell", for: indexPath) as! CreateADImageViewCell
            cell.addImageButton.tag = indexPath.row
            cell.addImageButton.addTarget(self, action:#selector(addImageAction(sender:)), for: .touchUpInside)
            
            if let image = params["image"] as? UIImage {
                cell.adImageView.image = image
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateADCell", for: indexPath) as! CreateADCell
            cell.detailsTextField.tag = indexPath.row
            cell.detailsTextField.delegate = self
            switch indexPath.row {
            case 1:
                cell.titleLabel.text = "Titolo"
                cell.detailsTextField.placeholder = "Inserisci il titolo"
                cell.detailsTextField.text = params["title"] as? String
                break
            case 2:
                cell.titleLabel.text = "Descrizione"
                cell.detailsTextField.placeholder = "Inserisci la descrizione"
                cell.detailsTextField.text = params["description"] as? String

                break
            case 3:
                cell.titleLabel.text = "Product"
                cell.detailsTextField.placeholder = "Enter Product"
                cell.detailsTextField.text = params["products"] as? String
                break
            case 4:
                cell.titleLabel.text = "Link"
                cell.detailsTextField.placeholder = "Enter Link"
                cell.detailsTextField.text = params["products"] as? String

                break
            case 5:
                cell.titleLabel.text = "Youtube video link"
                cell.detailsTextField.placeholder = "Enter Youtube Link"
                cell.detailsTextField.text = params["products"] as? String

                break
            case 6:
                cell.titleLabel.text = "Coupon"
                cell.detailsTextField.placeholder = "Select Coupon"
                break
            case 7:
                cell.titleLabel.text = "Category"
                cell.detailsTextField.placeholder = "Select Category"
                break
            case 8:
                cell.titleLabel.text = "Hastag"
                cell.detailsTextField.placeholder = "Enter Hastag"
                break
            case 9:
                cell.titleLabel.text = "Sede"
                cell.detailsTextField.placeholder = "Scegli la location"
                break
            case 10:
                cell.titleLabel.text = "Raggio in km"
                cell.detailsTextField.placeholder = "Scegli il raggio"
                cell.detailsTextField.text = params["raykm"] as? String
                break
            case 11:
                cell.titleLabel.text = "Alert Type"
                cell.detailsTextField.placeholder = "Select Alert type"
                break
            case 12:
                cell.titleLabel.text = "Data di scadenza"
                cell.detailsTextField.placeholder = "scegli la data di scadenza"
                
                if let time = params["expiration"] as? Int {
                    
                    print("TIME: \(time)")
                    cell.detailsTextField.text = getReadableDate(time: TimeInterval(time))
                
                } else {
                    
                    cell.detailsTextField.text = getReadableDate(time: Date().timeIntervalSince1970+2592000)
                }
                
                break
                
            default: break
                
            }
            return cell

        }
        
    }
    
    //MARK:- Action

    func addImageAction(sender: UIButton) {
        
        
        /*
        params["idad"] = "0"
        params["idcom"] = companyDict["idcom"]
        params["title"] = "test ad"
        params["description"] = "test"
        params["products"] = "test"
        params["link"] = "https://pioalert.com"
        params["youtube"] = "https://www.youtube.com/watch?v=AATS5ZnzCP8"
        params["coupon"] = "0"
        params["categories"] = "0,500"
        params["hashtags"] = "#alla"
        params["raykm"] = "0.03"
        params["locations"] = "1"
        params["beacons"] = "154"
        params["alertkind"] = "0"
        params["start"] = ""
        params["expiration"] = "21/09/2017 10:00"
        params["RelatedProducts"] = "0"
        params["method"] = "createAd"
        params["userid"] = companyDict["users_id"]
 
        let fotoImage = params["image"] as! UIImage
        WebApi.sharedInstance.imageUploadRequest(imageView:fotoImage , uploadUrl: URL(string: "http://www.pioalert.com/api/")! as NSURL, param:params as? [String : String])
        
        return
        */
        let actionSheet = UIAlertController(title:nil, message:nil, preferredStyle:.actionSheet)
        actionSheet.addAction(UIAlertAction(title:"Scatta una foto", style:.default, handler:{ action in
            self.openCameraOrLibrary(type: .camera)
        }))
        
        actionSheet.addAction(UIAlertAction(title:"Photo Gallery", style:.default, handler:{ action in
            self.openCameraOrLibrary(type: .photoLibrary)
        }))
        
        actionSheet.addAction(UIAlertAction(title:"Annulla", style: .cancel, handler:nil))
        actionSheet.view.tintColor = UIColor.gray
        self.present(actionSheet, animated: true, completion: nil)

    }
    
    func openCameraOrLibrary( type : UIImagePickerControllerSourceType) {
        
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(type) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self;
                imagePicker.sourceType = type;
                imagePicker.allowsEditing = false;
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func callApi(sender: UIButton) {
        
        var message = ""
        if self.params["title"] == nil {
            message = "Devi inserire un titolo per la Promo"
        }
        else if self.params["description"] == nil {
            message = "Devi inserire una descrizione per la Promo"
        }
        else if self.params["image"] == nil {
            message = "Devi inserire un immagine per la Promo."
        }
        
        if message != "" {
            Utility.sharedInstance.showSimpleAlert(title: "Attenzione", message: message, sender: self)
            return
        }
        
        
        Utility.sharedInstance.toggleLoadingView(visible: true, parent: self)
        
        self.params["idcom"] = self.companyDict["idcom"] as? String
        self.params["method"] = "createAd"
        let fotoImage = self.params["image"] as! UIImage
        WebApi.sharedInstance.imageUploadRequest(imageView:fotoImage , uploadUrl: URL(string: "http://www.pioalert.com/api/")! as NSURL, param:self.params)
        
        
        

    }
    
    func didSendApiMethod(_ method: String, result: String) {
        if method == "createAd" {
            DispatchQueue.main.async {
                Utility.sharedInstance.toggleLoadingView(visible: false, parent: self)
                Utility.sharedInstance.showSimpleAlert(title: "Bene 👍", message: "La Promo è stata inviata con successo, verrai contattato/a quando sarà online!", sender: self)
                
                let alertController = UIAlertController(title: "Bene 👍", message: "La Promo è stata inviata con successo, verrai contattato/a quando sarà online!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                    action in
                    //self.dismiss(animated: true, completion: nil)
                    self.back()
                })
                alertController.addAction(cancelAction)
                //self.present(alertController, animated: true, completion: nil)
                
            }
            
        }
    }
    
    

    func errorSendingApiMethod(_ method: String, error: String) {
        if method == "createAd" {
            Utility.sharedInstance.showSimpleAlert(title: "Attenzione", message: "Si è verificato un errore nell'invio della Promo, controlla i dati e riprova", sender: self)
        }
    }

    @IBAction func toolBarDoneButton(sender: UIButton) {
        self.view.endEditing(true)
        if self.pickerView?.tag == 6 {
            params["coupon"] = String(selectedRow)
        }
    }
    
    // MARK: - UIImagePickerController Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("Done setting image...")
            params["image"] = image
            picker.dismiss(animated: true, completion: nil)
            tableView.reloadData()
        } else {
            print("Error setting image...")
            Utility.sharedInstance.showSimpleAlert(title: "Errore", message: "Si è verificato un errore, riprova.", sender: self)
        }
        /*
        let resizeImage = image.resizeImage(targetSize: CGSize(width: image.size.width, height: image.size.height))
        
        picker.dismiss(animated: true, completion: nil)
        params["image"] = resizeImage
        
        print("Done setting image...")
         */
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        
        picker.dismiss(animated: true, completion: nil)
    }

    
    //MARK:- Picker Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        
        if self.pickerView?.tag == 10 {
            return raykm.count
        }
        
        
        
        return 3;
        
    }
    
    // Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        /*
        if self.pickerView?.tag == 6{
            let data = row == 0 ? "Yes" : "No"
            return data
        }
         */
        
        if pickerView.tag == 10 {
            return String(raykm[row])+" Km"
        }
        return " "
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        
        if self.pickerView?.tag == 10 {
            print("didSelectRow... \(row)")
            params["raykm"] = String(raykm[row])
            tableView.reloadData()
        }
    }
    
    
    
    //MARK:- TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    
        
        print("textFieldShouldBeginEditing...")
        
            if textField.tag == 6 {
                self.pickerView?.tag = 6
                textField.inputView = self.pickerView
                textField.inputAccessoryView = self.datePickerToolBar
                self.pickerView?.reloadAllComponents()
                return true
            }
            else if textField.tag == 10 {
                self.pickerView?.tag = 10
                textField.inputView = self.pickerView
                textField.inputAccessoryView = self.datePickerToolBar
                self.pickerView?.reloadAllComponents()
                return true
            }
            else if textField.tag == 12 {
                self.datePicker?.tag = 12
                textField.inputView = self.datePicker
                textField.inputAccessoryView = self.datePickerToolBar
                return true
            }
    
        return true
    }
    
    func getReadableDate(time: TimeInterval) -> String {
        
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
        
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // User finished typing (hit return): hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //let cell: CreateADCell = textField.superview!.superview as! CreateADCell
        //let indexPath = tableView.indexPath(for: cell)
        
        print("end editing for text field \(textField.tag)")
        
        switch textField.tag {
        case 1:
            params["title"] = textField.text
            break
        case 2:
            params["description"] = textField.text
            break
        case 3:
            params["products"] = textField.text
            break
        case 4:
            params["link"] = textField.text
            break
        case 5:
            params["youtube"] = textField.text
            break
        case 6:
            params["coupon"] = textField.text
            break
        case 7:
            params["categories"] = textField.text
            break
        case 8:
            params["hashtags"] = textField.text
            break
        case 9:
            params["locations"] = textField.text
            break
        case 10:
            
            //params["raykm"] = textField.text
            break
        case 11:
            params["alertkind"] = textField.text
            break
        case 12:
            print("Date picker date: "+(datePicker?.date.debugDescription)!)
            let time = datePicker?.date.timeIntervalSince1970
            params["expiration"] = Int(time!)
            tableView.reloadData()
            break
        default:
            break
        }
        
        //tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

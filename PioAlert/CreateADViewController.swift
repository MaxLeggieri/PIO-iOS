//
//  CreateADViewController.swift
//  PioAlert
//
//  Created by Suresh on 16/10/17.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class CreateADViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var pickerView:UIPickerView?
    @IBOutlet weak var datePicker:UIDatePicker?
    @IBOutlet weak var datePickerToolBar:UIToolbar?
    var params = Dictionary<String, Any>()
    var companyDict = [String:AnyObject]()
    var selectedRow: Int!
    var coupons = Array<Any>()
    var allCat = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        companyDict = PioUser.sharedUser.companyDict
        allCat = WebApi.sharedInstance.getAllCategories()

        // Do any additional setup after loading the view.
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
        else {
            return 85

        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateADImageViewCell", for: indexPath) as! CreateADImageViewCell
            cell.addImageButton.tag = indexPath.row
            cell.addImageButton.addTarget(self, action:#selector(addImageAction(sender:)), for: .touchUpInside)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateADCell", for: indexPath) as! CreateADCell
            cell.detailsTextField.tag = indexPath.row
            cell.detailsTextField.delegate = self
            switch indexPath.row {
            case 1:
                cell.titleLabel.text = "Title"
                cell.detailsTextField.placeholder = "Enter Title"
                cell.detailsTextField.text = params["title"] as? String
                break
            case 2:
                cell.titleLabel.text = "Description"
                cell.detailsTextField.placeholder = "Enter Description"
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
                cell.titleLabel.text = "Loction"
                cell.detailsTextField.placeholder = "Enter Location"
                break
            case 10:
                cell.titleLabel.text = "km Ray"
                cell.detailsTextField.placeholder = "Select km"
                break
            case 11:
                cell.titleLabel.text = "Alert Type"
                cell.detailsTextField.placeholder = "Select Alert type"
                break
            case 12:
                cell.titleLabel.text = "Expiration Date time"
                cell.detailsTextField.placeholder = "Enter Expiration Date"
                break
                
            default: break
                
            }
            return cell

        }
        
    }
    
    //MARK:- Action

    func addImageAction(sender: UIButton) {
        
        
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
        
        let actionSheet = UIAlertController(title:nil, message:nil, preferredStyle:.actionSheet)
        actionSheet.addAction(UIAlertAction(title:"Take Photo", style:.default, handler:{ action in
            self.openCameraOrLibrary(type: .camera)
        }))
        
        actionSheet.addAction(UIAlertAction(title:"Photo Gallery", style:.default, handler:{ action in
            self.openCameraOrLibrary(type: .photoLibrary)
        }))
        
        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler:nil))
        actionSheet.view.tintColor = UIColor.lightGray
        self.present(actionSheet, animated: true, completion: nil)

    }
    
    func openCameraOrLibrary( type : UIImagePickerControllerSourceType) {
        
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(type) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self;
                imagePicker.sourceType = type;
                imagePicker.allowsEditing = true;
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
    }
    
    func callApi(sender: UIButton) {
        params["idad"] = "0"
        params["idcom"] = "475"
        params["title"] = "test ad"
        params["description"] = "test"
        params["products"] = "test"
        params["image"] = UIImageJPEGRepresentation(UIImage(named:"placeHolderImage")!, 0.8)
        params["link"] = "https://pioalert.com"
        params["youtube"] = "https://www.youtube.com/watch?v=AATS5ZnzCP8"
        params["coupon"] = "0"
        params["categories"] = "0,500"
        params["hashtags"] = "#alla"
        params["raykm"] = "0.03"
        params["location"] = "1"
        params["beacons"] = "154"
        params["alertkind"] = "0"
        params["start"] = ""
        params["expiration"] = "21/09/2017 10:00"
        params["RelatedProducts"] = "0"
        params["method"] = "createAd"
        params["userid"] = "607"

    }


    @IBAction func toolBarDoneButton(sender: UIButton) {
        self.view.endEditing(true)
        if self.pickerView?.tag == 6 {
            params["coupon"] = String(selectedRow)
        }
    }
    
    // MARK: - UIImagePickerController Delegates
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let resizeImage = image.resizeImage(targetSize: CGSize(width: 720, height: 720))
        
        picker.dismiss(animated: true, completion: nil)
        params["image"] = resizeImage
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
        if self.pickerView?.tag == 6{
            return 2
        }
        return 3;
        
    }
    
    // Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.pickerView?.tag == 6{
            let data = row == 0 ? "Yes" : "No"
            return data
        }
        return " "
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    
    
    //MARK:- TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    
            if textField.tag == 6 {
                self.pickerView?.tag = 6
                textField.inputView = self.pickerView
                textField.inputAccessoryView = self.datePickerToolBar
                self.pickerView?.reloadAllComponents()
                return true
            }
    
        return false
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // User finished typing (hit return): hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let cell: CreateADCell = textField.superview!.superview as! CreateADCell
        let indexPath = tableView.indexPath(for: cell)
        switch indexPath!.row {
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
            params["raykm"] = textField.text
            break
        case 11:
            params["alertkind"] = textField.text
            break
        case 12:
            params["expiration"] = textField.text
            break
        default:
            break
        }
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

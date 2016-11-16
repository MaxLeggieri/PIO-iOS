//
//  ExtraInfoController.swift
//  PioAlert
//
//  Created by LiveLife on 02/11/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class ExtraInfoController: UITableViewController, WebApiDelegate {
    
    
    
    var extraConfig:[String:AnyObject]!
    var missing:[String]!
    var jobs:[String:String]!
    var jobNames = [String]()
    var genderNames = ["Uomo","Donna"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        WebApi.sharedInstance.delegate = self

        let nib = UINib(nibName: "PioHeader", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "PioHeader")
        
        extraConfig = WebApi.sharedInstance.signupMissing()
        layoutTable()
        
    }
    
    func layoutTable() {
        
        jobs = extraConfig["jobs"] as! [String:String]
        
        
        for index in jobs.keys {
            //jobNames.append(index as! String)
            
            print("jobs dict count: \(jobs.count)")
            
            print("KEY: "+index)
            let val = jobs[index]?.capitalizedString
            print("VAL: "+val!)
            
            jobNames.append(val!)
        }
        
        
        missing = extraConfig["2ask"] as! [String]
        
        print("Missing: "+missing.debugDescription)
        print("Found \(jobs.count) jobs")
        
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Here, we use NSFetchedResultsController
        // And we simply use the section name as title
        
        var title = ""
        
        if missing[section] == "idjobs" {
            title = "Occupazione"
        }
        else if missing[section] == "birth_date" {
            title = "Data di nascita"
        }
        else if missing[section] == "gender" {
            title = "Sesso"
        }
        else if missing[section] == "email" {
            title = "E-mail"
        } else {
            title = "Sconosciuto"
        }
        
        // Dequeue with the reuse identifier
        let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("PioHeader")
        let header = cell as! PioHeader
        header.titleLabel.text = title
        
        //header.bgView.backgroundColor = Color.primary
        return cell
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("numberOfSections: \(missing.count)")
        
        return missing.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if missing[section] == "idjobs" {
            return jobNames.count
        }
        else if missing[section] == "gender" {
            return 2
        }
        else {
            return 1
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if missing[indexPath.section] == "email"  {
            let cell = tableView.dequeueReusableCellWithIdentifier("formCell", forIndexPath: indexPath) as! FormCell
            cell.cellType = .Email
            cell.formTextField.keyboardType = .EmailAddress
            cell.formTextField.placeholder = "La tua email"
            if cell.dataIsValid {
                emailSelected = cell.formTextField.text
            } else {
                emailSelected = nil
            }
            return cell
        }
        else if missing[indexPath.section] == "birth_date" {
            let cell = tableView.dequeueReusableCellWithIdentifier("formCell", forIndexPath: indexPath) as! FormCell
            cell.cellType = .Date
            cell.formTextField.keyboardType = .NumberPad
            cell.formTextField.placeholder = "Formato 31/12/2000"
            if cell.dataIsValid {
                dateSelected = cell.formTextField.text
            } else {
                dateSelected = nil
            }
            return cell
        }
        else if missing[indexPath.section] == "gender" {
            let cell = tableView.dequeueReusableCellWithIdentifier("jobCell", forIndexPath: indexPath)
            
            let gender = genderNames[indexPath.row]
            if genderNameSelected != nil {
                if genderNameSelected == gender {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
                
            } else {
                cell.accessoryType = .None
            }
            
            cell.textLabel?.text = genderNames[indexPath.row]
            
            return cell
        }
        else if missing[indexPath.section] == "idjobs" {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("jobCell", forIndexPath: indexPath)
            
            let job = jobNames[indexPath.row]
            if jobNameSelected != nil {
                if jobNameSelected == job {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
                
            } else {
                cell.accessoryType = .None
            }
            
            cell.textLabel?.text = jobNames[indexPath.row]
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("jobCell", forIndexPath: indexPath)
            //cell.cellType = FormCell.FormCellTypeDefault
            return cell
        }
    }
    
    var jobIdSelected:String!
    var jobNameSelected:String!
    
    var genderNameSelected:String!
    
    var dateSelected:String!
    var emailSelected:String!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        print("Selected, missing: "+missing[indexPath.section])
        
        if missing[indexPath.section] == "idjobs" {
            //let key = jobs
            
            let job = jobNames[indexPath.row]
            //print("job: "+job)
            for key in jobs.keys {
                if jobs[key] == job.lowercaseString {
                    jobIdSelected = key
                    jobNameSelected = job
                    print("ID SELECTED: "+jobIdSelected)
                    tableView.reloadData()
                }
            }
            
            
        }
        else if missing[indexPath.section] == "gender" {
            
            let gender = genderNames[indexPath.row]
            
            for g in genderNames {
                if g == gender {
                    genderNameSelected = g
                    tableView.reloadData()
                }
            }
            
        }
        
    }
    
    
    @IBAction func sendExtraInfo() {
        
        tableView.reloadData()
        
        var errorDesc:String!
        
        if emailSelected == nil {
            errorDesc = "Inserisci un indirizzo mail valido"
        }
        else if dateSelected == nil {
            errorDesc = "Inserisci una data di nascita valida"
        }
        else if jobIdSelected == nil {
            errorDesc = "Seleziona un occupazione"
        }
        else if genderNameSelected == nil {
            errorDesc = "Seleziona il tuo sesso"
        }
        
        
        if errorDesc == nil {
            // Controllo validità
            
            
            
            
            
        } else {
            // Mostra popup
            let alert = UIAlertController(title: "Errore", message: errorDesc, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func didSendApiMethod(method: String, result: String) {
        print("didSendApiMethod EXTRA: "+method+" result:"+result)
        
        //layoutTable()
    }
    
    func errorSendingApiMethod(method: String, error: String) {
        print("errorSendingApiMethod EXTRA: "+method+" result:"+error)
    }

}

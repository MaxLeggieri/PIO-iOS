//
//  OptionsController.swift
//  PioAlert
//
//  Created by LiveLife on 18/07/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class OptionsController: UITableViewController {

    @IBOutlet weak var maxDistanceSlider:UISlider!
    @IBOutlet weak var maxDistanceLabel:UILabel!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        maxDistanceSlider.value = NSUserDefaults.standardUserDefaults().floatForKey("maxDistanceFromAds")
        maxDistanceLabel.text = "\(Int(maxDistanceSlider.value/1000)) km"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        var name = ""
        switch section {
        case 0:
            name = "Distanza dai contenuti"
            break
        default:
            break
        }
        
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        headerView.backgroundColor = Color.primaryDark.colorWithAlphaComponent(0.9)
        
        let label = UILabel(frame: CGRectMake(8,4,400,20))
        label.font = UIFont(name: "Futura", size: 15.0)
        label.textColor = UIColor.whiteColor()
        label.text = name
        
        headerView.addSubview(label)
        
        return headerView
    }
    */
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        maxDistanceLabel.text = "\(Int(sender.value/1000)) km"
        
        NSUserDefaults.standardUserDefaults().setInteger(Int(sender.value), forKey: "maxDistanceFromAds")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let url = NSURL(string: "mailto:feedback@pioalert.com")
                UIApplication.sharedApplication().openURL(url!)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

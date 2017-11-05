//
//  OrderController.swift
//  PioAlert
//
//  Created by Max L. on 21/10/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class OrderController: UIViewController {

    @IBOutlet weak var titleLabel:UILabel!
    
    @IBOutlet weak var statusImage:UIImageView!
    @IBOutlet weak var detailA:UITextView!
    @IBOutlet weak var detailB:UITextView!
    
    var order:Order!
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = order.brandname+" € "+order.total

        let status = Utility.sharedInstance.getOrderStatus(order, time: Int(NSDate().timeIntervalSince1970))
        
        switch status {
        case 2:
            statusImage.image = UIImage(named: "order_status_2")
        case 3:
            statusImage.image = UIImage(named: "order_status_3")
        case 4:
            statusImage.image = UIImage(named: "order_status_4")
        default:
            break
        }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM YYYY hh:mm a"
        
        var det1 = ""
        det1 += "Spedito da: "+order.brandname+"\n"
        det1 += "Data ordine: "+formatter.string(from: Date(timeIntervalSince1970: Double(order.timestamp)))+"\n"
        det1 += "ID ordine: "+String(order.idOrder)+"\n\n"
        
        for p in order.products {
            let rowTotal = Double(p.quantity) * Double(p.price)!
            det1 += String(p.quantity)+" "+p.name+"     "+Utility.sharedInstance.formatPrice(price: rowTotal)+"\n"
        }
        
        det1 += "\n"
        det1 += "Totale: € "+order.total+"\n"
        det1 += "Spedito da: "+order.brandname+"\n"
        
        detailA.text = det1
        
        var det2 = ""
        
        det2 += "Consegna prevista: "+formatter.string(from: Date(timeIntervalSince1970: Double(order.deliveryTime)))+"\n"
        det2 += "DHL tracking: "+order.trackingNumber+"\n"
        
        detailB.text = det2
        
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

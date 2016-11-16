//
//  CouponDisplayController.swift
//  PioAlert
//
//  Created by LiveLife on 19/07/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class CouponDisplayController: UIViewController {

    
    @IBOutlet weak var qrImageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var prodLabel:UILabel!
    @IBOutlet weak var usedLabel:UILabel!
    
    var selectedPromo:Promo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let data = selectedPromo!.couponCode.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter!.setValue(data, forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")
        
        let qrcodeImage = filter!.outputImage!//qrImageView?.image = UIImage(CIImage:filter!.outputImage!)
        
        let scaleX = qrImageView.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrImageView.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        
        qrImageView.image = UIImage(CIImage: transformedImage)
        
        
        titleLabel.text = selectedPromo!.title
        
        
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(selectedPromo!.usedCoupon))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        usedLabel.text = "Usato il: "+dateFormatter.stringFromDate(date)
        
        prodLabel.text = selectedPromo?.prodName
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismiss(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

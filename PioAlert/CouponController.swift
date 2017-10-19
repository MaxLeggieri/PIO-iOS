//
//  CouponController.swift
//  PioAlert
//
//  Created by LiveLife on 13/07/16.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit
import AVFoundation

class CouponController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, WebApiDelegate {

    
    var selectedPromo:Promo!
    @IBOutlet weak var messageLabel:UILabel!
    @IBOutlet weak var topBarView:UIView!
    //@IBOutlet weak var topBarView:UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var presenting:UIViewController!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func dismissCouponReader(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        //var error:NSError?
        
        //let input:AnyObject! = try AVCaptureDeviceInput.deviceInputWithDevice(captureDevice)
        
        
        print(selectedPromo!.couponCode)
        
        do {
            let input:AnyObject! = try AVCaptureDeviceInput.init(device: captureDevice)
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input as! AVCaptureInput)
        }
        catch {
            messageLabel.text = "Errore nell'inizializazione della camera..."
            return
        }
        
        
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession?.startRunning()
        
        // Move the message label to the top view
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: topBarView)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubview(toFront: qrCodeFrameView!)
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds
            
            if metadataObj.stringValue != nil {
                
                if metadataObj.stringValue == selectedPromo!.couponCode {
                    messageLabel.text = "Il tuo coupon è stato convalidato!"
                    messageLabel.backgroundColor = UIColor.green
                    
                    print(metadataObj.stringValue)
                    
                    let systemSoundID: SystemSoundID = 1111
                    AudioServicesPlaySystemSound (systemSoundID)
                    
                    let vc = presenting as! PromoViewController
                    vc.couponButton.isEnabled = false
                    vc.couponButton.alpha = 0.3
                    
                    WebApi.sharedInstance.useCoupon(metadataObj.stringValue, idad: selectedPromo.promoId)
                    selectedPromo.usedCoupon = 1
                } else {
                    messageLabel.text = "Il tuo coupon non è corretto..."
                    messageLabel.backgroundColor = UIColor.red
                    
                    print(metadataObj.stringValue)
                    
                    let systemSoundID: SystemSoundID = 1006
                    AudioServicesPlaySystemSound (systemSoundID)
                }
                
                captureSession?.stopRunning()
                
            }
        }
    }
    
    func didSendApiMethod(_ method: String, result: String) {
        print(result)
    }

    func errorSendingApiMethod(_ method: String, error: String) {
        print(error)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

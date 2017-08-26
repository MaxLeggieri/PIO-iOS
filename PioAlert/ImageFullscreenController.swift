//
//  ImageFullscreenController.swift
//  PioAlert
//
//  Created by LiveLife on 21/12/2016.
//  Copyright © 2016 LiveLife. All rights reserved.
//

import UIKit

class ImageFullscreenController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var indicator:UIActivityIndicatorView!
    @IBOutlet weak var scroll: UIScrollView!
    
    var image:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Dispose of any resources that can be recreated.
        self.scroll.minimumZoomScale = 1.0
        self.scroll.maximumZoomScale = 3.0
        
        imageView.alpha = 0
        imageView.image = image
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        
        UIView.animate(withDuration: 0.250, animations: {
            self.imageView.alpha = 1
            self.indicator.stopAnimating()
        }) 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func close(_ sender: UIButton) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

//
//  CategoryNavBar.swift
//  hayi
//
//  Created by MacBook Pro on 01/11/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import UIKit

class CategoryNavBar : UIView {
    
    
    override func awakeFromNib() {
    
        setUpViews()
        
        
    }
    
    func setUpViews(){
        
        
        // Create a navView to add to the navigation bar
        let navView = UIView()

        // Create the label
        let label = UILabel()
        label.text = "All Activities"
        label.textColor = .white
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center
        label.isUserInteractionEnabled = true

        // Create the image view
        let image = UIImageView()
        image.image = UIImage(named: "Dropdown icon")
        // To maintain the image's aspect ratio:
        //let imageAspect = image.image!.size.width/image.image!.size.height
        // Setting the image frame so that it's immediately before the text:
        image.frame = CGRect(x: 0 , y: 0, width: 20, height: 20)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        image.isUserInteractionEnabled = true

        // Add both the label and image view to the navView
        self.addSubview(image)
        self.addSubview(label)
        
        self.contentMode = UIView.ContentMode.scaleAspectFit
        
        
    }
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: 20, height: 20)
        }
    }

    
    
    
}

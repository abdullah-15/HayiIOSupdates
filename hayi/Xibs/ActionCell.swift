//
//  ActionCell.swift
//  hayi
//
//  Created by MacBook Pro on 09/11/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
protocol SendMail {
    func SendMail()
    func ShowTermsConditions()
    func ShowPrivacyPolicy()
}

class ActionCell: UITableViewCell {
    
    
    @IBOutlet weak var actionLabel: UILabel!
    
    var tagValue:Int = -1
    var delegate: SendMail?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.actionLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(labeltapped))
        self.actionLabel.addGestureRecognizer(tap)
    }
    
    @objc func labeltapped(){
        
        if actionLabel.text == "Contact Us" {

            self.delegate?.SendMail()
        }
        else if actionLabel.text == "Terms & Conditions" {
            
            self.delegate?.ShowTermsConditions()
        }
        else if actionLabel.text == "Privacy Policy" {
            self.delegate?.ShowPrivacyPolicy()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if self.tagValue == 0 {
            
            //Open Terms And C
        }
        else {

        }
        

        // Configure the view for the selected state
    }
    
    
    func configureCell(title: String,tagValue : Int) {
        
        self.actionLabel.text = title
        self.tagValue =  tagValue
    }
}


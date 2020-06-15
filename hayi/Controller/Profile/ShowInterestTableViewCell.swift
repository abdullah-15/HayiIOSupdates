//
//  ShowInterestTableViewCell.swift
//  hayi-ios2
//
//  Created by Mohsin on 17/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class ShowInterestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var Name: UILabel!
    
   
    @IBOutlet weak var userDescr: UILabel!
    
    @IBOutlet weak var profileBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.borderWidth = 0
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

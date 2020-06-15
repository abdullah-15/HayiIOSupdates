//
//  PresentTableViewCell.swift
//  hayi-ios2
//
//  Created by Mohsin on 03/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import ActiveLabel

protocol PresentTableViewCellDelegate {
    func didSelectProfileImageComments(Image: UIImage)
    func didSelectProfileNameComments(Tag: Int)
}


class PresentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var commentedText: ActiveLabel!
    
    @IBOutlet weak var messagecontainerView: UIView!
    @IBOutlet weak var commentedTime: UILabel!
    
    var delegate:PresentTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderWidth = 0
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        commentedText.URLColor = UIColor(hexString: "#1893c4")
        profileImage.isUserInteractionEnabled = true
        profileName.isUserInteractionEnabled = true
    
    }
    @objc func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.delegate.didSelectProfileImageComments(Image: profileImage.image!)
    }
    
    @objc func profileNameTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.delegate.didSelectProfileNameComments(Tag: profileName.tag)
    }
    
    func assignTags(indexPath:IndexPath){
        
        profileName.tag = indexPath.row
        
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
            
             profileImage.isUserInteractionEnabled = true
             profileImage.addGestureRecognizer(tapAvatar)
        
            let tapProfile = UITapGestureRecognizer(target: self, action: #selector(profileNameTapped(tapGestureRecognizer:)))
            profileName.isUserInteractionEnabled = true
             profileName.addGestureRecognizer(tapProfile)
        
        
       
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

//
//  ConversationListCell.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Kingfisher
protocol ConversationListCellDelegate {
    
    func didTapAvatarImage(indexPath: IndexPath)
}

class ConversationListCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageCounterLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var messageCounterBackground: UIView!
    
    var indexPath: IndexPath!
    
    let tapGesture = UITapGestureRecognizer()
    var delegate: ConversationListCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        messageCounterBackground.layer.cornerRadius = messageCounterBackground.frame.width / 2
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderWidth = 0
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        avatarImageView.clipsToBounds = true
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK: generate Cell
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        
        self.nameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        
        self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        
        self.messageCounterLabel.text = recentChat[kCOUNTER] as? String
        
        
        if let avatarString = recentChat[kAVATAR] {
            
            var url = avatarString as! String
            
            if (url == "") {
                
                url = "https://api.hayi.app/Resources/uploads/male.png"
            }
            
            self.avatarImageView.kf.setImage(with: URL(string: url))
        }
        else {
            
            self.avatarImageView.image = UIImage(named: "user (1)")
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            
            self.messageCounterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
            self.messageCounterBackground.isHidden = false
            self.messageCounterLabel.isHidden = false
        } else {
            self.messageCounterBackground.isHidden = true
            self.messageCounterLabel.isHidden = true
        }
        
        var date: Date!
        if let created = recentChat[kDATE] {
            
            if (created as! String).count != 14 {
                
                date = Date()
            }
            else {
                date = dateFormatter().date(from:  created as! String)
            }
            
        }
        else {
            
            date = Date()
        }
        self.dateLabel.text = timeElapsed(date: date)
    }
    
    @objc func avatarTap(){
        
        //delegate?.didTapAvatarImage(indexPath: self.indexPath)
    }
    
}

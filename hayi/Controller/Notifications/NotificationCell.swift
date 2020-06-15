//
//  NotificationCell.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var createdUserAvatar: UIImageView!
    @IBOutlet weak var notificationText: UILabel!
    
    @IBOutlet weak var notificationTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

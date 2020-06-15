//
//  simpleCell.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 19/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class simpleCell: UITableViewCell {

  @IBOutlet weak var simpleLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  
  func configureCell(title: String) {
    
    self.simpleLabel.text = title
    
  }
  
  
  
    
}

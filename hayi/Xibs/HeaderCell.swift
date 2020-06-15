//
//  HeaderCell.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 19/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {

  @IBOutlet weak var headerLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  
  func configureCell(title: String) {
    self.headerLabel.text = title
  }
  
}

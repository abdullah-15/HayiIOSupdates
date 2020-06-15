//
//  HeaderCollectionView.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 21/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class HeaderCollectionView: UICollectionReusableView {

  @IBOutlet weak var labelLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  
  
  func configureCell(title: String) {
    
    
    self.labelLabel.text = title
    
    
  }
  
  
  
}

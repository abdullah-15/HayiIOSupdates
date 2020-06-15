//
//  RoundImageWithBorder.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation

import UIKit

class RoundButtonWithBorderColor: UIButton {
  
  override func awakeFromNib() {
    self.setupView()
  }
  
  func setupView()
  {
    self.layer.cornerRadius = self.frame.height/2
    self.backgroundColor = .clear
    self.layer.borderWidth = 1
    self.layer.borderColor = #colorLiteral(red: 0.07175833732, green: 0.813359201, blue: 0.8076455593, alpha: 1)
    
  }
  
}

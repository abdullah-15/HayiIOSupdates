//
//  RoundView.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 21/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class RoundView: UIView {
  
  override func awakeFromNib() {
    self.setupView()
  }
  
  func setupView() {
    self.layer.cornerRadius = self.frame.height/2
    self.layer.borderColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
  }
  
}

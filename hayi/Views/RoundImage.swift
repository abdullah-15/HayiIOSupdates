//
//  RoundImage.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation

import UIKit

class RoundImage: UIImageView {
  
  override func awakeFromNib() {
    setupView()
  }
  
  func setupView() {
    self.layer.cornerRadius = self.frame.width / 2
    self.clipsToBounds = true
  }
  
}

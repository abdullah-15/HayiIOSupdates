//
//  TableExtension.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 17/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import UIKit



extension UITableView
{
  func unSelectRow() {
    let selectedRow: IndexPath? = self.indexPathForSelectedRow
    if let selectedRow = selectedRow {
      self.deselectRow(at: selectedRow, animated: true)
    }
  }
  
  func restore() {
    self.backgroundView = nil
    self.separatorStyle = .singleLine
  }
  
  func registerTableCellsAndHeaders(cells: [String]) {
    for item in cells {
      let breakTimeLogCell = UINib(nibName:  item , bundle: nil)
      self.register(breakTimeLogCell, forCellReuseIdentifier: item)
    }
  }
  
}

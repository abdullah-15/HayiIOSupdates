//
//  SelfSizedTableView.swift
//  hayi
//
//  Created by MacBook Pro on 28/03/2020.
//  Copyright © 2020 Hayi. All rights reserved.
//

import Foundation
import UIKit

final class SelfSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

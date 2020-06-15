//
//  MessageCollectionviewCell.swift
//  hayi
//
//  Created by MacBook Pro on 08/11/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import MessageKit

extension MessageCollectionViewCell {

    override open func delete(_ sender: Any?) {
        
        // Get the collectionView
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                // Trigger action
                collectionView.delegate?.collectionView?(collectionView, performAction: NSSelectorFromString("delete:"), forItemAt: indexPath, withSender: sender)
            }
        }
    }
}

//
//  CustomMessageCell.swift
//  hayi
//
//  Created by MacBook Pro on 11/11/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
open class CustomMessageCell: UICollectionViewCell {
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView:  MessagesCollectionView) {
        self.contentView.backgroundColor = UIColor.red
    }
}

open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    lazy open var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)

    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
}

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
         //TODO - Customize to size your content appropriately. This just returns a constant size.
        return CGSize(width: 300, height: 130)
    }
}

//
//  FeedCollectionViewCell.swift
//  hayi-ios2
//
//  Created by Mohsin on 04/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell  {
    
    @IBOutlet weak var cross: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.contentMode = .scaleAspectFill
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}




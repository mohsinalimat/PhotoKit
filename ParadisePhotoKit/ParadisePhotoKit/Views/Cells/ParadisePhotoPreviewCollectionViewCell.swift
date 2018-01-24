//
//  ParadisePhotoPreviewCollectionViewCell.swift
//  ParadisePhotoKit
//
//  Created by 李二狗 on 2018/1/24.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit

class ParadisePhotoPreviewCollectionViewCell: UICollectionViewCell {

    open static let reusableCellIdentifier = "ParadisePhotoPreviewCollectionViewCell"
    
    @IBOutlet weak var thumbnailView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

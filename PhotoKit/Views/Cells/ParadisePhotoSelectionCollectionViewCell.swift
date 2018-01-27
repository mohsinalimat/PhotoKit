//
//  ParadisePhotoSelectionCollectionViewCell.swift
//  PhotoKit
//
//  Created by 李二狗 on 2018/1/24.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit

open class ParadisePhotoSelectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var labelContainerView: UIView!
    
    open static let reusableCellIdentifier = "ParadisePhotoSelectionCollectionViewCell"
    open static let counterSelectedColor = UIColor.init(red:0.64, green:0.64, blue:0.99, alpha:1.00)
    open static let counterNormalColor = UIColor.init(white: 0, alpha: 0.2)
    
    open func setupContent(index: Int?, covered: Bool) {
        self.counterLabel.text = nil
        self.coverView.isHidden = !covered
        self.coverView.alpha = 0.8
        self.labelContainerView.backgroundColor = UIColor.clear
        
        if let index = index {
            self.counterLabel.text = "\(index + 1)"
            self.counterLabel.borderColor = type(of: self).counterSelectedColor
            self.counterLabel.backgroundColor = self.counterLabel.borderColor
        } else {
            self.counterLabel.borderColor = UIColor.white
            self.counterLabel.backgroundColor = type(of: self).counterNormalColor
        }
    }
    
    open var onSelection: (() -> Swift.Void)? = nil
    
    @IBAction func selectionAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.onSelection?()
        }
    }
    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

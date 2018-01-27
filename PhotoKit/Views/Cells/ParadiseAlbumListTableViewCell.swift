//
//  ParadiseAlbumListTableViewCell.swift
//  PhotoKit
//
//  Created by 李二狗 on 2018/1/24.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit

open class ParadiseAlbumListTableViewCell: UITableViewCell {

    open static let reusableCellIdentifier = "ParadiseAlbumListTableViewCell"
    
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumContentsCountLabel: UILabel!
    @IBOutlet weak var albumCoverView: UIImageView!
    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

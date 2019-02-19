



//
//  ColunmCollectionViewCell.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/20.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class ColunmCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var contentOutlet: UILabel!
    @IBOutlet weak var bottomOutlet: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var model: HomeColumnItemModel! {
        didSet {
            contentOutlet.text = model.name
            contentOutlet.textColor = model.isSelected ? RGB(250, 126, 136) : RGB(136, 136, 136)
            bottomOutlet.isHidden = !model.isSelected
        }
    }
    
    func updateUI() {
        contentOutlet.textColor = model.isSelected ? RGB(250, 126, 136) : RGB(136, 136, 136)
        bottomOutlet.isHidden = !model.isSelected
    }
}

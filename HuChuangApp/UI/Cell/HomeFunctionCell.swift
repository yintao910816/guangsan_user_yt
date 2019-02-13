//
//  HomeFunctionCell.swift
//  HuChuangApp
//
//  Created by sw on 13/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class HomeFunctionCell: UICollectionViewCell {

    @IBOutlet weak var imageVOutlet: UIImageView!
    @IBOutlet weak var titleOutlet: UILabel!
    
    var model: HomeFunctionModel! {
        didSet {
            imageVOutlet.setImage(model.iconPath, .homeFunction)
            titleOutlet.text = model.name
        }
    }
}

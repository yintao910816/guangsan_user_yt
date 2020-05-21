//
//  MineCell.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/13.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class MineCell: UITableViewCell {

    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var cellIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    var model: MenuListItemModel! {
        didSet {
            titleOutlet.text = model.title
            cellIcon.image = model.titleIcon
        }
    }
}

//
//  HCAccountListCell.swift
//  HuChuangApp
//
//  Created by yintao on 2020/6/3.
//  Copyright © 2020 sw. All rights reserved.
//

import UIKit

class HCAccountListCell: UITableViewCell {

    @IBOutlet weak var iconOutlet: UIImageView!
    @IBOutlet weak var titleOutlet: UILabel!
        
    public var model: HCLoginAccountModel! {
        didSet {
            if model.isAdd {
                iconOutlet.image = UIImage(named: model.avatar)
            }else {
                iconOutlet.setImage(model.avatar, .userIcon)
            }
            titleOutlet.text = model.nickName
        }
    }
    
}

//
//  EditUserInfoCell.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/13.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class EditUserInfoCell: UITableViewCell {

    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var desOutlet: UILabel!
    @IBOutlet weak var iconOutlet: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    var model: EditUserInfoModel! {
        didSet {
            titleOutlet.text = model.title
            if model.isImg == true {
                iconOutlet.isHidden = false
                desOutlet.isHidden  = true
                iconOutlet.setImage(model.iconUrl, .userIcon)
            }else {
                iconOutlet.isHidden = true
                desOutlet.isHidden  = false
                desOutlet.text = model.desTitle
            }
        }
    }
}

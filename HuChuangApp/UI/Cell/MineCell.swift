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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    var title: String! {
        didSet {
            titleOutlet.text = title
        }
    }
}

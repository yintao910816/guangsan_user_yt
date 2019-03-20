




//
//  ArticleCell.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/20.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var imgOutlet: UIImageView!
    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var subTitleOutlet: UILabel!
    @IBOutlet weak var timeOutlet: UILabel!
    @IBOutlet weak var readNumOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var model: HomeArticleModel! {
        didSet {
            imgOutlet.setImage(model.picPath, .homeFunction)
            titleOutlet.text = model.title
            subTitleOutlet.text = model.info
            timeOutlet.text = model.modifyDate
            readNumOutlet.text = model.readNumber
        }
    }
}

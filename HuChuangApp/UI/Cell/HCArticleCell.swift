//
//  HCArticleCell.swift
//  HuChuangApp
//
//  Created by yintao on 2020/6/15.
//  Copyright © 2020 sw. All rights reserved.
//

import UIKit

public let HCArticleCell_identifier = "HCArticleCell"

class HCArticleCell: UITableViewCell {
    
    private var titleLabel: UILabel!
    private var coverImgV: UIImageView!
    private var lineView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    private func setupUI() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.textColor = RGB(51, 51, 51)
        titleLabel.font = .font(fontSize: 14, fontName: .PingFRegular)
        addSubview(titleLabel)
        
        coverImgV = UIImageView()
        coverImgV.contentMode = .scaleAspectFill
        coverImgV.clipsToBounds = true
        addSubview(coverImgV)
        
        lineView = UIView()
        lineView.backgroundColor = RGB(240, 240, 240)
        addSubview(lineView)

        coverImgV.snp.makeConstraints{
            $0.right.equalTo(self).offset(-15)
            $0.top.equalTo(self).offset(15)
            $0.bottom.equalTo(self).offset(-15)
            $0.width.equalTo(120)
        }
        
        lineView.snp.makeConstraints {
            $0.left.right.bottom.equalTo(0)
            $0.height.equalTo(0.5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(15)
            $0.right.equalTo(coverImgV.snp.left).offset(-15)
            $0.top.equalTo(15)
        }
    }
    
    public var model: HCArticleItemModel! {
        didSet {
            titleLabel.text = model.title
            coverImgV.setImage(model.picPath)
        }
    }
    
    public var hiddenLine: Bool = false {
        didSet {
            lineView.isHidden = hiddenLine
        }
    }
    
    var searchArticleModel: HCSearchArticleItemModel! {
        didSet {
            titleLabel.text = searchArticleModel.title
        }
    }
    
    var searchCourseModel: HCSearchCourseItemModel! {
        didSet {
            //            imgV.setImage(searchModel.picPath)
            //            titleLabel.text = searchModel.title
            //            readCountLabel.text = searchModel.readCountText
            //            collectCountLabel.text = searchModel.collectCountText
        }
    }
    
}

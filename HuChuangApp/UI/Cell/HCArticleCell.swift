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
        
        lineView = UIView()
        lineView.backgroundColor = RGB(240, 240, 240)
        addSubview(lineView)

        lineView.snp.makeConstraints {
            $0.left.right.bottom.equalTo(0)
            $0.height.equalTo(8)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(15)
            $0.right.equalTo(-15)
            $0.top.equalTo(12)
            $0.bottom.equalTo(lineView.snp.top).offset(-12)
        }
    }
    
    public var model: HCArticleItemModel! {
        didSet {
            titleLabel.text = model.title
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




//
//  HCClassRoomListCell.swift
//  HuChuangApp
//
//  Created by sw on 2019/9/28.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

public let HCClassRoomListCell_identifier = "HCClassRoomListCell"
public let HCClassRoomListCell_height: CGFloat = 108

class HCClassRoomListCell: UITableViewCell {

    private var imgV: UIImageView!
    private var titleLabel: UILabel!
    private var collectCountLabel: UILabel!
    private var readCountLabel: UILabel!
    private var sepLine: UIView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    private func setupUI() {
        imgV = UIImageView()
        imgV.backgroundColor = RGB(249, 249, 249)
        imgV.contentMode = .scaleAspectFill
        imgV.clipsToBounds = true
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.textColor = RGB(51, 51, 51)
        titleLabel.font = .font(fontSize: 13, fontName: .PingFRegular)

        collectCountLabel = UILabel()
        collectCountLabel.textColor = RGB(153, 153, 153)
        collectCountLabel.font = .font(fontSize: 10, fontName: .PingFRegular)

        readCountLabel = UILabel()
        readCountLabel.textColor = RGB(153, 153, 153)
        readCountLabel.font = .font(fontSize: 10, fontName: .PingFRegular)
        
        sepLine = UIView()
        sepLine.backgroundColor = RGB(249, 249, 249)
        
        contentView.addSubview(imgV)
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectCountLabel)
        contentView.addSubview(readCountLabel)
        contentView.addSubview(sepLine)

        imgV.snp.makeConstraints {
            $0.left.equalTo(15)
            $0.top.equalTo(13)
            $0.bottom.equalTo(-13)
            $0.width.equalTo(110)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imgV.snp.top)
            $0.left.equalTo(imgV.snp.right).offset(10)
            $0.right.equalTo(-24)
        }

        readCountLabel.snp.makeConstraints {
            $0.right.equalTo(-17)
            $0.bottom.equalTo(imgV.snp.bottom).offset(-2)
        }
        
        collectCountLabel.snp.makeConstraints {
            $0.right.equalTo(readCountLabel.snp.left).offset(-18)
            $0.centerY.equalTo(readCountLabel.snp.centerY)
        }
        
        sepLine.snp.makeConstraints {
            $0.left.equalTo(imgV.snp.left)
            $0.right.equalTo(readCountLabel.snp.right)
            $0.bottom.equalTo(0)
            $0.height.equalTo(1)
        }
    }
    
    var model: HCArticleItemModel! {
        didSet {
            imgV.setImage(model.picPath)
            titleLabel.text = model.title
            readCountLabel.text = model.readCountText
            collectCountLabel.text = model.collectCountText
        }
    }
    
    var searchArticleModel: HCSearchArticleItemModel! {
        didSet {
            imgV.setImage(searchArticleModel.picPath)
            titleLabel.text = searchArticleModel.title
            readCountLabel.text = searchArticleModel.readCountText
            collectCountLabel.text = searchArticleModel.collectCountText
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

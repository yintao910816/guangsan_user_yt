//
//  HomeHeader.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxSwift

class HomeHeader: BaseFilesOwner {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var carouselView: CarouselView!
    @IBOutlet weak var functionView: UICollectionView!
    @IBOutlet weak var noticeView: ScrollTextView!
    @IBOutlet weak var goodNewsView: ScrollTextView!
    
    @IBOutlet weak var functionViewHeightCns: NSLayoutConstraint!
    
    var bannerModelObser = Variable([HomeBannerModel]())
    var noticeModelObser = Variable([HomeNoticeModel]())
    var goodNewsModelObser = Variable([HomeGoodNewsModel]())

    override init() {
        super.init()
        
        contentView = (Bundle.main.loadNibNamed("HomeHeaderView", owner: self, options: nil)?.first as! UIView)
        contentView.correctWidth()
        
        rxBind()
    }
    
    private func rxBind() {
        
        bannerModelObser.asDriver()
            .drive(onNext: { [weak self] data in
                self?.carouselView.setData(source: data)
            })
            .disposed(by: disposeBag)
        
        noticeModelObser.asDriver()
            .drive(onNext: { [weak self] data in
                self?.noticeView.datasourceModel = data
            })
            .disposed(by: disposeBag)

        goodNewsModelObser.asDriver()
            .drive(onNext: { [weak self] data in
                self?.goodNewsView.datasourceModel = data
            })
            .disposed(by: disposeBag)

    }
}

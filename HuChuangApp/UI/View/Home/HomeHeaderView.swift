//
//  HomeHeader.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class HomeHeaderView: UIView {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var carouselView: CarouselView!
    @IBOutlet weak var functionView: UICollectionView!
    @IBOutlet weak var noticeView: ScrollTextView!
    @IBOutlet weak var goodNewsView: ScrollTextView!
    
    @IBOutlet weak var functionViewHeightCns: NSLayoutConstraint!
    
    var bannerModelObser = Variable([HomeBannerModel]())
    var functionModelObser = Variable([HomeFunctionModel]())
    var noticeModelObser = Variable([HomeNoticeModel]())
    var goodNewsModelObser = Variable([HomeGoodNewsModel]())
    
    public let functionDidSelected = PublishSubject<HomeFunctionModel>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = (Bundle.main.loadNibNamed("HomeHeaderView", owner: self, options: nil)?.first as! UIView)
        addSubview(contentView)

        contentView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
       
        setupUI()
        rxBind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let width: CGFloat = (PPScreenW - 1) / 4.0
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: width, height: width)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .init(top: 0, left: 0, bottom: 10, right: 0)
        
        functionView.collectionViewLayout = layout
        functionView.register(UINib.init(nibName: "HomeFunctionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeFunctionCellID")
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

        functionModelObser.asDriver()
            .drive(functionView.rx.items(cellIdentifier: "HomeFunctionCellID", cellType: HomeFunctionCell.self)){ (_, model, cell) in
                cell.model = model
            }
            .disposed(by: disposeBag)
        
        functionView.rx.modelSelected(HomeFunctionModel.self)
            .bind(to: functionDidSelected)
            .disposed(by: disposeBag)
    }
}

extension HomeHeaderView {
    
    func headerHeight(dataCount: Int) ->CGFloat {
        if dataCount == 0 { return 0 }
        
        let itemHeight: CGFloat = (PPScreenW - 1) / 4.0
        let height = CGFloat((dataCount / 4 + (dataCount % 4 == 0 ? 0 : 1))) * itemHeight + 10.0
        
        functionViewHeightCns.constant = height

        return 423 + height
    }
}

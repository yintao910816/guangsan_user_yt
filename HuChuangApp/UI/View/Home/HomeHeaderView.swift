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
    
    @IBOutlet weak var firstImgV: UIImageView!
    @IBOutlet weak var secondImgV: UIImageView!
    @IBOutlet weak var thirdImgV: UIImageView!
    @IBOutlet weak var firthImgV: UIImageView!
    @IBOutlet weak var fifthImgV: UIImageView!

    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var firthLabel: UILabel!
    @IBOutlet weak var fifthLabel: UILabel!

    public var bannerModelObser = Variable([HomeBannerModel]())
    public var funcModelObser = Variable([HomeFunctionModel]())

    public let functionDidSelected = PublishSubject<HomeFunctionModel>()
    public let bannerDidSelected = PublishSubject<CarouselSource>()

    @IBAction func actions(_ sender: UIButton) {
        let idx = sender.tag - 1000
        if idx < funcModelObser.value.count {
            functionDidSelected.onNext(funcModelObser.value[idx])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = (Bundle.main.loadNibNamed("HomeHeaderView", owner: self, options: nil)?.first as! UIView)
        addSubview(contentView)

        contentView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
        
        rxBind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func rxBind() {
                
        bannerModelObser.asDriver()
            .drive(onNext: { [weak self] data in
                self?.carouselView.setData(source: data)
            })
            .disposed(by: disposeBag)
        
        funcModelObser.asDriver()
            .drive(onNext: { [weak self] data in
                self?.setupFuncData(data: data)
            })
            .disposed(by: disposeBag)

                
        carouselView.tapCallBack = { [weak self] in self?.bannerDidSelected.onNext($0) }
    }
    
    private func setupFuncData(data: [HomeFunctionModel]) {
        let icons: [UIImageView] = [firstImgV, secondImgV, thirdImgV, firthImgV, fifthImgV]
        let titles: [UILabel] = [firstLabel, secondLabel, thirdLabel, firthLabel, fifthLabel]
        
        for idx in 0..<data.count {
            let item = data[idx]
            if idx < 5 {
                icons[idx].setImage(item.iconPath)
                titles[idx].text = item.name
            }
        }
    }
}

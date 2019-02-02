//
//  HomeViewModel.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel: BaseViewModel {
    
    var bannerModelObser = Variable([HomeBannerModel]())
    var noticeModelObser = Variable([HomeNoticeModel]())
    var goodNewsModelObser = Variable([HomeGoodNewsModel]())

    override init() {
        super.init()
        
        reloadSubject
            .subscribe(onNext: { [unowned self] in self.requestBanner() })
            .disposed(by: disposeBag)
        
        noticeModelObser.value = [HomeNoticeModel(), HomeNoticeModel(), HomeNoticeModel()]
        goodNewsModelObser.value = [HomeGoodNewsModel(), HomeGoodNewsModel(), HomeGoodNewsModel()]
    }
    
    private func requestBanner(){
        HCProvider.request(.selectBanner())
            .map(models: HomeBannerModel.self)
            .subscribe(onSuccess: { [weak self] data in
                self?.bannerModelObser.value = data
            }) { error in
                PrintLog(error)
            }
            .disposed(by: disposeBag)
    }
}

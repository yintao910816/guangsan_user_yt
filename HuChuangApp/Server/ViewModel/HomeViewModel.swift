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
    var functionModelsObser = Variable([HomeFunctionModel]())
    var noticeModelObser = Variable([HomeNoticeModel]())
    var goodNewsModelObser = Variable([HomeGoodNewsModel]())

    override init() {
        super.init()
        
        hud.noticeLoading()

        let loadDataSignal = Observable.combineLatest(requestBanner(), requestFunctionList()){ ($0, $1) }
        reloadSubject.flatMap{ loadDataSignal }
            .subscribe(onNext: { [unowned self] data in
                self.bannerModelObser.value = data.0
                self.functionModelsObser.value = data.1
                self.hud.noticeHidden()
                }, onError: { [unowned self] error in
                    self.hud.failureHidden(self.errorMessage(error))
            })
            .disposed(by: disposeBag)
        
        noticeModelObser.value = [HomeNoticeModel(), HomeNoticeModel(), HomeNoticeModel()]
        goodNewsModelObser.value = [HomeGoodNewsModel(), HomeGoodNewsModel(), HomeGoodNewsModel()]
    }
    
    private func requestBanner() ->Observable<[HomeBannerModel]>{
        return HCProvider.request(.selectBanner())
            .map(models: HomeBannerModel.self)
            .asObservable()
    }
    
    private func requestFunctionList() ->Observable<[HomeFunctionModel]>{
        return HCProvider.request(.functionList())
            .map(models: HomeFunctionModel.self)
            .asObservable()
    }

}

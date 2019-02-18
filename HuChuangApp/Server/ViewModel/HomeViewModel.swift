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
    
    let functionItemDidSelected = PublishSubject<(HomeFunctionModel, UINavigationController?)>()

    override init() {
        super.init()
        
        hud.noticeLoading()
        
        let loadDataSignal = Observable.combineLatest(requestBanner(), requestFunctionList(), requestNoticeList()){ ($0, $1, $2) }
        reloadSubject.flatMap{ loadDataSignal }
            .subscribe(onNext: { [unowned self] data in
                self.dealHomeHeaderData(data: data)
                self.hud.noticeHidden()
                }, onError: { [unowned self] error in
                    self.hud.failureHidden(self.errorMessage(error))
            })
            .disposed(by: disposeBag)
        
        functionItemDidSelected.subscribe(onNext: { [unowned self] data in
            self.functionPush(model: data.0, navigationVC: data.1)
        })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NotificationName.User.LoginSuccess)
            .flatMap{ _ in loadDataSignal }
            .subscribe(onNext: { [unowned self] data in
                self.dealHomeHeaderData(data: data)
            })
            .disposed(by: disposeBag)
        
        goodNewsModelObser.value = [HomeGoodNewsModel(), HomeGoodNewsModel(), HomeGoodNewsModel()]
    }
    
    private func dealHomeHeaderData(data: ([HomeBannerModel], [HomeFunctionModel], [HomeNoticeModel])) {
        bannerModelObser.value = data.0
        functionModelsObser.value = data.1
        noticeModelObser.value = data.2
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
    
    private func requestNoticeList() ->Observable<[HomeNoticeModel]> {
        return HCProvider.request(.noticeList(type: "new", pageNum: 1, pageSize: 10))
            .map(models: HomeNoticeModel.self)
            .asObservable()
    }

    private func functionPush(model: HomeFunctionModel, navigationVC: UINavigationController?) {
        if model.functionUrl.count > 0 {
            var url = model.functionUrl
            if url.last != "?" {
                url += "?unitId=\(model.unitId)"
            }else {
                url += "unitId=\(model.unitId)"
            }
            let webVC = BaseWebViewController()
            webVC.title = model.name
            webVC.url   = url
            navigationVC?.pushViewController(webVC, animated: true)
//            let webVC = BaseWKWebViewViewController()
//            webVC.title = model.name
//            webVC.url = model.functionUrl + "&unitId=\(model.unitId)"
//            navigationVC?.pushViewController(webVC, animated: true)
        }else {
            hud.failureHidden("功能暂不开放")
        }
    }
}

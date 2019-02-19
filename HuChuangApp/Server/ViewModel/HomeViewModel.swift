//
//  HomeViewModel.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel: RefreshVM<HomeArticleModel> {
    
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
    
    override func requestData(_ refresh: Bool) {
        setOffset(refresh: refresh)
        
        HCProvider.request(.article(id: "6"))
            .map(models: HomeArticleModel.self)
            .subscribe(onSuccess: { data in
                PrintLog("article data -- \(data)")
            }) { error in
                PrintLog("article error -- \(error)")
            }
            .disposed(by: disposeBag)
    }
    
    //MARK:
    //MARK: request
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
}

extension HomeViewModel {
    
    private func functionPush(model: HomeFunctionModel, navigationVC: UINavigationController?) {
        if model.functionUrl.count > 0 {
            var url = model.functionUrl
            PrintLog("h5拼接前地址：\(url)")
            if url.contains("?") == false {
                url += "?token=\(userDefault.token)&unitId=\(model.unitId)"
            }else {
                url += "&token=\(userDefault.token)&unitId=\(model.unitId)"
            }
            PrintLog("h5拼接后地址：\(url)")
            
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
    
    private func dealHomeHeaderData(data: ([HomeBannerModel], [HomeFunctionModel], [HomeNoticeModel])) {
        bannerModelObser.value = data.0
        functionModelsObser.value = data.1
        noticeModelObser.value = data.2
    }

}

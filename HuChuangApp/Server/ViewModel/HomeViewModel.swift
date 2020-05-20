//
//  HomeViewModel.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel: RefreshVM<HomeFunctionSectionModel>, VMNavigation {
    
    var bannerModelObser = Variable([HomeBannerModel]())
    
    /// 设置右上角消息数量提醒
    var unreadCountObser = Variable(("", CGFloat(0.0)))
    
    let bannerSelected = PublishSubject<CarouselSource>()

    let functionItemDidSelected = PublishSubject<(HomeFunctionModel, UINavigationController?)>()
    let messageListPublish = PublishSubject<UINavigationController?>()
    let refreshUnreadPublish = PublishSubject<Void>()

    let pushH5Subject = PublishSubject<HomeFunctionModel>()

    private var articleTypeID: String = ""

    override init() {
        super.init()
        hud.noticeLoading()
        
        messageListPublish
            ._doNext(forNotice: hud)
            .flatMap{ [unowned self] _ in self.requestH5(type: .notification) }
            .subscribe(onNext: { [unowned self] model in
                self.hud.noticeHidden()
                self.pushH5(model: model)
                }, onError: { error in
                    self.hud.failureHidden(self.errorMessage(error))
            })
            .disposed(by: disposeBag)
        
        pushH5Subject
            .subscribe(onNext: { [unowned self] in self.pushH5(model: $0) })
            .disposed(by: disposeBag)

        functionItemDidSelected.subscribe(onNext: { [unowned self] data in
            self.functionPush(model: data.0, navigationVC: data.1)
        })
            .disposed(by: disposeBag)
                
        refreshUnreadPublish
            .subscribe(onNext: { [unowned self] in
                self.requestUnread()
            })
            .disposed(by: disposeBag)

        bannerSelected
            .subscribe(onNext: {
                guard let bannerModel = $0 as? HomeBannerModel, bannerModel.validLink else { return }
                HomeViewModel.push(BaseWebViewController.self, ["url":bannerModel.link, "title": bannerModel.title])
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(NotificationName.User.LoginSuccess)
            .subscribe(onNext: { [weak self] data in
                self?.requestData(true)
            })
            .disposed(by: disposeBag)
    }
    
    override func requestData(_ refresh: Bool) {
        setOffset(refresh: refresh)

        requestUnread()
        
        requestHeaderData()
            .subscribe(onNext: { [weak self] data in
                self?.hud.noticeHidden()
                self?.bannerModelObser.value = data.0
                self?.updateRefresh(refresh, data.1, nil)
                }, onError: { [unowned self] error in
                    self.hud.failureHidden(self.errorMessage(error))
            })
            .disposed(by: disposeBag)
    }
    
    private func pushH5(model: H5InfoModel) {
        guard model.setValue.count > 0 else { return }
        let url = "\(model.setValue)?token=\(userDefault.token)&unitId=\(AppSetup.instance.unitId)"
        HomeViewModel.push(BaseWebViewController.self, ["url": url, "title": model.name])
    }
    
    private func pushH5(model: HomeFunctionModel) {
        guard model.functionUrl.count > 0 else { return }
        let url = "\(model.functionUrl)?token=\(userDefault.token)&unitId=\(AppSetup.instance.unitId)"
        HomeViewModel.push(BaseWebViewController.self, ["url": url, "title": model.name])
    }
    
    public var maxFuncRow: Int {
        get {
            var row = 0
            for sectionItem in datasource.value {
                let tempRow = sectionItem.functions.count / 4 + (sectionItem.functions.count % 4 == 0 ? 0 : 1)
                if row < tempRow {
                    row = tempRow
                }
            }
            return row
        }
    }
}

extension HomeViewModel {
    
    private func requestHeaderData() ->Observable<([HomeBannerModel], [HomeFunctionSectionModel])> {
        return Observable.combineLatest(requestBanner(), requestFunctionList()){ ($0, $1) }
            .asObservable()
    }

    private func requestBanner() ->Observable<[HomeBannerModel]>{
        return HCProvider.request(.selectBanner)
            .map(models: HomeBannerModel.self)
            .asObservable()
            .catchErrorJustReturn([HomeBannerModel]())
    }
    
    private func requestFunctionList() ->Observable<[HomeFunctionSectionModel]>{
        return HCProvider.request(.functionList)
            .map(models: HomeFunctionSectionModel.self)
            .asObservable()
            .catchErrorJustReturn([HomeFunctionSectionModel]())
    }
        
    private func requestH5(type: H5Type) ->Observable<H5InfoModel> {
        return HCProvider.request(.unitSetting(type: type))
            .map(model: H5InfoModel.self)
            .asObservable()
    }
    
    private func requestUnread() {
        HCProvider.request(.messageUnreadCount)
            .mapJSON()
            .subscribe(onSuccess: { [weak self] res in
                if let dic = res as? [String: Any],
                    let count = dic["data"] as? Int,
                    count > 0{
                    let countString = "\(count)"
                    let countWidth = countString.getTexWidth(fontSize: 12, height: 20) + 10
                    self?.unreadCountObser.value = (countString, countWidth)
                }else {
                    self?.unreadCountObser.value = ("", 0)
                }
            }) { error in
                PrintLog(error)
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    
    private func functionPush(model: HomeFunctionModel, navigationVC: UINavigationController?) {
        if model.functionUrl.count > 0 {
            var url = model.functionUrl
            PrintLog("h5拼接前地址：\(url)")
            if url.contains("photoSeach") == true {
                HomeViewModel.push(HCScanViewController.self, nil)
                return
            }else if url.contains("?") == false {
                url += "?token=\(userDefault.token)&unitId=\(model.unitId)"
            }else {
                url += "&token=\(userDefault.token)&unitId=\(model.unitId)"
            }
            PrintLog("h5拼接后地址：\(url)")
            
            let webVC = BaseWebViewController()
            webVC.title = model.name
            webVC.url   = url
            navigationVC?.pushViewController(webVC, animated: true)
        }else {
//            hud.failureHidden("功能暂不开放")
        }
    }
    
    private func pushH5(url: String, navigationVC: UINavigationController?) {
        guard url.count > 0 else { return }
        
        let webVC = BaseWebViewController()
        webVC.url   = url
        navigationVC?.pushViewController(webVC, animated: true)
    }
        
}

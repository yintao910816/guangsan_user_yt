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
    
    public let recomFuncData = Variable([HomeFunctionModel]())
    public var bannerModelObser = Variable([HomeBannerModel]())
    public var noticeModelObser = Variable([HomeNoticeModel]())

    public let bannerSelected = PublishSubject<CarouselSource>()

    public let functionItemDidSelected = PublishSubject<(HomeFunctionModel, UINavigationController?)>()
    public let pushH5Subject = PublishSubject<HomeFunctionModel>()
    public let pushCodeBarSubject = PublishSubject<Void>()

    public let reloadRightBarItemSubject = PublishSubject<Void>()

    private var articleTypeID: String = ""

    override init() {
        super.init()
        hud.noticeLoading()
                
        pushH5Subject
            .subscribe(onNext: { [unowned self] in self.pushH5(model: $0) })
            .disposed(by: disposeBag)
                
        pushCodeBarSubject
            .flatMap { [unowned self] in self.requestH5(type: .myBarCode) }
            .subscribe(onNext: { [unowned self] in self.pushH5(model: $0) })
            .disposed(by: disposeBag)

        functionItemDidSelected.subscribe(onNext: { [unowned self] data in
            self.functionPush(model: data.0, navigationVC: data.1)
        })
            .disposed(by: disposeBag)
                
        bannerSelected
            .subscribe(onNext: {
                guard let bannerModel = $0 as? HomeBannerModel, bannerModel.validLink else { return }
                HomeViewModel.push(BaseWebViewController.self, ["url":bannerModel.link, "title": bannerModel.title, "canViewBigPhoto": true])
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(NotificationName.User.LoginSuccess)
            .subscribe(onNext: { [weak self] data in
                self?.reloadRightBarItemSubject.onNext(Void())
                self?.requestData(true)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NotificationName.Logic.refreshMessageBadge)
            .subscribe(onNext: { [weak self] _ in
                self?.requestUnread()
            })
            .disposed(by: disposeBag)
        
        HCProvider.request(.selectInfo)
            .map(model: HCUserModel.self)
            .subscribe(onSuccess: { user in
                HCHelper.saveLogin(user: user)
            }) { error in
                PrintLog(error)
            }
            .disposed(by: disposeBag)
    }
    
    override func requestData(_ refresh: Bool) {
        super.requestData(refresh)
        
        requestUnread()
        
        HCProvider.request(.selectFunc(isRecom: "1"))
            .map(models: HomeFunctionModel.self)
            .subscribe(onSuccess: { [weak self] data in
                self?.recomFuncData.value = data
            }) { _ in }
            .disposed(by: disposeBag)
        
        requestHeaderData()
            .subscribe(onNext: { [weak self] data in
                self?.hud.noticeHidden()
                self?.bannerModelObser.value = data.0
                self?.updateRefresh(refresh, data.1, 0)
                self?.noticeModelObser.value = data.2
                }, onError: { [unowned self] error in
                    self.hud.failureHidden(self.errorMessage(error))
            })
            .disposed(by: disposeBag)
    }
    
    private func pushH5(model: H5InfoModel) {
        guard model.setValue.count > 0 else { return }
//        let url = "\(model.setValue)?token=\(userDefault.token)&unitId=\(AppSetup.instance.unitId)"
        let url = AppSetup.transformURL(urlStr: model.setValue)
        HomeViewModel.push(BaseWebViewController.self, ["url": url, "title": model.name])
    }
    
    private func pushH5(model: HomeFunctionModel) {
        guard model.functionUrl.count > 0 else { return }
//        let url = "\(model.functionUrl)?token=\(userDefault.token)&unitId=\(AppSetup.instance.unitId)"
        let url = AppSetup.transformURL(urlStr: model.functionUrl, unitId: model.unitId)
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
    
    private func requestHeaderData() ->Observable<([HomeBannerModel], [HomeFunctionSectionModel], [HomeNoticeModel])> {
        return Observable.combineLatest(requestBanner(), requestFunctionList(), requestNotice()){ ($0, $1, $2) }
            .asObservable()
    }

    private func requestNotice() ->Observable<[HomeNoticeModel]> {
        return HCProvider.request(.noticeList(type: "new", pageNum: 0, pageSize: 20))
            .map(models: HomeNoticeModel.self)
            .asObservable()
            .catchErrorJustReturn([HomeNoticeModel]())
    }
    
    private func requestBanner() ->Observable<[HomeBannerModel]>{
        return HCProvider.request(.selectBanner)
            .map(models: HomeBannerModel.self)
            .asObservable()
            .catchErrorJustReturn([HomeBannerModel]())
    }
    
    private func requestFunctionList() ->Observable<[HomeFunctionSectionModel]>{
        return HCProvider.request(.selectFuncType(isRecom: "1", isRecomFunc: "0"))
            .map(models: HomeFunctionSectionModel.self)
            .asObservable()
            .catchErrorJustReturn([HomeFunctionSectionModel]())
    }
        
    private func requestH5(type: H5Type) ->Observable<H5InfoModel> {
        return HCProvider.request(.unitSetting(type: type))
            .map(model: H5InfoModel.self)
            .asObservable()
            .catchErrorJustReturn(H5InfoModel())
    }
    
    private func requestUnread() {
        HCProvider.request(.messageUnreadCount)
            .mapJSON()
            .subscribe(onSuccess: { res in
                if let dic = res as? [String: Any],
                    let count = dic["data"] as? Int {
                    let messageVC = (UIApplication.shared.keyWindow?.rootViewController as? HCTabBarViewController)?.viewControllers?[1]
                    messageVC?.tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
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

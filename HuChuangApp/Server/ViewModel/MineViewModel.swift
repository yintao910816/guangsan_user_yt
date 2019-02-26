//
//  MineViewModel.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/13.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift

class MineViewModel: BaseViewModel, VMNavigation {
    
    let userInfo = PublishSubject<HCUserModel>()
    let datasource = PublishSubject<[String]>()
    let gotoEditUserInfo = PublishSubject<Void>()
    let cellDidSelected = PublishSubject<String>()
    
    override init() {
        super.init()
     
        gotoEditUserInfo
            .subscribe(onNext: { _ in
                MineViewModel.sbPush("HCMain", "editUserInfoVC")
            })
            .disposed(by: disposeBag)
        
        cellDidSelected
            .subscribe(onNext: { [unowned self] title in
                self.cellDidSelected(title: title)
            })
            .disposed(by: disposeBag)
        
        HCHelper.share.userInfoHasReload
            .subscribe(onNext: { [unowned self] user in
                self.userInfo.onNext(user)
            })
            .disposed(by: disposeBag)
        
        reloadSubject.subscribe(onNext: { [unowned self] in self.requestUserInfo() })
            .disposed(by: disposeBag)
    }
    
    private func cellDidSelected(title: String) {
        if title == "身份认证" {
            hud.noticeLoading()
            requestH5(type: .bindHos)
                .subscribe(onNext: { [weak self] model in
                    self?.hud.noticeHidden()
                    self?.pushH5(model: model)
                    }, onError: { error in
                        self.hud.failureHidden(self.errorMessage(error))
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func requestH5(type: H5Type) ->Observable<H5InfoModel> {
        return HCProvider.request(.unitSetting(type: type))
            .map(model: H5InfoModel.self)
            .asObservable()
    }

    private func requestUserInfo() {
//        let data = ["身份认证", "我的消息", "意见反馈", "分享给好友", "设置"]
        let data = ["身份认证"]
        datasource.onNext(data)
        
        HCProvider.request(.selectInfo())
            .map(model: HCUserModel.self)
            .subscribe(onSuccess: { [unowned self] user in
                HCHelper.saveLogin(user: user)
                self.userInfo.onNext(user)
            }) { error in
                PrintLog(error)
            }
            .disposed(by: disposeBag)
    }
    
    private func pushH5(model: H5InfoModel) {
        let url = "\(model.setValue)&token=\(userDefault.token)"
        HomeViewModel.push(BaseWebViewController.self, ["url": url])
    }

}

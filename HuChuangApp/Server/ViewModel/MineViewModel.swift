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
    let pushH5Subject = PublishSubject<H5Type>()

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
        
        pushH5Subject
            ._doNext(forNotice: hud)
            .flatMap{ [unowned self] in self.requestH5(type: $0) }
            .subscribe(onNext: { [unowned self] model in
                self.hud.noticeHidden()
                self.pushH5(model: model)
                }, onError: { [unowned self] error in
                    self.hud.failureHidden(self.errorMessage(error))
            })
            .disposed(by: disposeBag)

//        pushH5Subject
//            ._doNext(forNotice: hud)
//            .subscribe(onNext: { [unowned self] type in
//                self.requestH5(type: type)
//                    .subscribe(onNext: { model in
//                        self.hud.noticeHidden()
//                        self.pushH5(model: model)
//                    }, onError: { error in
//                        self.hud.failureHidden(self.errorMessage(error))
//                    })
//                    .disposed(by: self.disposeBag)
//            })
//            .disposed(by: disposeBag)

        HCHelper.share.userInfoHasReload
            .subscribe(onNext: { [unowned self] user in
                self.userInfo.onNext(user)
            })
            .disposed(by: disposeBag)
        
        reloadSubject.subscribe(onNext: { [unowned self] in self.requestUserInfo() })
            .disposed(by: disposeBag)
    }
    
    private func cellDidSelected(title: String) {
        if title == "绑定机构" {
            hud.noticeLoading()
            let type = (HCHelper.share.userInfoModel?.visitCard.count ?? 0) > 0 ? H5Type.succBind : H5Type.bindHos
            requestH5(type: type)
                .subscribe(onNext: { [weak self] model in
                    self?.hud.noticeHidden()
                    self?.pushH5(model: model)
                    }, onError: { error in
                        self.hud.failureHidden(self.errorMessage(error))
                })
                .disposed(by: disposeBag)
        }else if title == "我的消息" {
            hud.noticeLoading()
            requestH5(type: .notification)
                .subscribe(onNext: { [weak self] model in
                    self?.hud.noticeHidden()
                    self?.pushH5(model: model)
                    }, onError: { error in
                        self.hud.failureHidden(self.errorMessage(error))
                })
                .disposed(by: disposeBag)
        }else if title == "设置" {
            NoticesCenter.alert(message: "开发中...")
        }else if title == "软件分享" {
            hud.noticeLoading()
            requestH5(type: .underDev)
                .subscribe(onNext: { [weak self] model in
                    self?.hud.noticeHidden()
                    self?.pushH5(model: model)
                    }, onError: { error in
                        self.hud.failureHidden(self.errorMessage(error))
                })
                .disposed(by: disposeBag)
        }else if title == "用户反馈" {
            hud.noticeLoading()
            requestH5(type: .memberFeedback)
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
        let data = ["绑定机构", "我的消息", "设置", "软件分享", "用户反馈"]
        datasource.onNext(data)
        
        HCProvider.request(.selectInfo)
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
        guard model.setValue.count > 0 else { return }
        
        if model.setValue.count > 0 {
            var url = model.setValue
            PrintLog("h5拼接前地址：\(url)")
            if url.contains("?") == false {
                url += "?token=\(userDefault.token)&unitId=36"
            }else {
                url += "&token=\(userDefault.token)&unitId=36"
            }
            PrintLog("h5拼接后地址：\(url)")
            
            HomeViewModel.push(BaseWebViewController.self, ["url": url])
        }else {
            hud.failureHidden("功能暂不开放")
        }

//        let url = "\(model.setValue)?token=\(userDefault.token)&unitId=\(AppSetup.instance.unitId)"
//        HomeViewModel.push(BaseWebViewController.self, ["url": url])
    }

}

//
//  MineViewModel.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/13.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class MineViewModel: BaseViewModel, VMNavigation {
    
    let userInfo = PublishSubject<HCUserModel>()
    let datasource = PublishSubject<[SectionModel<Int, MenuListItemModel>]>()
    let gotoEditUserInfo = PublishSubject<Void>()
    let cellDidSelected = PublishSubject<MenuListItemModel>()
    let pushH5Subject = PublishSubject<H5Type>()

    override init() {
        super.init()
     
        gotoEditUserInfo
            .subscribe(onNext: { _ in
                MineViewModel.sbPush("HCMain", "editUserInfoVC")
            })
            .disposed(by: disposeBag)
        
        cellDidSelected
            .subscribe(onNext: { [unowned self] model in
                self.cellDidSelected(model: model)
            })
            .disposed(by: disposeBag)
        
        pushH5Subject.concatMap{ [unowned self] in self.requestH5(type: $0) }
            .subscribe(onNext: { [unowned self] model in
                self.hud.noticeHidden()
                self.pushH5(model: model)
                }, onError: { [unowned self] error in
                    self.hud.failureHidden(self.errorMessage(error))
            })
            .disposed(by: disposeBag)

//        pushH5Subject
//            ._doNext(forNotice: hud)
//            .flatMap{ [unowned self] in self.requestH5(type: $0) }
//            .subscribe(onNext: { [unowned self] model in
//                self.hud.noticeHidden()
//                self.pushH5(model: model)
//                }, onError: { [unowned self] error in
//                    self.hud.failureHidden(self.errorMessage(error))
//            })
//            .disposed(by: disposeBag)

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
    
    private func cellDidSelected(model: MenuListItemModel) {
        hud.noticeLoading()
        requestH5(type: model.h5Type)
            .subscribe(onNext: { [weak self] model in
                self?.hud.noticeHidden()
                self?.pushH5(model: model)
                }, onError: { error in
                    self.hud.failureHidden(self.errorMessage(error))
            })
            .disposed(by: disposeBag)
    }
    
    private func requestH5(type: H5Type) ->Observable<H5InfoModel> {
        return HCProvider.request(.unitSetting(type: type))
            .map(model: H5InfoModel.self)
            .asObservable()
    }

    private func requestUserInfo() {
        let bindType = (HCHelper.share.userInfoModel?.visitCard.count ?? 0) > 0 ? H5Type.succBind : H5Type.bindHos
        let dataSignal = [SectionModel.init(model: 0, items: [MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_renzheng"),
                                                                                            title: "认证管理",
                                                                                            h5Type: bindType),
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_peiou"),
                                                                                            title: "配偶信息",
                                                                                            h5Type: .memberMate),
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_jiaofei"),
                                                                                            title: "缴费记录",
                                                                                            h5Type: .memberCharge),
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_geren"),
                                                                                            title: "个人信息",
                                                                                            h5Type: .memberInfo)]),
                          SectionModel.init(model: 1, items: [MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_xiaoxi"),
                                                                                            title: "我的消息",
                                                                                            h5Type: .underDev)]),
                          SectionModel.init(model: 2, items: [MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_xitong"),
                                                                                            title: "系统设置",
                                                                                            h5Type: .underDev),
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_fenxiang"),
                                                                                            title: "软件分享",
                                                                                            h5Type: .underDev),
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_fankui"),
                                                                                            title: "用户反馈",
                                                                                            h5Type: .memberFeedback)])]
        datasource.onNext(dataSignal)
        
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


class MenuListItemModel {
    var titleIcon: UIImage?
    var title: String = ""
    
    var h5Type: H5Type = .underDev
    
    class func createModel(titleIcon: UIImage? = nil, title: String, h5Type: H5Type) ->MenuListItemModel {
        let model = MenuListItemModel()
        model.titleIcon = titleIcon
        model.title = title
        model.h5Type = h5Type
        return model
    }
}

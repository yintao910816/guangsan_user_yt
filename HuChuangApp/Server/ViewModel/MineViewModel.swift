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
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_zhiliao"),
                                                                                            title: "治疗信息",
                                                                                            h5Type: .cureMessage),
//                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_xitong"),
//                                                                                            title: "账户与安全",
//                                                                                            h5Type: .accountSecurity)]
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_xitong"),
                                                                                            title: "关于柔济孕宝",
                                                                                            segue: "aboutSegue")]),
                          SectionModel.init(model: 1, items: [MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_xuanjiao"),
                                                                                            title: "宣教指引",
                                                                                            h5Type: .missionToGuide,
                                                                                            segue: "xuanjiaoSegue"),
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_jingqi"),
                                                                                            title: "经期日记",
                                                                                            h5Type: .menstrualDiary),
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_yuchanqi"),
                                                                                            title: "预产期计算",
                                                                                            h5Type: .dueDate),
                                                              MenuListItemModel.createModel(titleIcon: UIImage(named: "mine_yunma"),
                                                                                            title: "孕妈日记",
                                                                                            h5Type: .pregantDiary)])]
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
//            var url = model.setValue
//            PrintLog("h5拼接前地址：\(url)")
//            if url.contains("?") == false {
//                url += "?token=\(userDefault.token)&unitId=36"
//            }else {
//                url += "&token=\(userDefault.token)&unitId=36"
//            }
//            PrintLog("h5拼接后地址：\(url)")
            HomeViewModel.push(BaseWebViewController.self, ["url": AppSetup.transformURL(urlStr: model.setValue)])
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
    var segue: String = ""
    
    class func createModel(titleIcon: UIImage? = nil, title: String, h5Type: H5Type = .underDev, segue: String = "") ->MenuListItemModel {
        let model = MenuListItemModel()
        model.titleIcon = titleIcon
        model.title = title
        model.h5Type = h5Type
        model.segue = segue
        return model
    }
}

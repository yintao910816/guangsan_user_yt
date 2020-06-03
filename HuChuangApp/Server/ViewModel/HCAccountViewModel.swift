//
//  HCAccountViewModel.swift
//  HuChuangApp
//
//  Created by yintao on 2020/6/3.
//  Copyright © 2020 sw. All rights reserved.
//

import Foundation

import RxSwift

class HCAccountViewModel: BaseViewModel {

    private var navigation: UINavigationController?
     
    public var recordAccountObser = Variable([HCLoginAccountModel]())
    public let cellDidSelectedSubject = PublishSubject<HCLoginAccountModel>()
    
    init(navigation: UINavigationController?) {
        super.init()
        
        self.navigation = navigation
        
        reloadSubject
            .subscribe(onNext: { [weak self] in
                HCLoginAccountModel.selectAll { ret in
                    var tempArr = [HCLoginAccountModel]()

                    let addAccountModel = HCLoginAccountModel()
                    addAccountModel.nickName = "添加账号"
                    addAccountModel.avatar = "add_account"
                    addAccountModel.isAdd = true
                    
                    tempArr.append(contentsOf: ret)
                    tempArr.append(addAccountModel)
                    
                    self?.recordAccountObser.value = tempArr
                }
            })
            .disposed(by: disposeBag)
        
        cellDidSelectedSubject
            .subscribe(onNext: { [unowned self] in
                if $0.isAdd {
                    HCHelper.presentLogin(presentVC: nil) {
                        self.navigation?.popToRootViewController(animated: true)
                    }
                }else {
                    self.login(data: ($0.account, "837546"))
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func login(data: (String, String)) {
        hud.noticeLoading()
        HCProvider.request(.login(mobile: data.0, smsCode: data.1))
            .map(model: HCUserModel.self)
            .subscribe(onSuccess: { [weak self] user in
                let accountModel = HCLoginAccountModel()
                accountModel.account = data.0
                accountModel.nickName = user.name
                accountModel.avatar = user.headPath
                accountModel.pwd = data.1
                accountModel.insert()
                
                userDefault.loginPhone = data.0
                HCHelper.saveLogin(user: user)
                
                NotificationCenter.default.post(name: NotificationName.User.LoginSuccess, object: nil)
                self?.navigation?.popToRootViewController(animated: true)
            }) { [weak self] error in
                self?.hud.failureHidden(self?.errorMessage(error))
            }
            .disposed(by: disposeBag)
    }
}

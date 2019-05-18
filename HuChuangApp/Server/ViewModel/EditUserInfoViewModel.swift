//
//  EditUserInfoViewModel.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/13.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift

class EditUserInfoViewModel: BaseViewModel, VMNavigation {
    
    let datasource = PublishSubject<[EditUserInfoModel]>()
    let gotoEdit = PublishSubject<EditUserInfoModel>()
    
    override init() {
        super.init()
        
        gotoEdit.subscribe(onNext: { model in
            EditUserInfoViewModel.sbPush("HCMain", model.controllerID)
        })
            .disposed(by: disposeBag)
        
        HCHelper.share.userInfoHasReload
            .subscribe(onNext: { [weak self] user in
                self?.dealData(user: user)
            })
            .disposed(by: disposeBag)
        
        reloadSubject.subscribe(onNext: { [unowned self] _ in
            self.requestUserInfo()
        })
            .disposed(by: disposeBag)
    }
    
    private func requestUserInfo() {
        
        if let user = HCHelper.share.userInfoModel {
            self.dealData(user: user)
            return
        }
        
        HCProvider.request(.selectInfo)
            .map(model: HCUserModel.self)
            .subscribe(onSuccess: { [weak self] user in
                self?.dealData(user: user)
            }) { error in
                PrintLog(error)
            }
            .disposed(by: disposeBag)
    }
    
    private func dealData(user: HCUserModel) {
        var data = [EditUserInfoModel]()
        
        let iconModel = EditUserInfoModel.createModel(title: "头像", controllerID: "editUserIconVC", iconUrl: user.headPath, isImg: true)
        data.append(iconModel)
        
        let nickNameModel = EditUserInfoModel.createModel(title: "昵称", controllerID: "editNickNameVC", desTitle: user.name)
        data.append(nickNameModel)
        
        let sexModel = EditUserInfoModel.createModel(title: "性别", controllerID: "editUserSexVC", desTitle: user.sexText)
        data.append(sexModel)
        
        let birthdayModel = EditUserInfoModel.createModel(title: "生日", controllerID: "editBirthdayVC", desTitle: user.birthday)
        data.append(birthdayModel)
        
        let synopsisModel = EditUserInfoModel.createModel(title: "个性签名", controllerID: "editSynopsisVC", desTitle: user.synopsis)
        data.append(synopsisModel)
        
        datasource.onNext(data)
    }
}

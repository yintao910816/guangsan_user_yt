//
//  AccountViewModel.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum LoginType {
    case phone
    case idCard
}

class LoginViewModel: BaseViewModel {
    
    let codeEnable = Variable(true)
    
    public var recordAccountObser = Variable([HCLoginAccountModel]())
    
    init(input: (account: Driver<String>, pass: Driver<String>, loginType: Driver<LoginType>),
         tap: (loginTap: Driver<Void>, sendCodeTap: Driver<Void>)) {
        super.init()
                
        let inputSignal = Driver.combineLatest(input.account, input.pass, input.loginType) { ($0,$1,$2) }
        
        tap.loginTap.withLatestFrom(inputSignal)
            ._doNext(forNotice: hud)
            .filter { [unowned self] data -> Bool in return self.dealInputError(data: data) }
            .drive(onNext: { [unowned self] in self.login(data: $0) })
            .disposed(by: disposeBag)
        
        tap.sendCodeTap.withLatestFrom(input.account)
            .filter{ [unowned self] in self.dealInputError(phone: $0) }
            ._doNext(forNotice: hud)
            .drive(onNext: { [unowned self] in self.sendCode(phone: $0) })
            .disposed(by: disposeBag)
        
        reloadSubject
            .subscribe(onNext: { [weak self] in
                HCLoginAccountModel.selectAll { ret in
                    self?.recordAccountObser.value = ret
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func sendCode(phone: String) {
        codeEnable.value = false

        HCProvider.request(.validateCode(mobile: phone))
            .mapResponse()
            .subscribe(onSuccess: { [weak self] model in
                if RequestCode(rawValue: model.code) == .success {
                    self?.hud.successHidden("验证码已发送")
                }else {
                    self?.codeEnable.value = true
                    self?.hud.failureHidden(model.message)
                }
            }) { [weak self] error in
                self?.hud.failureHidden(self?.errorMessage(error))
            }
            .disposed(by: disposeBag)
    }
    
    private func login(data: (String, String, LoginType)) {
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

                self?.popSubject.onNext(Void())
            }) { [weak self] error in
                self?.hud.failureHidden(self?.errorMessage(error))
            }
            .disposed(by: disposeBag)
    }

    private func dealInputError(phone: String) ->Bool {
        if ValidateNum.phoneNum(phone).isRight == false {
            hud.failureHidden("请输入正确的手机号码")
            return false
        }
        return true
    }

    private func dealInputError(data: (String, String, LoginType)) ->Bool {
        switch data.2 {
        case .phone:
            if ValidateNum.phoneNum(data.0).isRight == false {
                hud.failureHidden("请输入正确的手机号码")
                return false
            }
            if data.1.count == 0 {
                hud.failureHidden("请输入验证码")
                return false
            }
            return true
        case .idCard:
            if ValidateNum.carNum(data.0).isRight == false {
                hud.failureHidden("请输入正确的身份证号码")
                return false
            }
            if ValidateNum.password(data.1).isRight == false {
                hud.failureHidden("请输入正确的密码")
                return false
            }
            if data.1.count < 6 || data.1.count > 12 {
                hud.failureHidden("请输入6-12位密码")
                return false
            }
            return true
        }
    }
}

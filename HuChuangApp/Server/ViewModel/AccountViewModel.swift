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
    public let pushBindSubject = PublishSubject<UMSocialUserInfoResponse>()

    init(input: (account: Driver<String>, pass: Driver<String>, loginType: Driver<LoginType>),
         tap: (loginTap: Driver<Void>, sendCodeTap: Driver<Void>, weChatTap: Driver<Void>)) {
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
                
        tap.weChatTap.asObservable()
            ._doNext(forNotice: hud)
            .flatMap{ HCAccountManager.WeChatLogin() }
            .do(onNext: { [weak self] UserInfoRes in
                if let _ = UserInfoRes {
                    self?.hud.noticeHidden()
                }else {
                    self?.hud.failureHidden("未获取到授权信息")
                }
                }, onError: { [weak self] error in
                    self?.hud.failureHidden(self?.errorMessage(error))
            })
            .filter{ $0 != nil }
            .map { $0! }
            .flatMap { [unowned self] in self.getAuthMemberInfoRequest(socialInfo: $0!) }
            .subscribe(onNext: { [weak self] data in
                if data.0.code == RequestCode.unBindPhone.rawValue {
                    self?.hud.noticeHidden()
                    self?.pushBindSubject.onNext(data.1)
                }else if let user = data.0.data{
                    self?.hud.noticeHidden()
                    HCHelper.saveLogin(user: user)
                    self?.popSubject.onNext(Void())
                }else {
                    self?.hud.failureHidden("未获取到用户信息")
                }
                }, onError: { [weak self] error in
                    self?.hud.failureHidden(self?.errorMessage(error))
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

    private func getAuthMemberInfoRequest(socialInfo: UMSocialUserInfoResponse) ->Observable<(DataModel<HCUserModel>,UMSocialUserInfoResponse)>
    {
        return HCProvider.request(.getAuthMember(openId: socialInfo.openid))
            .map(result: HCUserModel.self)
            .map { ($0, socialInfo) }
            .asObservable()
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

class HCBindPhoneViewModel: BaseViewModel {
    
    private var socialUserInfo: UMSocialUserInfoResponse!
    
    public let codeEnable = Variable(true)
    public let enableBind = Variable(false)

    init(socialUserInfo: UMSocialUserInfoResponse,
         input: (account: Driver<String>, pass: Driver<String>),
         tap: (bindTap: Driver<Void>, sendCodeTap: Driver<Void>, agreeTap: Variable<Bool>)) {
        super.init()
        
        self.socialUserInfo = socialUserInfo
        
        let inputSignal = Observable.combineLatest(input.account.asObservable(), input.pass.asObservable(), tap.agreeTap.asObservable()) { ($0,$1,$2) }
        
        tap.bindTap.asObservable().withLatestFrom(inputSignal)
            ._doNext(forNotice: hud)
            .filter { [unowned self] data -> Bool in return self.dealInputError(data: data) }
            .map{ ($0.0,$0.1,$0.2) }
            .subscribe(onNext: { [unowned self] in self.bindRequest(mobile: $0.0, smsCode: $0.1) })
            .disposed(by: disposeBag)
        
        tap.sendCodeTap.withLatestFrom(input.account)
            .filter{ [unowned self] in self.dealInputError(phone: $0) }
            ._doNext(forNotice: hud)
            .drive(onNext: { [unowned self] in self.sendCode(phone: $0) })
            .disposed(by: disposeBag)
    }
    
    private func bindRequest(mobile: String, smsCode: String) {
        HCProvider.request(.bindAuthMember(userInfo: socialUserInfo, mobile: mobile, smsCode: smsCode))
            .map(model: HCUserModel.self)
            .asObservable()
            .do(onNext: { HCHelper.saveLogin(user: $0) },
                onError: { [weak self] in self?.hud.failureHidden(self?.errorMessage($0)) })
            .flatMap { _ in HCProvider.request(.selectInfo).map(model: HCUserModel.self) }
            .subscribe(onNext: { [weak self] userInfo in
                HCHelper.saveLogin(user: userInfo)
                self?.popSubject.onNext(Void())
            }, onError: { [weak self] error in
                self?.hud.failureHidden(self?.errorMessage(error))
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

    private func dealInputError(phone: String) ->Bool {
        if ValidateNum.phoneNum(phone).isRight == false {
            hud.failureHidden("请输入正确的手机号码")
            return false
        }
        return true
    }

    private func dealInputError(data: (String, String, Bool)) ->Bool {
        if !data.2 {
            hud.failureHidden("请先同意用户协议")
            enableBind.value = false
            return false
        }
        
        if ValidateNum.phoneNum(data.0).isRight == false {
            hud.failureHidden("请输入正确的手机号码")
            enableBind.value = false
            return false
        }
        if data.1.count == 0 {
            hud.failureHidden("请输入验证码")
            enableBind.value = false
            return false
        }
        enableBind.value = true
        return true
    }

}

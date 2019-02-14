//
//  EditViewModel.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/14.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift

class EditUserIconViewModel: BaseViewModel {
    
    let userIcon = PublishSubject<String?>()
    let finishEdit = PublishSubject<UIImage?>()

    override init() {
        super.init()

        finishEdit
            .filter({ [unowned self] image -> Bool in
                if image == nil {
                    self.hud.failureHidden("请选择头像")
                    return false
                }
                return true
            })
            ._doNext(forNotice: hud)
            .flatMap({ [unowned self] image -> Observable<HCUserModel> in
                return self.requestEditIcon(icon: image!).concatMap{ self.requestUpdateUserInfo(iconPath: $0.filePath) }
            })
            .subscribe(onNext: { [weak self] user in
                HCHelper.saveLogin(user: user)
                self?.hud.noticeHidden()
                self?.popSubject.onNext(Void())
                }, onError: { [weak self] error in
                    self?.hud.failureHidden(self?.errorMessage(error))
            })
            .disposed(by: disposeBag)

        reloadSubject.subscribe(onNext: { [weak self] _ in
            self?.userIcon.onNext(HCHelper.share.userInfoModel?.headPath)
        })
            .disposed(by: disposeBag)
    }

    private func requestEditIcon(icon: UIImage) ->Observable<UpLoadIconModel>{
        return HCProvider.request(.uploadIcon(image: icon))
            .map(model: UpLoadIconModel.self)
            .asObservable()
    }
    
    private func requestUpdateUserInfo(iconPath: String) ->Observable<HCUserModel> {
        guard let user = HCHelper.share.userInfoModel else {
            hud.failureHidden("用户信息获取失败，请重新登录") {
                HCHelper.presentLogin()
            }
            return Observable.empty()
        }
        
        let params: [String: String] = ["patientId": user.uid,
                                        "name": user.name,
                                        "sex": "\(user.sex)",
                                        "headPath": iconPath,
                                        "synopsis": user.synopsis,
                                        "birthday": user.birthday]
        
        return HCProvider.request(.updateInfo(param: params))
            .map(model: HCUserModel.self)
            .asObservable()
    }
}

class EditNickNameViewModel: BaseViewModel {
    
    let nickName = PublishSubject<String?>()
    let finishEdit = PublishSubject<String>()
    
    override init() {
        super.init()
        
        finishEdit
            ._doNext(forNotice: hud)
            .subscribe(onNext: { [weak self] nickName in
                self?.requestUpdateUserInfo(nickName: nickName)
            })
            .disposed(by: disposeBag)
        
        reloadSubject.subscribe(onNext: { [weak self] _ in
            self?.nickName.onNext(HCHelper.share.userInfoModel?.name)
        })
            .disposed(by: disposeBag)
    }
    
    private func requestUpdateUserInfo(nickName: String) {
        guard let user = HCHelper.share.userInfoModel else {
            hud.failureHidden("用户信息获取失败，请重新登录") {
                HCHelper.presentLogin()
            }
            return
        }
        let params: [String: String] = ["patientId": user.uid,
                                        "name": nickName,
                                        "sex": "\(user.sex)",
                                        "headPath": user.headPath,
                                        "synopsis": user.synopsis,
                                        "birthday": user.birthday]

        HCProvider.request(.updateInfo(param: params))
            .map(model: HCUserModel.self)
            .subscribe(onSuccess: { [weak self] user in
                HCHelper.saveLogin(user: user)
                self?.hud.noticeHidden()
                self?.popSubject.onNext(Void())
            }) { [weak self] error in
                self?.hud.failureHidden(self?.errorMessage(error))
            }
            .disposed(by: disposeBag)
    }
}

class EditSexViewModel: BaseViewModel {
    
    let datasource = PublishSubject<[String]>()
    let sex = PublishSubject<String>()
    let finishEdit = PublishSubject<String>()

    override init() {
        super.init()
        
        finishEdit
            ._doNext(forNotice: hud)
            .subscribe(onNext: { [weak self] sex in
                self?.requestUpdateUserInfo(sex: sex)
            })
            .disposed(by: disposeBag)

        reloadSubject.subscribe(onNext: { [weak self] _ in
            self?.datasource.onNext(["男", "女"])
            self?.sex.onNext(HCHelper.share.userInfoModel?.sexText ?? "男")
        })
            .disposed(by: disposeBag)
    }
    
    func selectedRow(sex: String) ->Int { return sex == "男" ? 0 : 1 }
    
    private func requestUpdateUserInfo(sex: String) {
        guard let user = HCHelper.share.userInfoModel else {
            hud.failureHidden("用户信息获取失败，请重新登录") {
                HCHelper.presentLogin()
            }
            return
        }
        let params: [String: String] = ["patientId": user.uid,
                                        "name": user.name,
                                        "sex": sex == "男" ? "1" : "2",
                                        "headPath": user.headPath,
                                        "synopsis": user.synopsis,
                                        "birthday": user.birthday]
        HCProvider.request(.updateInfo(param: params))
            .map(model: HCUserModel.self)
            .subscribe(onSuccess: { [weak self] user in
                HCHelper.saveLogin(user: user)
                self?.hud.noticeHidden()
                self?.popSubject.onNext(Void())
            }) { [weak self] error in
                self?.hud.failureHidden(self?.errorMessage(error))
            }
            .disposed(by: disposeBag)
    }
}

class EditBirthdayViewModel: BaseViewModel {
    
    let birthday = PublishSubject<String?>()
    let finishEdit = PublishSubject<String>()

    override init() {
        super.init()
        
        finishEdit
            ._doNext(forNotice: hud)
            .subscribe(onNext: { [weak self] birthday in
                self?.requestUpdateUserInfo(birthday: birthday)
            })
            .disposed(by: disposeBag)

        reloadSubject.subscribe(onNext: { [weak self] _ in
            self?.birthday.onNext(HCHelper.share.userInfoModel?.birthday)
        })
            .disposed(by: disposeBag)
    }
    
    private func requestUpdateUserInfo(birthday: String) {
        guard let user = HCHelper.share.userInfoModel else {
            hud.failureHidden("用户信息获取失败，请重新登录") {
                HCHelper.presentLogin()
            }
            return
        }
        let params: [String: String] = ["patientId": user.uid,
                                        "name": user.name,
                                        "sex": "\(user.sex)",
                                        "headPath": user.headPath,
                                        "synopsis": user.synopsis,
                                        "birthday": birthday]
        HCProvider.request(.updateInfo(param: params))
            .map(model: HCUserModel.self)
            .subscribe(onSuccess: { [weak self] user in
                HCHelper.saveLogin(user: user)
                self?.hud.noticeHidden()
                self?.popSubject.onNext(Void())
            }) { [weak self] error in
                self?.hud.failureHidden(self?.errorMessage(error))
            }
            .disposed(by: disposeBag)
    }
}

class EditSynopsisViewModel: BaseViewModel {
    
    let synopsis = PublishSubject<String?>()
    let finishEdit = PublishSubject<String>()

    override init() {
        super.init()
        
        finishEdit
            ._doNext(forNotice: hud)
            .subscribe(onNext: { [weak self] synopsis in
            self?.requestUpdateUserInfo(synopsis: synopsis)
        })
            .disposed(by: disposeBag)

        reloadSubject.subscribe(onNext: { [weak self] _ in
            self?.synopsis.onNext(HCHelper.share.userInfoModel?.synopsis)
        })
            .disposed(by: disposeBag)
    }
    
    private func requestUpdateUserInfo(synopsis: String) {
        guard let user = HCHelper.share.userInfoModel else {
            hud.failureHidden("用户信息获取失败，请重新登录") {
                HCHelper.presentLogin()
            }
            return
        }
        let params: [String: String] = ["patientId": user.uid,
                                        "name": user.name,
                                        "sex": "\(user.sex)",
                                        "headPath": user.headPath,
                                        "synopsis": synopsis,
                                        "birthday": user.birthday]
        HCProvider.request(.updateInfo(param: params))
            .map(model: HCUserModel.self)
            .subscribe(onSuccess: { [weak self] user in
                HCHelper.saveLogin(user: user)
                self?.hud.noticeHidden()
                self?.popSubject.onNext(Void())
            }) { [weak self] error in
                self?.hud.failureHidden(self?.errorMessage(error))
            }
            .disposed(by: disposeBag)
    }
}


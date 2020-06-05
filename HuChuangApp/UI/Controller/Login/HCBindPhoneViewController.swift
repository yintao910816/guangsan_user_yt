//
//  HCBindPhoneViewController.swift
//  HuChuangApp
//
//  Created by sw on 2019/12/16.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxSwift

class HCBindPhoneViewController: BaseViewController {

    @IBOutlet weak var phoneInputOutlet: UITextField!
    @IBOutlet weak var smsCodeInputOutlet: UITextField!
    
    @IBOutlet weak var bindOutlet: UIButton!
    @IBOutlet weak var getAuthorOutlet: UIButton!
    
    @IBOutlet weak var contentBgView: UIView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var isAgreeButton: UIButton!

    private var viewModel: HCBindPhoneViewModel!
    private var socialUserInfo: UMSocialUserInfoResponse!
    private var agreeObservable = Variable(true)
    
//    private let keyBoardManager = KeyboardManager()
    private var timer: CountdownTimer!

    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func closeAction(_ sender: TYClickedButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func actions(_ sender: UIButton) {
        if sender == agreeButton {
            let webVC = BaseWebViewController()
            webVC.url = "http://120.24.79.125/static/html/roujiyunbao.html"
            navigationController?.pushViewController(webVC, animated: true)
        }else if sender == isAgreeButton {
            sender.isSelected = !sender.isSelected
            agreeObservable.value = sender.isSelected
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        keyBoardManager.registerNotification()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        keyBoardManager.removeNotification()
    }

    override func setupUI() {        
        let agreeText = "我已阅读并接受《用户协议》"
        agreeButton.setAttributedTitle(agreeText.attributed(.init(location: 7, length: 6), HC_MAIN_COLOR, nil), for: .normal)
        
        timer = CountdownTimer.init(totleCount: 120)
        
        #if DEBUG
        phoneInputOutlet.text = "18627844751"
        #endif
    }
    
    override func rxBind() {
        timer.showText.asDriver()
            .skip(1)
            .drive(onNext: { [weak self] second in
                if second == 0 {
                    self?.viewModel.codeEnable.value = true
                    self?.getAuthorOutlet.setTitle("获取验证码", for: .normal)
                }else {
                    self?.getAuthorOutlet.setTitle("\(second)s", for: .normal)
                }
            })
            .disposed(by: disposeBag)

        let bindDriver = bindOutlet.rx.tap.asDriver()
            .do(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            })
        let sendCodeDriver = getAuthorOutlet.rx.tap.asDriver()
            .do(onNext: { [unowned self] _ in
                self.timer.timerStar()
                self.view.endEditing(true)
            })

        viewModel = HCBindPhoneViewModel.init(socialUserInfo: socialUserInfo,
                                              input: (account: phoneInputOutlet.rx.text.orEmpty.asDriver(),
                                                      pass: smsCodeInputOutlet.rx.text.orEmpty.asDriver()),
                                              tap: (bindTap: bindDriver,
                                                    sendCodeTap: sendCodeDriver,
                                                    agreeTap: agreeObservable))
        
        viewModel.codeEnable.asDriver()
            .drive(getAuthorOutlet.rx.enabled)
            .disposed(by: disposeBag)
        
        viewModel.popSubject
            .subscribe(onNext: { [weak self] in
                HCHelper.share.isPresentLogin = false
                NotificationCenter.default.post(name: NotificationName.User.LoginSuccess, object: nil)
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    override func prepare(parameters: [String : Any]?) {
        socialUserInfo = (parameters!["model"] as! UMSocialUserInfoResponse)
    }
}

extension HCBindPhoneViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        keyBoardManager.move(coverView: bindOutlet, moveView: contentBgView)
        return true
    }
}

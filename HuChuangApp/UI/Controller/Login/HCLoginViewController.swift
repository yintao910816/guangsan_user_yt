//
//  HCLoginViewController.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxSwift

class HCLoginViewController: BaseViewController {

    @IBOutlet weak var accountOutlet: UILabel!
    @IBOutlet weak var passOutlet: UILabel!
    @IBOutlet weak var accountInputOutlet: UITextField!
    @IBOutlet weak var passInputOutlet: UITextField!
    
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var getAuthorOutlet: UIButton!
    @IBOutlet weak var phoneLoginOutlet: UIButton!
    @IBOutlet weak var idCardLoginOutlet: UIButton!
    @IBOutlet weak var forgetPassOutlet: UIButton!
    
    @IBOutlet weak var contentBgView: UIView!
    
    @IBOutlet weak var authorWidthCns: NSLayoutConstraint!
    @IBOutlet weak var authorHMarginCns: NSLayoutConstraint!
    
    private let loginTypeObser = Variable(LoginType.phone)
    
    private var timer: CountdownTimer!
    
    private var viewModel: LoginViewModel!
    
    private let keyBoardManager = KeyboardManager()
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func actions(_ sender: UIButton) {
        forgetPassOutlet.isHidden = sender == phoneLoginOutlet
        
        if sender == phoneLoginOutlet {
            loginTypeObser.value = .phone
            
            phoneLoginOutlet.backgroundColor = HC_MAIN_COLOR
            phoneLoginOutlet.setTitleColor(.white, for: .normal)
            idCardLoginOutlet.backgroundColor = RGB(231, 232, 233)
            idCardLoginOutlet.setTitleColor(RGB(36, 36, 36), for: .normal)
            
            accountOutlet.text = "手机号"
            passOutlet.text    = "验证码"
            accountInputOutlet.placeholder = "输入11位手机号码"
            passInputOutlet.placeholder    = "输入验证码"
            
            authorWidthCns.constant = 80
            authorHMarginCns.constant = 10
        }else if sender == idCardLoginOutlet {
            loginTypeObser.value = .idCard
            
            idCardLoginOutlet.backgroundColor = HC_MAIN_COLOR
            idCardLoginOutlet.setTitleColor(.white, for: .normal)
            phoneLoginOutlet.backgroundColor = RGB(231, 232, 233)
            phoneLoginOutlet.setTitleColor(RGB(36, 36, 36), for: .normal)
            
            accountOutlet.text = "身份证号"
            passOutlet.text    = "密码"
            accountInputOutlet.placeholder = "输入身份证号码"
            passInputOutlet.placeholder    = "输入密码"
            
            authorWidthCns.constant = 0
            authorHMarginCns.constant = 0
        }else if sender.tag == 1000 {
            let webVC = BaseWebViewController()
            webVC.url = "http://120.24.79.125/static/html/roujiyunbao.html"
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func setupUI() {
        keyBoardManager.registerNotification()
        
        timer = CountdownTimer.init(totleCount: 60)
        
        #if DEBUG
//        accountInputOutlet.text = "13995631675"
        accountInputOutlet.text = "13316213432"
        passInputOutlet.text  = "837546"
        #else
        accountInputOutlet.text = userDefault.loginPhone
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
        
        let loginDriver = loginOutlet.rx.tap.asDriver()
            .do(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            })
        let sendCodeDriver = getAuthorOutlet.rx.tap.asDriver()
            .do(onNext: { [unowned self] _ in
                self.timer.timerStar()
                self.view.endEditing(true)
            })

        viewModel = LoginViewModel.init(input: (account: accountInputOutlet.rx.text.orEmpty.asDriver(),
                                                pass: passInputOutlet.rx.text.orEmpty.asDriver(),
                                                loginType: loginTypeObser.asDriver()),
                                        tap: (loginTap: loginDriver,
                                              sendCodeTap: sendCodeDriver))
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
}

extension HCLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyBoardManager.move(coverView: loginOutlet, moveView: contentBgView)
        return true
    }
}

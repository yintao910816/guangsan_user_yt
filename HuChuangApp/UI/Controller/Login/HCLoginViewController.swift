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
    
    private var viewModel: LoginViewModel!
    
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
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func setupUI() {
        #if DEBUG
        accountInputOutlet.text = "18627844751"
        passInputOutlet.text  = "8888"
        #endif
    }
    
    override func rxBind() {
        let loginDriver = loginOutlet.rx.tap.asDriver()
            .do(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            })
        let sendCodeDriver = getAuthorOutlet.rx.tap.asDriver()
            .do(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            })

        viewModel = LoginViewModel.init(input: (account: accountInputOutlet.rx.text.orEmpty.asDriver(),
                                                pass: passInputOutlet.rx.text.orEmpty.asDriver(),
                                                loginType: loginTypeObser.asDriver()),
                                        tap: (loginTap: loginDriver,
                                              sendCodeTap: sendCodeDriver))
        
        viewModel.popSubject
            .subscribe(onNext: { [weak self] in
                HCHelper.share.isPresentLogin = false
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

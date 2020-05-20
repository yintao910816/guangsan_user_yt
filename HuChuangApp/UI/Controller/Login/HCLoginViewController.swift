//
//  HCLoginViewController.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class HCLoginViewController: BaseViewController {

    @IBOutlet weak var accountInputOutlet: UITextField!
    @IBOutlet weak var passInputOutlet: UITextField!
    
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var getAuthorOutlet: UIButton!
    @IBOutlet weak var contentBgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let loginTypeObser = Variable(LoginType.phone)
    
    private var timer: CountdownTimer!
    
    private var viewModel: LoginViewModel!
    
    private let keyBoardManager = KeyboardManager()
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        self.tableView.isHidden = true
    }
    
    @IBAction func actions(_ sender: UIButton) {
        if sender.tag == 1000 {
            let webVC = BaseWebViewController()
            webVC.url = "http://120.24.79.125/static/html/roujiyunbao.html"
            navigationController?.pushViewController(webVC, animated: true)
        }else if sender.tag == 1001 {
            self.tableView.isHidden = !self.tableView.isHidden
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func setupUI() {
        keyBoardManager.registerNotification()
        
        tableView.rowHeight = 40
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        timer = CountdownTimer.init(totleCount: 60)
        
        #if DEBUG
        accountInputOutlet.text = "13995631675"
//        accountInputOutlet.text = "13316213432"
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
        
        viewModel.recordAccountObser.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { _, model, cell in
                cell.selectionStyle = .none
                cell.textLabel?.text = model.account
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = .clear
                
                if cell.viewWithTag(100) == nil {
                    let line = UIView.init(frame: .init(x: 0, y: cell.height - 1, width: cell.width, height: 1))
                    line.backgroundColor = RGB(230, 230, 230)
                    line.tag = 100
                    cell.addSubview(line)
                }
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(HCLoginAccountModel.self)
            .asDriver()
            .do(onNext: { [unowned self] _ in
                self.tableView.isHidden = true
            })
            .map { $0.account }
            .drive(accountInputOutlet.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.reloadSubject.onNext(Void())
    }
}

extension HCLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyBoardManager.move(coverView: loginOutlet, moveView: contentBgView)
        return true
    }
}

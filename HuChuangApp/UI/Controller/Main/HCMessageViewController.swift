//
//  HCMessageViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2020/5/20.
//  Copyright © 2020 sw. All rights reserved.
//

import UIKit

class HCMessageViewController: BaseViewController {

    private var viewModel: HCMessageViewModel!
    private var webCtrl: BaseWebViewController!
    
    override func setupUI() {
        webCtrl = BaseWebViewController.init()
        webCtrl.view.frame = .init(x: 0, y: 0, width: view.width, height: view.height - (tabBarController?.tabBar.height ?? 0))
        addChild(webCtrl)
        view.addSubview(webCtrl.view)
        
        webCtrl.finishLoad = { [unowned self] in
            self.viewModel.finishLoadSubject.onNext(Void())
        }
    }
    
    override func rxBind() {
        viewModel = HCMessageViewModel.init(hudView: webCtrl.view)
        
        viewModel.webURLObser.asDriver()
            .skip(1)
            .drive(onNext: { [unowned self] in
                self.webCtrl.url = $0.setValue
                self.webCtrl.setupUI()
            })
            .disposed(by: disposeBag)
        
        viewModel.reloadSubject.onNext(Void())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        webCtrl.view.frame = view.bounds
    }
}

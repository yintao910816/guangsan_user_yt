//
//  HCTabBarViewController.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxSwift

class HCTabBarViewController: UITabBarController {

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.rx.notification(NotificationName.User.LoginSuccess)
            .subscribe(onNext: { [weak self] data in
               self?.selectedIndex = 0
            })
            .disposed(by: disposeBag)
    }

}

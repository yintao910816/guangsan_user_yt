//
//  HCEditUserIconViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/14.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class HCEditUserIconViewController: BaseViewController {

    @IBOutlet weak var userIconOutlet: UIImageView!
    
    private var viewModel: EditUserIconViewModel!
    
    @IBAction func actions(_ sender: UIButton) {
    }
    
    override func setupUI() {
        
    }
    
    override func rxBind() {
        viewModel = EditUserIconViewModel()
        
        viewModel.userIcon
            .bind(to: userIconOutlet.rx.image(forStrategy: .userIcon))
            .disposed(by: disposeBag)
        
        viewModel.reloadSubject.onNext(Void())
    }
}

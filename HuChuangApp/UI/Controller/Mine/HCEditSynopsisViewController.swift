//
//  HCEditSynopsisViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/14.
//  Copyright © 2019 sw. All rights reserved.
//  修改个性签名

import UIKit

class HCEditSynopsisViewController: BaseViewController {
    
    @IBOutlet weak var inputOutlet: UITextField!
    
    private var viewModel: EditSynopsisViewModel!

    override func setupUI() {
        
    }
    
    override func rxBind() {
        viewModel = EditSynopsisViewModel()
        
        viewModel.synopsis
            .bind(to: inputOutlet.rx.text)
            .disposed(by: disposeBag)
        
        addBarItem(title: "完成", titleColor: .white)
            .map{ [unowned self] in self.inputOutlet.text ?? "" }
            .asObservable()
            .bind(to: viewModel.finishEdit)
            .disposed(by: disposeBag)
        
        viewModel.popSubject
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.reloadSubject.onNext(Void())
    }

}

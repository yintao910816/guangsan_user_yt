//
//  HCEditBirthdayViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/14.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class HCEditBirthdayViewController: BaseViewController {
    
    @IBOutlet weak var inputOutlet: UITextField!
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    
    private var viewModel: EditBirthdayViewModel!
    
    @IBAction func dataChange(_ sender: UIDatePicker) {
        let fmt = DateFormatter.init()
        fmt.dateFormat = "yyyy-MM-dd"
        let s = fmt.string(from: datePickerOutlet.date)
        inputOutlet.text = s
    }
    
    override func setupUI() {
        
    }
    
    override func rxBind() {
        viewModel = EditBirthdayViewModel()
        
        viewModel.birthday
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

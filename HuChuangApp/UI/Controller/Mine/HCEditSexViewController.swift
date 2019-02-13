//
//  HCEditSexViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/14.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxDataSources

class HCEditSexViewController: BaseViewController {
    
    @IBOutlet weak var inputOutlet: UITextField!
    @IBOutlet weak var pickerOutlet: UIPickerView!
    
    private var viewModel: EditSexViewModel!
    
    override func setupUI() {
        UIPickerView.appearance().backgroundColor = RGB(208, 210, 217)
    }
    
    override func rxBind() {
        viewModel = EditSexViewModel()
        
        
        viewModel.sex
            .do(onNext: { [weak self] sex in
                let row = self?.viewModel.selectedRow(sex: sex)
                self?.pickerOutlet.selectRow(row ?? 0, inComponent: 0, animated: false)
            })
            .bind(to: inputOutlet.rx.text)
            .disposed(by: disposeBag)
        
        addBarItem(title: "完成", titleColor: .white)
            .map{ [unowned self] in self.inputOutlet.text ?? "" }
            .asObservable()
            .bind(to: viewModel.finishEdit)
            .disposed(by: disposeBag)
        
//        let stringPickerAdapter = RxPickerViewStringAdapter<[String]>.init(components: [],
//                                                                           numberOfComponents: { _,_,_ in 1 },
//                                                                           numberOfRowsInComponent: { (_, _, items, _) -> Int in
//                                                                            return items.count },
//                                                                           titleForRow: { (_, _, items, row, _) -> String? in
//                                                                            return items[row] })
        
//        viewModel.datasource.asObservable()
//            .bind(to: pickerOutlet.rx.items(adapter: stringPickerAdapter))
//            .disposed(by: disposeBag)
        
        viewModel.datasource
            .bind(to: pickerOutlet.rx.itemTitles) { (row, element) in
                return element
            }
            .disposed(by: disposeBag)
        
        pickerOutlet.rx.modelSelected(String.self)
            .map{ $0.first }
            .bind(to: inputOutlet.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.popSubject
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.reloadSubject.onNext(Void())
    }

}

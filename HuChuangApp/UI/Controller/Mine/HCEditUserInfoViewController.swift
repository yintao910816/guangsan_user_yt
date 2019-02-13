//
//  HCEditUserInfoViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/13.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class HCEditUserInfoViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: EditUserInfoViewModel!
    
    override func setupUI() {
        tableView.rowHeight = 50
        
        tableView.register(UINib.init(nibName: "EditUserInfoCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "EditUserInfoCellID")
    }
    
    override func rxBind() {
        viewModel = EditUserInfoViewModel()
                
        viewModel.datasource
            .bind(to: tableView.rx.items(cellIdentifier: "EditUserInfoCellID", cellType: EditUserInfoCell.self)) { _, model, cell in
                cell.model = model
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(EditUserInfoModel.self)
            .bind(to: viewModel.gotoEdit)
            .disposed(by: disposeBag)
        
        viewModel.reloadSubject.onNext(Void())
    }
}

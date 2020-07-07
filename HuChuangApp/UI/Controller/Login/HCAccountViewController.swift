//
//  HCAccountViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2020/6/3.
//  Copyright © 2020 sw. All rights reserved.
//

import UIKit

class HCAccountViewController: BaseViewController {

    private var tableView: UITableView!
    
    private var viewModel: HCAccountViewModel!
    
    override func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "切换账号"
        
        tableView = UITableView.init(frame: view.bounds, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 50
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
        
        tableView.register(UINib.init(nibName: "HCAccountListCell", bundle: nil), forCellReuseIdentifier: "HCAccountListCell")
    }
    
    override func rxBind() {
        viewModel = HCAccountViewModel.init(navigation: self.navigationController)
        
        viewModel.recordAccountObser.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "HCAccountListCell", cellType: HCAccountListCell.self)) { _, model, cell in
                cell.model = model
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(HCLoginAccountModel.self)
            .bind(to: viewModel.cellDidSelectedSubject)
            .disposed(by: disposeBag)
        
        viewModel.reloadSubject.onNext(Void())
    }
}

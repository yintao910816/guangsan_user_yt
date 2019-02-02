//
//  HCHomeViewController.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class HCHomeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var header: HomeHeader!
    
    private var viewModel: HomeViewModel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func setupUI() {
        header = HomeHeader()
        
        tableView.tableHeaderView = header.contentView
    }
    
    override func rxBind() {
        viewModel = HomeViewModel()
        
        viewModel.bannerModelObser.asDriver()
            .drive(header.bannerModelObser)
            .disposed(by: disposeBag)
        
        viewModel.noticeModelObser.asDriver()
            .drive(header.noticeModelObser)
            .disposed(by: disposeBag)
        
        viewModel.goodNewsModelObser.asDriver()
            .drive(header.goodNewsModelObser)
            .disposed(by: disposeBag)
        
        viewModel.reloadSubject.onNext(Void())
    }
    
}

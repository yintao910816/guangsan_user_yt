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

    private var header: HomeHeaderView!
    private var viewModel: HomeViewModel!
        
    override func setupUI() {
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        header = HomeHeaderView.init(frame: .init(x: 0, y: 0, width: tableView.width, height: 395))

        tableView.tableHeaderView = header
        
        tableView.register(UINib.init(nibName: "HomeFunctionContentCell", bundle: nil),
                           forCellReuseIdentifier: HomeFunctionContentCell_identifier)
    }
    
    override func rxBind() {
        viewModel = HomeViewModel()
                
        addBarItem(normal: "home_icon_bar", right: false)
            .drive(viewModel.pushCodeBarSubject)
            .disposed(by: disposeBag)
        
        addBarItem(normal: "home_icon_account")
            .drive(onNext: { HCHelper.presentLogin() })
            .disposed(by: disposeBag)
        
        viewModel.recomFuncData.asDriver()
            .drive(header.funcModelObser)
            .disposed(by: disposeBag)
        
        viewModel.datasource.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
                
        viewModel.bannerModelObser.asDriver()
            .drive(header.bannerModelObser)
            .disposed(by: disposeBag)
        
        tableView.prepare(viewModel, HomeFunctionSectionModel.self, showFooter: false, showHeader: true, isAddNoMoreContent: false)
        
        header.functionDidSelected
            .map{ [unowned self] in ($0, self.navigationController) }
            .bind(to: viewModel.functionItemDidSelected)
            .disposed(by: disposeBag)
        
        header.bannerDidSelected
            .bind(to: viewModel.bannerSelected)
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.setDataSource(self)
            .disposed(by: disposeBag)
        
        tableView.headerRefreshing()
    }
    
}

extension HCHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeFunctionContentCell_identifier) as! HomeFunctionContentCell
        cell.models = viewModel.datasource.value
        cell.itemDidSelected = { [unowned self] in self.viewModel.pushH5Subject.onNext($0) }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeFunctionContentCell.cellHeight(for: viewModel.maxFuncRow)
    }
}

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
        
        header = HomeHeaderView.init(frame: .init(x: 0, y: 0, width: tableView.width, height: HomeHeaderView.viewHieht(hasNotice: false)))
        tableView.tableHeaderView = header
        
        tableView.register(UINib.init(nibName: "HomeFunctionContentCell", bundle: nil),
                           forCellReuseIdentifier: HomeFunctionContentCell_identifier)
    }
    
    override func rxBind() {
        viewModel = HomeViewModel()
                        
        viewModel.recomFuncData.asDriver()
            .drive(header.funcModelObser)
            .disposed(by: disposeBag)
        
        viewModel.datasource.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.noticeModelObser.asDriver()
            .do(onNext: { [unowned self] in
                var rect = self.header.frame
                rect.size.height = HomeHeaderView.viewHieht(hasNotice: $0.count > 0)
                self.header.frame = rect
                self.tableView.tableHeaderView = self.header
            })
            .drive(header.noticeModelObser)
            .disposed(by: disposeBag)
                
        viewModel.bannerModelObser.asDriver()
            .drive(header.bannerModelObser)
            .disposed(by: disposeBag)
        
        tableView.prepare(viewModel, showFooter: false, showHeader: true, isAddNoMoreContent: false)
        
        header.functionDidSelected
            .map{ [unowned self] in ($0, self.navigationController) }
            .bind(to: viewModel.functionItemDidSelected)
            .disposed(by: disposeBag)
        
        header.bannerDidSelected
            .bind(to: viewModel.bannerSelected)
            .disposed(by: disposeBag)
        
        header.noticeDidSelected
            .subscribe(onNext: { [unowned self] _ in
                self.tabBarController?.selectedIndex = 1
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.setDataSource(self)
            .disposed(by: disposeBag)
        
        addBarItem(normal: "home_icon_bar", right: false)
            .drive(viewModel.pushCodeBarSubject)
            .disposed(by: disposeBag)
        
        HCHelper.share.userInfoHasReload
            .subscribe(onNext: { [unowned self] in
                let icon = $0.sexText == "男" ? "home_icon_account_boy" : "home_icon_account_girl"
                self.addBarItem(normal: icon)
                    .drive(onNext: {
                        self.navigationController?.pushViewController(HCAccountViewController(), animated: true)
//                        NoticesCenter.alert(message: "是否切换当前登录账号", cancleTitle: "切换", okTitle: "取消", callBackCancle: {
//                        HCHelper.presentLogin()
//                        })
                    })
                    .disposed(by: self.disposeBag)
            })
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

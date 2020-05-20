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
    @IBOutlet weak var navHeightCns: NSLayoutConstraint!
    @IBOutlet weak var navOutlet: UIView!
    @IBOutlet weak var unreadCountOutlet: UILabel!
    @IBOutlet weak var rightBarButton: TYClickedButton!
    @IBOutlet weak var unreadCountWidthCns: NSLayoutConstraint!
    @IBOutlet weak var unreadBgOutlet: UIView!

    private var header: HomeHeaderView!
    
    private var viewModel: HomeViewModel!

    @IBAction func actions(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            navigationController?.pushViewController(HCScanViewController(), animated: true)
        case 101:
            viewModel.messageListPublish.onNext(navigationController)
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if viewModel != nil { viewModel.refreshUnreadPublish.onNext(Void()) }
    }
    
    override func setupUI() {
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        navHeightCns.constant += LayoutSize.fitTopArea

        rightBarButton.setEnlargeEdge(top: 10, bottom: 10, left: 10, right: 10)
        
        header = HomeHeaderView.init(frame: .init(x: 0, y: 0, width: tableView.width, height: 395))

        tableView.tableHeaderView = header
        
        tableView.register(UINib.init(nibName: "HomeFunctionContentCell", bundle: nil),
                           forCellReuseIdentifier: HomeFunctionContentCell_identifier)
    }
    
    override func rxBind() {
        viewModel = HomeViewModel()
        
        viewModel.datasource.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.unreadCountObser
            .asDriver()
            .drive(onNext: { [unowned self] data in
                self.unreadCountOutlet.text = data.0
                self.unreadCountWidthCns.constant = data.1
                self.unreadBgOutlet.layer.cornerRadius = data.1 / 2.0
            })
            .disposed(by: disposeBag)
        
        viewModel.bannerModelObser.asDriver()
            .drive(header.bannerModelObser)
            .disposed(by: disposeBag)
                
//        viewModel.functionModelsObser.asDriver()
//            .drive(header.functionModelObser)
//            .disposed(by: disposeBag)
//
//        viewModel.noticeModelObser.asDriver()
//            .drive(header.noticeModelObser)
//            .disposed(by: disposeBag)
//
//        viewModel.goodNewsModelObser.asDriver()
//            .drive(header.goodNewsModelObser)
//            .disposed(by: disposeBag)
        
        tableView.prepare(viewModel, HomeFunctionSectionModel.self, showFooter: false, showHeader: true, isAddNoMoreContent: false)
        
        header.functionDidSelected
            .map{ [unowned self] in ($0, self.navigationController) }
            .bind(to: viewModel.functionItemDidSelected)
            .disposed(by: disposeBag)
        
//        header.noticeDidSelected
//            .bind(to: viewModel.noticeDidSelected)
//            .disposed(by: disposeBag)
//
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

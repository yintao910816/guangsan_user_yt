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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func setupUI() {
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        header = HomeHeaderView.init(frame: .init(x: 0, y: 0, width: tableView.width, height: 0))
        
        tableView.rowHeight = 60
        tableView.register(UINib.init(nibName: "ArticleCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "ArticleCellID")
    }
    
    override func rxBind() {
        viewModel = HomeViewModel()
        
        viewModel.bannerModelObser.asDriver()
            .drive(header.bannerModelObser)
            .disposed(by: disposeBag)
        
        viewModel.functionModelsObser.asDriver()
            .do(onNext: { [unowned self] data in
                var rect = self.header.frame
                rect.size.height = self.header.headerHeight(dataCount: data.count)
                self.header.frame = rect
                self.tableView.tableHeaderView = self.header
            })
            .drive(header.functionModelObser)
            .disposed(by: disposeBag)

        viewModel.noticeModelObser.asDriver()
            .drive(header.noticeModelObser)
            .disposed(by: disposeBag)
        
        viewModel.goodNewsModelObser.asDriver()
            .drive(header.goodNewsModelObser)
            .disposed(by: disposeBag)
        
        tableView.prepare(viewModel, HomeArticleModel.self, showFooter: false, showHeader: true, isAddNoMoreContent: false)

        viewModel.datasource.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "ArticleCellID", cellType: ArticleCell.self)) { _, model, cell in
                cell.model = model
            }
            .disposed(by: disposeBag)
        
        header.functionDidSelected
            .map{ [unowned self] in ($0, self.navigationController) }
            .bind(to: viewModel.functionItemDidSelected)
            .disposed(by: disposeBag)
        
        // 今日知识
        viewModel.columnModelObser.asDriver()
            .drive(header.colunmModelObser)
            .disposed(by: disposeBag)
        
        header.didSelectItemSubject
            .bind(to: viewModel.didSelectItemSubject)
            .disposed(by: disposeBag)
        
        viewModel.reloadSubject.onNext(Void())
    }
    
}

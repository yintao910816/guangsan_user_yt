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
    }
    
    override func setupUI() {
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        navHeightCns.constant += LayoutSize.fitTopArea

        header = HomeHeaderView.init(frame: .init(x: 0, y: 0, width: tableView.width, height: 0))
        
        tableView.rowHeight = 90
        tableView.register(UINib.init(nibName: "ArticleCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "ArticleCellID")
    }
    
    override func rxBind() {
        viewModel = HomeViewModel()
        
        viewModel.bannerModelObser.asDriver()
            .drive(header.bannerModelObser)
            .disposed(by: disposeBag)
        
        viewModel.headerDataCountObser.asDriver()
            .drive(onNext: { [weak self] data in
                guard let strongSelf = self else { return }
                var rect = strongSelf.header.frame
                rect.size.height = strongSelf.header.headerHeight(functionDataCount: data.0, noticeDataCount: data.1, goodNewsDataCount: data.2)
                strongSelf.header.frame = rect
                strongSelf.tableView.tableHeaderView = strongSelf.header
            })
            .disposed(by: disposeBag)
        
        viewModel.functionModelsObser.asDriver()
            .drive(header.functionModelObser)
            .disposed(by: disposeBag)

        viewModel.noticeModelObser.asDriver()
            .drive(header.noticeModelObser)
            .disposed(by: disposeBag)
        
        viewModel.goodNewsModelObser.asDriver()
            .drive(header.goodNewsModelObser)
            .disposed(by: disposeBag)
        
        tableView.prepare(viewModel, HomeArticleModel.self, showFooter: false, showHeader: true, isAddNoMoreContent: false)

//        viewModel.datasource.asDriver()
//            .drive(tableView.rx.items(cellIdentifier: "ArticleCellID", cellType: ArticleCell.self)) { _, model, cell in
//                cell.model = model
//            }
//            .disposed(by: disposeBag)
        
        header.functionDidSelected
            .map{ [unowned self] in ($0, self.navigationController) }
            .bind(to: viewModel.functionItemDidSelected)
            .disposed(by: disposeBag)
        
        header.noticeDidSelected
            .bind(to: viewModel.noticeDidSelected)
            .disposed(by: disposeBag)
        
        header.goodnewsDidSelected
            .bind(to: viewModel.goodnewsDidSelected)
            .disposed(by: disposeBag)

        // 今日知识
        viewModel.columnModelObser.asDriver()
            .drive(header.colunmModelObser)
            .disposed(by: disposeBag)
        
        header.didSelectItemSubject
            .bind(to: viewModel.didSelectItemSubject)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(HomeArticleModel.self).asDriver()
            .map{ [unowned self] in ($0, self.navigationController) }
            .drive(viewModel.todaySelected)
            .disposed(by: disposeBag)
        
//        viewModel.reloadSubject.onNext(Void())
        tableView.headerRefreshing()
    }
    
}

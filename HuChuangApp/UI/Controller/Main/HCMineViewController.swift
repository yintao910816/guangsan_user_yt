//
//  HCMineViewController.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxDataSources

class HCMineViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    private var header: MineHeaderView!
    private var footer: MineFooterView!
    
    private var viewModel: MineViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func setupUI() {
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
//        else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
       
        var headerHeight: CGFloat = 180
        if UIDevice.current.isX { headerHeight += 44 }
        header =  MineHeaderView.init(frame: .init(x: 0, y: 0, width: tableView.width, height: headerHeight))
        tableView.tableHeaderView = header
        
        footer = MineFooterView.init(frame: .init(x: 0, y: 0, width: tableView.width, height: 90))
        tableView.tableFooterView = footer
        
        tableView.rowHeight = 45
        tableView.register(UINib.init(nibName: "MineCell", bundle: Bundle.main), forCellReuseIdentifier: "MineCellID")
    }
    
    override func rxBind() {
        viewModel = MineViewModel()
        
        header.gotoEditUserInfo
            .bind(to: viewModel.gotoEditUserInfo)
            .disposed(by: disposeBag)
        
        let datasource = RxTableViewSectionedReloadDataSource<SectionModel<Int, MenuListItemModel>>.init(configureCell: { (_, tb, indexPath, model) -> UITableViewCell in
            let cell = tb.dequeueReusableCell(withIdentifier: "MineCellID") as! MineCell
            cell.model = model
            return cell
        })

        viewModel.datasource
            .bind(to: tableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        viewModel.userInfo
            .bind(to: header.userModel)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(MenuListItemModel.self)
            .bind(to: viewModel.cellDidSelected)
            .disposed(by: disposeBag)
        
        footer.loginOut = {
            HCHelper.share.clearUser()
            HCHelper.presentLogin()
        }
        
        header.yuyueOutlet.rx.tap.asDriver()
            .map{ H5Type.memberSubscribe }
            .drive(viewModel.pushH5Subject)
            .disposed(by: disposeBag)
        
        header.wenzhenOutlet.rx.tap.asDriver()
            .map{ H5Type.consultRecord }
            .drive(viewModel.pushH5Subject)
            .disposed(by: disposeBag)

        header.quanziOutlet.rx.tap.asDriver()
            .map{ H5Type.underDev }
            .drive(viewModel.pushH5Subject)
            .disposed(by: disposeBag)

        viewModel.reloadSubject.onNext(Void())
    }
}

extension HCMineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sepView = UIView()
        sepView.backgroundColor = .clear
        return sepView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

}

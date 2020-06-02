//
//  HCCircleViewController.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class HCClassRoomViewController: BaseViewController {

    private var viewModel: HCClassRoomViewModel!
    
    private var slideCtrl: TYSlideMenuController!
    
    override func setupUI() {
        view.backgroundColor = .white
                       
        slideCtrl = TYSlideMenuController()
        addChild(slideCtrl)
        view.addSubview(slideCtrl.view)
        
        slideCtrl.pageScroll = { [weak self] page in
            self?.viewModel.requestTodayListSubject.onNext(page)
        }
    }
    
    override func rxBind() {
        viewModel = HCClassRoomViewModel.init()
        
        viewModel.menuItemData
            .subscribe(onNext: { [weak self] menus in
                guard let strongSelf = self else { return }
                
                var ctrls: [HCClassRoomItemController] = []
                for idx in 0..<menus.count {
                    let ctrl = HCClassRoomItemController()
                    ctrl.pageIdx = idx
                    ctrl.view.backgroundColor = .white
                    ctrl.bind(viewModel: strongSelf.viewModel, canRefresh: true, canLoadMore: true, isAddNoMoreContent: false)
                    ctrl.didSelectedCallBack = { [weak self] in
                        let ctrl = HCArticleDetailViewController()
                        ctrl.prepare(parameters: HCArticleDetailViewController.preprare(model: $0))
                        self?.navigationController?.pushViewController(ctrl, animated: true)
                    }
                    
                    ctrls.append(ctrl)
                }
                
                strongSelf.slideCtrl.menuItems = menus
                strongSelf.slideCtrl.menuCtrls = ctrls
            })
            .disposed(by: disposeBag)
        
        viewModel.pageListData
            .subscribe(onNext: { [weak self] data in
                self?.slideCtrl.reloadList(listMode: data.0, page: data.1)
            })
            .disposed(by: disposeBag)
        
        viewModel.reloadSubject.onNext(Void())
    }
}

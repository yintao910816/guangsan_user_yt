//
//  HCClassRoomItemController.swift
//  HuChuangApp
//
//  Created by sw on 2019/9/27.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class HCClassRoomItemController: HCSlideItemController {

    private var tableView: UITableView!
    private var datasource: [HCArticleItemModel] = []
    
    public var didSelectedCallBack: ((HCArticleItemModel)->())?
            
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        tableView = UITableView.init()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = HCClassRoomListCell_height

        tableView.register(HCClassRoomListCell.self, forCellReuseIdentifier: HCClassRoomListCell_identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
    }
    
    override func reloadData(data: Any?) {
        if let dataModels = data as? [HCArticleItemModel] {
            datasource = dataModels
            tableView.reloadData()
        }
    }

    override func bind<T>(viewModel: RefreshVM<T>, canRefresh: Bool, canLoadMore: Bool, isAddNoMoreContent: Bool) {
  
        tableView.prepare(viewModel, showFooter: canLoadMore, showHeader: canRefresh, isAddNoMoreContent: isAddNoMoreContent)
    }
}

extension HCClassRoomItemController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: HCClassRoomListCell_identifier) as! HCClassRoomListCell)
        cell.model = datasource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        didSelectedCallBack?(datasource[indexPath.row])
    }
    
}

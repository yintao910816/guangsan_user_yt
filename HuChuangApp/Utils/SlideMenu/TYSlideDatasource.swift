//
//  TYSlideDatasource.swift
//  HuChuangApp
//
//  Created by sw on 2019/9/27.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation

struct TYSlideItemModel {
    var textColor: UIColor = RGB(51, 51, 51)
    var selectedTextColor: UIColor = RGB(255, 102, 149)
    var lineColor: UIColor = .red
    var textFont: UIFont = .font(fontSize: 14, fontName: .PingFMedium)
    
    var isSelected: Bool = false
    
    var dataModel: HomeColumnItemModel!
    
    public lazy var contentWidth: CGFloat = {
        return self.dataModel.name.getTexWidth(fontSize: 14, height: 30, fontName: FontName.PingFRegular.rawValue) + 30
    }()
    
    public static func creatSimple(for titles: [String]) ->[TYSlideItemModel] {
        var dataModels: [TYSlideItemModel] = []
        for title in titles {
            var itemModel = TYSlideItemModel()
            itemModel.isSelected = dataModels.count == 0
            
            let columItem = HomeColumnItemModel()
            columItem.name = title
            itemModel.dataModel = columItem
            
            dataModels.append(itemModel)
        }
        return dataModels
    }
}

extension TYSlideItemModel {
    /// 课堂数据    
    internal static func mapData(models: [HomeColumnItemModel]) ->[TYSlideItemModel] {
        var datas: [TYSlideItemModel] = []
        
        for idx in 0..<models.count {
            var m = TYSlideItemModel()
            m.dataModel = models[idx]
            m.isSelected = idx == 0
            datas.append(m)
        }
        
        return datas
    }
}

class HCSlideItemController: BaseViewController {
    
    public var pageIdx: Int = 0

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    public func reloadData(data: Any?) {
        
    }
    
    public func bind<T>(viewModel: RefreshVM<T>, canRefresh: Bool, canLoadMore: Bool, isAddNoMoreContent: Bool) {
        
    }
}

//
//  HCClassRoom.swift
//  HuChuangApp
//
//  Created by yintao on 2020/6/2.
//  Copyright © 2020 sw. All rights reserved.
//

import Foundation

class HCStoreAndStatusModel: HJModel {
    var store: Int = 0
    var status: Bool = false
}

class HCArticlePageDataModel: HJModel {

    var records: [HCArticleItemModel] = []
}

class HCArticleItemModel: HJModel {
    var id: String = ""
    var shopId: String = ""
    var title: String = ""
    var info: String = ""
    var author: String = ""
    var picPath: String = ""
    var content: String = ""
    var publishDate: String = ""
    var sort: Int = 0
    var channelId: Int = 0
    var createDate: String = ""
    var modifyDate: String = ""
    var creates: String = ""
    var modifys: String = ""
    var bak: String = ""
    var seoDescription: String = ""
    var seoKeywords: String = ""
    var code: String = ""
    var unitId: String = ""
    var del: String = ""
    var recom: String = ""
    var top: Bool = false
    var release: Bool = false
    var hrefUrl: String = ""
    var store: Int = 0
    var readNumber: Int = 0
    
    lazy var cellHeight: CGFloat = {
        
        var height: CGFloat = 85.0
        var titleH: CGFloat = self.title.getTextHeigh(fontSize: 14,
                                                      width: UIScreen.main.bounds.width - 92,
                                                      fontName: FontName.PingFRegular.rawValue)
        height += (titleH > 20 ? 20 : 0)
        
        var desH: CGFloat = self.title.getTextHeigh(fontSize: 12,
                                                    width: UIScreen.main.bounds.width - 92,
                                                    fontName: FontName.PingFRegular.rawValue)
        height += (desH > 17 ? 17 : 0)
        
        return height
    }()
    
    lazy var readCountText: String = {
        return "\(self.readNumber) 阅读"
    }()
    
    lazy var collectCountText: String = {
        return "\(self.store) 收藏"
    }()
    
    /// 模型转换
    public class func transform(model: HCSearchArticleItemModel) ->HCArticleItemModel {
        let m = HCArticleItemModel()
        m.id = "\(model.id)"
        m.hrefUrl = model.hrefUrl
        m.picPath = model.picPath
        m.title = model.title
        return m
    }
}

class HomeColumnItemModel: HJModel {
    var id: Int = 0
    var shopId: String = ""
    var parentId: String = ""
    var path: String = ""
    var name: String = ""
    var type: String = ""
    var url: String = ""
    var target: String = ""
    var sort: String = ""
    var createDate: String = ""
    var modifyDate: String = ""
    var creates: String = ""
    var modifys: String = ""
    var bak: String = ""
    var code: String = ""
    var unitId: String = ""
    var hide: Bool = false
    var del: Bool = false
    
    var isSelected: Bool = false
    
    lazy var cellSize: CGSize = {
        let width = self.name.getTexWidth(fontSize: 13, height: 20)
        return CGSize.init(width: width, height: 35)
    }()
    
    class func creatAllColum() ->HomeColumnItemModel {
        let model = HomeColumnItemModel()
        model.name = "全部"
        return model
    }
}

class HomeColumnModel: HJModel {
    var title: String = ""
    var content: [HomeColumnItemModel] = []
}

//
//  Home.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import HandyJSON

class HomeBannerModel: HJModel {
    
    var clickCount: String = ""
    var path: String = ""
    var id  : String = ""
    var updateTime: String = ""
    var title: String = ""
    var type: String = ""
    var createTime: String = ""
    var link: String = ""
    var order: String = ""
    var hospitalId: String = ""
    
    override func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &link, name: "url")
    }
}

extension HomeBannerModel: CarouselSource {
    
    var url: String? { return path }
}

class HomeNoticeModel: HJModel {
    
    var bak: String = ""
    var content: String = ""
    var createDate: String = ""
    var creates: String = ""
    var id: String = ""
    var modifyDate: String = ""
    var modifys: String = ""
    var title: String = ""
    var type: String = ""
    var unitId: String = ""
    var url: String = ""
    var validDate: String = ""
}

extension HomeNoticeModel: ScrollTextModel {
   
    var textContent: String {
        return content
    }
    
    var height: CGFloat { return 35 }
    
}

class HomeGoodNewsModel: HJModel {
    var appid: String = ""
    var name: String = ""
    var count: String = ""
    var deliver: String = ""
    var pid: String = ""
    var oid: String = ""
    var type: String = ""
    var mcardno: String = ""
    var rowid: String = ""
}

extension HomeGoodNewsModel: ScrollTextModel {
    
    var textContent: String {
        if type == "childbirth" {
            return "热烈庆祝\(name)于\(deliver)成功分娩"
        }
        return "未知类型"
    }
    
    var height: CGFloat { return 63 }
}


class HomeFunctionModel: HJModel {
    var bak: String = ""
    var code: String = ""
    var createDate: String = ""
    var creates: String = ""
    var functionUrl: String = ""
    var hide: String = ""
    var iconPath: String = ""
    var id: String = ""
    var modifyDate: String = ""
    var modifys: String = ""
    var name: String = ""
    var recom: String = ""
    var sort: String = ""
    var type: String = ""
    var unitId: String = ""
    var unitName: String = ""
}

class HomeArticleModel: HJModel {
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
}

class HomeColumnItemModel: HJModel {
    var id: String = ""
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
    
    
}

class HomeColumnModel: HJModel {
    var title: String = ""
    var content: [HomeColumnItemModel] = []
}

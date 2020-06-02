//
//  HCSearch.swift
//  HuChuangApp
//
//  Created by yintao on 2020/6/2.
//  Copyright © 2020 sw. All rights reserved.
//

import Foundation

class HCBaseSearchItemModel: HJModel {
    
}

class HCSearchCourseItemModel: HCBaseSearchItemModel {
    
}

class HCSearchArticleItemModel: HCBaseSearchItemModel {
    var author: String = ""
    var bak: String = ""
    var channelId: Int = 0
    var code: String = ""
    var content: String = ""
    var createDate: String = ""
    var creates: String = ""
    var del: Bool = false
    var hrefUrl: String = ""
    var id: Int = 0;
    var info: String = ""
    var linkTypes: Int = 0
    var linkUrls: String = ""
    var memberId: Int = 0
    var modifyDate: String = ""
    var modifys: String = ""
    var picPath: String = ""
    var publishDate: String = ""
    var readNumber: Int = 0
    var recom: Int = 0
    var release: Bool = true
    var seoDescription: String = ""
    var seoKeywords: String = ""
    var shopId: Int = 0
    var sort: Int = 0
    var store: Int = 0
    var title: String = ""
    var top: Bool = true
    var unitId: Int = 0
    
    lazy var readCountText: String = {
        return "\(self.readNumber) 阅读"
    }()
    
    lazy var collectCountText: String = {
        return "\(self.store) 收藏"
    }()
}

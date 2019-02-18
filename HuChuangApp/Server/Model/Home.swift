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
    
}

extension HomeGoodNewsModel: ScrollTextModel {
    
    var textContent: String {
        return "侧都能分两块三空间浪费你说打卡机开发能力健康三方就可能是电脑数据看妇科"
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

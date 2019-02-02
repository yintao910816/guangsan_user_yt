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
    
}

extension HomeNoticeModel: ScrollTextModel {
   
    var textContent: String {
        return "侧都能分两块三空间浪费你说打卡机开发能力健康三方就可能是电脑数据看妇科"
    }
    
    var height: CGFloat { return 59 }
    
}

class HomeGoodNewsModel: HJModel {
    
}

extension HomeGoodNewsModel: ScrollTextModel {
    
    var textContent: String {
        return "侧都能分两块三空间浪费你说打卡机开发能力健康三方就可能是电脑数据看妇科"
    }
    
    var height: CGFloat { return 63 }
}

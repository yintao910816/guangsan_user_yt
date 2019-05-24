//
//  AppAbout.swift
//  HuChuangApp
//
//  Created by sw on 24/05/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import HandyJSON

/// 监测版本更新
class AppVersionModel: HJModel {
    var apkName: String = ""
    var apkType: Int = 0
    var apkUrl: String = ""
    var appType: String = ""
    var bak: String = ""
    var createDate: String = ""
    var creates: String = ""
    var descriptionInfo: String = ""
    var id: String = ""
    var modifyDate: String = ""
    var modifys: String = ""
    var package_name: String = ""
    var type: Int = 0
    var umengKey: String = ""
    var umengSecret: String = ""
    var unitId: String = ""
    var updateApk: Int = 0
    var versionCode: String = ""
    var versionName: String = ""

    override func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &descriptionInfo, name: "description")
    }
}

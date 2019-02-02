//
//  HCUser.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import HandyJSON

class HCUserModel: HJModel {
    
    var account: String = ""
    var ip: String = ""
    var skin: String = ""
    var status: String = ""
    var modifyDate: String = ""
    var lastLogin: String = ""
    var creates: String = ""
    var modifys: String = ""
    var bak: String = ""
    var birthday: String = ""
    var sex: String = ""
    var synopsis: String = ""
    var bindDate: String = ""
    var mobileInfo: String = ""
    var unitName: String = ""
    var numbers: String = ""
    var identityCard: String = ""
    var unitId: String = ""
    var name: String = ""
    var enable: String = ""
    var hisNo: String = ""
    var visitCard: String = ""
    var uid: String = ""
    var token: String = ""
    var email: String = ""
    var environment: String = ""
    var age: String = ""
    var createDate: String = ""
    var headPath: String = ""
    
    override func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &uid, name: "id")
    }
    
}

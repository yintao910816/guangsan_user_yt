//
//  EditUserInfoModel.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/13.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation

struct EditUserInfoModel {
    
    var title: String = ""
    var desTitle: String = ""
    var iconUrl: String  = ""
    
    var isImg: Bool = false
    
    var controllerID: String = ""
    
    static func createModel(title: String,
                            controllerID: String,
                            desTitle: String = "",
                            iconUrl: String = "",
                            isImg: Bool = false) ->EditUserInfoModel {
        var model = EditUserInfoModel()
        model.controllerID = controllerID
        model.title = title
        model.desTitle = desTitle
        model.iconUrl  = iconUrl
        model.isImg    = isImg
        
        return model
    }
}

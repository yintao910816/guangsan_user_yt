//
//  BaseModel.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation

enum RequestCode: Int {
    /// 请求成功
    case success = 200
    /// 身份验证不通过，需要重新登录
    case invalid = 401
    /// 微信授权未绑定手机号
    case unBindPhone = 402
    /// 其它错误
    case badRequest
}

// MARK:
// MARK: 所有请求数据
class ResponseModel: HJModel{
    
    var code: Int = 0
    var message : String = ""
    
}

class DataModel<T>: ResponseModel {
    
    var data: T?
    
}

/// 只返回请求是否成功
class RequestResultModel: ResponseModel {
    
    var data: String = ""
}

//
//  SRUserAPI.swift
//  StoryReader
//
//  Created by 020-YinTao on 2016/11/25.
//  Copyright © 2016年 020-YinTao. All rights reserved.
//

import Foundation
import Moya

//MARK:
//MARK: 接口定义
enum API{
    /// 登录
    case login(mobile: String, smsCode: String)
    
    /// 首页banner
    case selectBanner()
    /// 首页功能列表
    case functionList()
}

//MARK:
//MARK: TargetType 协议
extension API: TargetType{
    
    var path: String{
        switch self {
        case .login(_):
            return "api/login/login"
        case .selectBanner():
            return "api/index/selectBanner"
        case .functionList():
            return "api/index/select"
        }
    }
    
    var baseURL: URL{ return APIAssistance.baseURL(API: self) }
    
    var task: Task {
        if let _parameters = parameters {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: _parameters, options: []) else {
                return .requestPlain
            }
            return .requestCompositeData(bodyData: jsonData, urlParameters: [:])
        }
        return .requestPlain
    }
    
    var method: Moya.Method { return APIAssistance.mothed(API: self) }
    
    var sampleData: Data{ return Data() }
    
    var validate: Bool { return false }
    
    var headers: [String : String]? {
        return ["token": userDefault.token,
                "Content-Type": "application/json; charset=utf-8",
                "Accept": "application/json",
                "unitId": "36"]
    }
    
}

//MARK:
//MARK: 请求参数配置
extension API {
    
    private var parameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case .login(let mobile, let smsCode):
            params["mobile"] = mobile
            params["smsCode"] = smsCode
        case .selectBanner():
            params["code"] = "banner"
        default:
            return nil
        }
        return params
    }
}


//func stubbedResponse(_ filename: String) -> Data! {
//    @objc class TestClass: NSObject { }
//
//    let bundle = Bundle(for: TestClass.self)
//    let path = bundle.path(forResource: filename, ofType: "json")
//    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
//}

//MARK:
//MARK: API server
let HCProvider = MoyaProvider<API>(plugins: [MoyaPlugins.MyNetworkActivityPlugin,
                                             RequestLoadingPlugin()]).rx

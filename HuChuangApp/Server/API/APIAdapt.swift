//
//  AppSetup.swift
//  StoryReader
//
//  Created by 020-YinTao on 2016/11/25.
//  Copyright © 2016年 020-YinTao. All rights reserved.
//

import Foundation

class AppSetup {
    
    static let instance = AppSetup()
    
    var requestParam: [String : Any] = [:]
    
    var unitId: String = "36"
    
    var HCProvider = MoyaProvider<API>(plugins: [MoyaPlugins.MyNetworkActivityPlugin,
                                                 RequestLoadingPlugin()]).rx
        
    public func resetProvider() {
        _ = HCProvider.deallocated
            .subscribe(onNext: { _ in
                PrintLog("释放 HCProvider")
            })
        
        HCProvider = MoyaProvider<API>(plugins: [MoyaPlugins.MyNetworkActivityPlugin,
        RequestLoadingPlugin()]).rx
    }
    
    /**
     版本号拼接到所有请求url
     不能超过1000
     */
    var urlVision: String{
        get{
            // 获取版本号
            let versionInfo = Bundle.main.infoDictionary
            let appVersion = versionInfo?["CFBundleShortVersionString"] as! String
            let resultString = appVersion.replacingOccurrences(of: ".", with: "")
            return resultString
        }
    }
    
    /**
     切换用户重新设置请求相关参数
     */
    public func resetParam() {
//                requestParam = [
//                    "uid": userDefault.uid,
//                    "token": userDefault.token
//        ]
        
        PrintLog("默认请求参数已改变：\(requestParam)")
    }
}

import Moya

struct APIAssistance {
        
//    private static let base   = "https://ivf.gy3y.com/hc-patients/"
//    private static let fileBase = "https://ivf.gy3y.com/hc-files/"

    private static let base   = "https://ivf.gy3y.com/hc-patient/"
    private static let fileBase = "https://ivf.gy3y.com/hc-files/"

    static public func baseURL(API: API) ->URL{
        switch API {
        case .uploadIcon(_):
            return URL(string: fileBase)!
        default:
            return URL(string: base)!
        }
    }
    
    /**
     请求方式
     */
    static public func mothed(API: API) ->Moya.Method{
        switch API {
        case .version, .selectFunc(_):
            return .get
        default:
            return .post
        }
    }
    
}

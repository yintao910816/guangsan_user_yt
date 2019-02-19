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
    /// 获取验证码
    case validateCode(mobile: String)
    /// 登录
    case login(mobile: String, smsCode: String)
    /// 获取用户信息
    case selectInfo()
    /// 修改用户信息
    case updateInfo(param: [String: String])
    /// 上传头像
    case uploadIcon(image: UIImage)
    /// 首页banner
    case selectBanner()
    /// 首页功能列表
    case functionList()
    /// api/index/goodNews
//    case goodNews
    /// 首页通知消息
    case noticeList(type: String, pageNum: Int, pageSize: Int)
    /// 今日知识
    case column(cmsCode: String)
    case article(id: String)
}

//MARK:
//MARK: TargetType 协议
extension API: TargetType{
    
    var path: String{
        switch self {
        case .validateCode(_):
            return "api/login/validateCode"
        case .login(_):
            return "api/login/login"
        case .selectInfo():
            return "api/member/selectInfo"
        case .updateInfo(_):
            return "api/member/updateInfo"
        case .uploadIcon(_):
            return "api/upload/imgSingle"
//            return "api/upload/fileSingle"
        case .selectBanner():
            return "api/index/selectBanner"
        case .functionList():
            return "api/index/select"
        case .noticeList(_):
            return "api/index/noticeList"
        case .column(_):
            return "api/index/column"
        case .article(_):
            return "api/index/article"
        }
    }
    
    var baseURL: URL{ return APIAssistance.baseURL(API: self) }
    
    var task: Task {
        switch self {
        case .uploadIcon(let image):
            let data = image.jpegData(compressionQuality: 0.6)!
            //根据当前时间设置图片上传时候的名字
            let date:Date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
            let dateStr:String = formatter.string(from: date)
            
            let formData = MultipartFormData(provider: .data(data), name: "file", fileName: dateStr, mimeType: "image/jpeg")
            return .uploadMultipart([formData])
        default:
            break
        }
        
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
        var contentType: String = "application/json; charset=utf-8"
        switch self {
        case .uploadIcon(_):
            contentType = "image/jpeg"
        default:
            break
        }
        
        let customHeaders: [String: String] = ["token": userDefault.token,
                                               "Content-Type": contentType,
                                               "Accept": "application/json",
                                               "unitId": "36"]
        return customHeaders
    }
    
}

//MARK:
//MARK: 请求参数配置
extension API {
    
    private var parameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case .validateCode(let mobile):
            params["mobile"] = mobile
        case .login(let mobile, let smsCode):
            params["mobile"] = mobile
            params["smsCode"] = smsCode
        case .updateInfo(let param):
            params = param
        case .selectBanner():
            params["code"] = "banner"
        case .noticeList(let type, let pageNum, let pageSize):
            params["type"] = type
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
        case .column(let cmsCode):
            params["cmsCode"] = cmsCode
        case .article(let id):
            params["id"] = id
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

//
//  SRUserAPI.swift
//  StoryReader
//
//  Created by 020-YinTao on 2016/11/25.
//  Copyright © 2016年 020-YinTao. All rights reserved.
//

import Foundation
import Moya

/*
 绑定用户    bindHos
 功能暂未开放    underDev
 喜报    goodnews
 消息中心    notification
 绑定成功    succBind
 公告    announce
 问诊记录    consultRecord
 我的预约    memberSubscribe
 我的收藏    memberCollect
 用户反馈    memberFeedback
 功能暂未开放 underDev
 **/

enum H5Type: String {
    /// 好孕消息
    case goodNews = "goodnews"
    /// 消息中心
    case notification = "notification"
    /// 通知消息
    case announce = "announce"
    /// 认证管理
    case bindHos = "bindHos"
    ///
    case succBind = "succBind"
    /// 问诊记录
    case consultRecord = "consultRecord"
    /// 我的预约
    case memberSubscribe = "memberSubscribe"
    /// 我的收藏
    case memberCollect = "memberCollect"
    /// 用户反馈
    case memberFeedback = "memberFeedback"
    /// cms功能：readNumber=阅读量,modifyDate=发布时间，hrefUrl=调整地址
    case hrefUrl = "hrefUrl"    
    /// 配偶信息
    case memberMate = "memberMate"
    /// 缴费记录
    case memberCharge = "memberCharge"
    /// 个人信息
    case memberInfo = "memberInfo"
    /// 电子就诊卡条码
    case myBarCode = "myBarCode"
    
    /// 开发中
    case underDev = "underDev"
}

//MARK:
//MARK: 接口定义
enum API{
    /// 向app服务器注册友盟token
    case UMAdd(deviceToken: String)

    /// 获取验证码
    case validateCode(mobile: String)
    /// 登录
    case login(mobile: String, smsCode: String)
    /// 获取用户信息
    case selectInfo
    /// 修改用户信息
    case updateInfo(param: [String: String])
    /// 上传头像
    case uploadIcon(image: UIImage)
    /// 首页banner
    case selectBanner
    /// 首页功能列表   是否推荐：空查所有，true 推荐，false 不推荐
    case functionList(isRecom: String)
    /// 好消息
    case goodNews
    /// 首页通知消息
    case noticeList(type: String, pageNum: Int, pageSize: Int)
    /// 获取未读消息
    case messageUnreadCount
    /// 今日知识
    case column(cmsCode: String)
    case article(id: String)
    
    /// 获取h5地址
    case unitSetting(type: H5Type)
    
    /// 检查版本更新
    case version
}

//MARK:
//MARK: TargetType 协议
extension API: TargetType{
    
    var path: String{
        switch self {
        case .UMAdd(_):
            return "api/umeng/add"
        case .validateCode(_):
            return "api/login/validateCode"
        case .login(_):
            return "api/login/login"
        case .selectInfo:
            return "api/member/selectInfo"
        case .updateInfo(_):
            return "api/member/updateInfo"
        case .uploadIcon(_):
            return "api/upload/imgSingle"
        case .selectBanner:
            return "api/index/selectBanner"
        case .functionList:
            return "api/index/selectType"
        case .noticeList(_):
            return "api/index/noticeList"
        case .messageUnreadCount:
            return "api/messageCenter/unread"
        case .goodNews:
            return "api/index/goodNews"
        case .column(_):
            return "api/index/column"
        case .article(_):
            return "api/index/article"
        case .unitSetting(_):
            return "api/index/unitSetting"
        case .version:
            return "api/apk/version"
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
        case .version:
            return .requestParameters(parameters: ["type": "ios", "packageName": "com.huchuang.guangsanuser"],
                                      encoding: URLEncoding.default)
        default:
            if let _parameters = parameters {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: _parameters, options: []) else {
                    return .requestPlain
                }
                return .requestCompositeData(bodyData: jsonData, urlParameters: [:])
            }
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
        PrintLog("request headers -- \(customHeaders)")
        return customHeaders
    }
    
}

//MARK:
//MARK: 请求参数配置
extension API {
    
    private var parameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case .UMAdd(let deviceToken):
            let infoDic = Bundle.main.infoDictionary
            let identif = infoDic?["CFBundleIdentifier"]
            
            params["deviceToken"] = deviceToken
            params["appPackage"] = identif
            params["appType"] = "ios"

        case .validateCode(let mobile):
            params["mobile"] = mobile
        case .login(let mobile, let smsCode):
            params["mobile"] = mobile
            params["smsCode"] = smsCode
        case .updateInfo(let param):
            params = param
        case .selectBanner:
            params["code"] = "banner"
        case .noticeList(let type, let pageNum, let pageSize):
            params["type"] = type
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
        case .column(let cmsCode):
            params["cmsCode"] = cmsCode
        case .article(let id):
            params["id"] = id
        case .unitSetting(let type):
            params["settingCode"] = type.rawValue
        
        case .functionList(let isRecom):
            params["isRecom"] = isRecom

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

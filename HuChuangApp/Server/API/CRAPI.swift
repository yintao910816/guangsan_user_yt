//
//  SRUserAPI.swift
//  StoryReader
//
//  Created by 020-YinTao on 2016/11/25.
//  Copyright © 2016年 020-YinTao. All rights reserved.
//

import Foundation
import Moya

/// 文章栏目编码
enum HCWebCmsCode: String {
    /// 科普
    case classRoom = "ff"
}

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
    /// 首诊信息
    case firstMessage = "firstMessage"
    /// 治疗信息
    case cureMessage = "cureMessage"
    /// 账号与安全
    case accountSecurity = "accountSecurity"
    /// 宣教指引
    case missionToGuide = "missionToGuide"
    /// 经期日记
    case menstrualDiary = "menstrualDiary"
    /// 预产期计算
    case dueDate = "dueDate"
    /// 孕妈日记
    case pregantDiary = "pregantDiary"
    
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
    /// 首页功能列表（下面子功能区域）   是否推荐：空查所有，true 推荐，false 不推荐
    case selectFuncType(isRecom: String, isRecomFunc: String)
    /// 首页主功能区
    case selectFunc(isRecom: String)
    /// 好消息
    case goodNews
    /// 首页通知消息
    case noticeList(type: String, pageNum: Int, pageSize: Int)
    /// 获取未读消息
    case messageUnreadCount
    
    /// 获取h5地址
    case unitSetting(type: H5Type)
    
    case allChannelArticle(cmsCode: HCWebCmsCode, pageNum: Int, pageSize: Int)
    /// 课堂
    case column(cmsType: HCWebCmsCode)
    /// 栏目文章列表
    case articlePage(cmsCode: HCWebCmsCode, id: Int, pageNum: Int, pageSize: Int)
    /// 文章当前收藏数量
    case storeAndStatus(articleId: String)
    /// 文章收藏取消
    case articelStore(articleId: String, status: Bool)

    /// 更新阅读量
    case increReading(id: String)
    
    /// 点击消息时调用，更新未读数
    case refreshMessageCenter

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
        case .login(_, _):
            return "api/login/login"
        case .selectInfo:
            return "api/member/selectInfo"
        case .updateInfo(_):
            return "api/member/updateInfo"
        case .uploadIcon(_):
            return "api/upload/imgSingle"
        case .selectBanner:
            return "api/index/selectBanner"
        case .selectFuncType(_, _):
            return "api/index/selectType"
        case .selectFunc(_):
            return "api/index/select"
        case .noticeList(_, _, _):
            return "api/index/noticeList"
        case .messageUnreadCount:
            return "api/messageCenter/unread"
        case .goodNews:
            return "api/index/goodNews"
        case .unitSetting(_):
            return "api/index/unitSetting"
            
        case .allChannelArticle(_, _, _):
            return "api/index/allChannelArticle"
        case .column(_):
            return "api/index/column"
        case .articlePage(_, _, _, _):
            return "api/index/articlePage"
        case .storeAndStatus(_):
            return "api/cms/storeAndStatus"
        case .articelStore(_):
            return "api/cms/store"

        case .increReading(_):
            return "api/index/increReading"
            
        case .refreshMessageCenter:
            return "api/messageCenter/batchReads"
            
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
        case .selectFunc(let isRecom):
            return .requestParameters(parameters: ["isRecom": isRecom],
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
        case .unitSetting(let type):
            params["settingCode"] = type.rawValue
        
        case .selectFuncType(let isRecom, let isRecomFunc):
            params["isRecom"] = isRecom
            params["isRecomFunc"] = isRecomFunc
        case .selectFunc(let isRecom):
            params["isRecom"] = isRecom
            
        case .allChannelArticle(let cmsCode, let pageNum, let pageSize):
            params["cmsCode"] = cmsCode.rawValue
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["unitId"] = "36"

        case .column(let cmsCode):
            params["cmsCode"] = cmsCode.rawValue
        case .articlePage(let cmsCode, let id, let pageNum, let pageSize):
            params["cmsCode"] = cmsCode.rawValue
            params["id"] = id
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
        case .storeAndStatus(let articleId):
            params["articleId"] = articleId
        case .articelStore(let articleId, let status):
            params["articleId"] = articleId
            params["status"] = status
            
        case .increReading(let id):
            params["id"] = id
        case .refreshMessageCenter:
            params["unitId"] = "36"

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
//let HCProvider = MoyaProvider<API>(plugins: [MoyaPlugins.MyNetworkActivityPlugin,
//                                             RequestLoadingPlugin()]).rx
let HCProvider = AppSetup.instance.HCProvider

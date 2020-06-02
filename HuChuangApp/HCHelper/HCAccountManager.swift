//
//  HCAccountManager.swift
//  HuChuangApp
//
//  Created by yintao on 2019/12/16.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift

class HCAccountManager {
        
    class func WeChatLogin() ->Observable<UMSocialUserInfoResponse?> {
        return Observable<UMSocialUserInfoResponse?>.create { obser -> Disposable in
            UMSocialManager.default()?.getUserInfo(with: .wechatSession, currentViewController: nil, completion: { (result, error) in
                if error != nil {
                    obser.onError(error!)
                }else {
                    obser.onNext(result as? UMSocialUserInfoResponse)
                }
                obser.onCompleted()
            })
            
            return Disposables.create { }
        }
    }
}

extension HCAccountManager {
    // 分享
    class func presentShare(thumbURL: Any, title: String, descr: String, webpageUrl: String) {
        let messageObject = UMSocialMessageObject.init()
        let shareObject = UMShareWebpageObject.shareObject(withTitle: title, descr: descr, thumImage: thumbURL)!
        shareObject.webpageUrl = webpageUrl
        messageObject.shareObject = shareObject
        
        PrintLog("分享链接：\(shareObject.webpageUrl)")
    UMSocialUIManager.setPreDefinePlatforms([NSNumber(integerLiteral:UMSocialPlatformType.wechatSession.rawValue),NSNumber(integerLiteral:UMSocialPlatformType.wechatTimeLine.rawValue)])

        UMSocialUIManager.showShareMenuViewInWindow { (platformType, info) in
            UMSocialManager.default()?.share(to: platformType, messageObject: messageObject, currentViewController: NSObject().visibleViewController!, completion: { (data, error) in
                if error != nil {
                    print(error)
                }else {
                    if let result = data as? UMSocialShareResponse {
                        PrintLog(result)
//                        NoticesCenter.alert(message: "分享成功")
                    }else {
                        PrintLog("未知结果")
                    }
                }
            })
        }
    }
    
    /// 拼接医生主页分享链接
    class func doctorHomeLink(forShare userId: String) ->String {
//        let urlString = "\(APIAssistance.baseH5Host)?from=groupmessage#/\(H5Type.doctorHome)?userId=\(userId)&share=1"
//        return urlString
        return ""
    }
    /// 拼接文章分享链接
    class func articleLink(forUrl url: String) ->String {
        return "\(url)?share=1&from=groupmessage"
    }
    /// App Store下载地址
    class func appstoreURL() ->String {
        let urlStr = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1454537873"
        return urlStr
    }
}

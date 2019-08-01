//
//  HCNotifications.swift
//  HuChuangApp
//
//  Created by sw on 13/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation

typealias NotificationName = Notification.Name

extension Notification.Name {
    
    public struct User {
        /**
         * 登录成功，需要重新拉取数据和重新向app后台上传umtoken的界面可接受此通知
         */
        static let LoginSuccess = Notification.Name(rawValue: "org.user.notification.name.loginSuccess")
    }
    
    public struct Pay {
        /// 微信支付成功
        static let wxPaySuccess = Notification.Name(rawValue: "org.user.notification.name.wxPaySuccess")
    }
}

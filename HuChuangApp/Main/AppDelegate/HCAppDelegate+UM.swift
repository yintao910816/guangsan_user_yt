//
//  HCAppDelegate+UM.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/26.
//  Copyright © 2019 sw. All rights reserved.
//

private let AppKey = "5c755523b465f5e0850002e0"
private let AppSecret = "kgvzh8shch25usnuur8fzvidbddyxxop"

import Foundation

extension HCAppDelegate {
   
    func setupUM(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if #available(iOS 10.0, *) {
            UMConfigure.initWithAppkey(AppKey, channel: "App Store")
            
            let entity = UMessageRegisterEntity()
            entity.types = Int(UMessageAuthorizationOptions.badge.rawValue) | Int(UMessageAuthorizationOptions.alert.rawValue)
            //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
     
            // 使用 UNUserNotificationCenter 来管理通知
            let center = UNUserNotificationCenter.current()
            //监听回调事件
            center.delegate = self
            
            UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (flag, error) in
                if flag == true {
                    PrintLog("UM注册成功")
                }else {
                    PrintLog("UM注册失败")
                }
            }
            
            //iOS 10 使用以下方法注册，才能得到授权
            center.requestAuthorization(options: [UNAuthorizationOptions.alert,UNAuthorizationOptions.badge,UNAuthorizationOptions.sound], completionHandler: { (granted:Bool, error:Error?) -> Void in
                if (granted) {
                    //点击允许
//                    PrintLog("注册通知成功")
//                    UserDefaults.standard.set(true, forKey: kReceiveRemoteNote)
                    //获取当前的通知设置，UNNotificationSettings 是只读对象，不能直接修改，只能通过以下方法获取
                    center.getNotificationSettings(completionHandler:{(settings:UNNotificationSettings) in
                        PrintLog( "UNNotificationSettings")
                    })
                } else {
                    //点击不允许
//                    UserDefaults.standard.set(false, forKey: kReceiveRemoteNote)
//                    PrintLog("注册通知失败")
                }
            })
        } else {
            // Fallback on earlier versions
            let type = UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue
            let set = UIUserNotificationSettings.init(types: UIUserNotificationType(rawValue: type), categories: nil)
            UIApplication.shared.registerUserNotificationSettings(set)
        }
        
    }
}

extension HCAppDelegate : UNUserNotificationCenterDelegate{
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        PrintLog("didRegister notificationSetting")
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        UMessage.registerDeviceToken(deviceToken)
        
        let data = deviceToken as NSData
        let token = data.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        
        PrintLog( token)
        
        let infoDic = Bundle.main.infoDictionary
        let identif = infoDic?["CFBundleIdentifier"]
        
        let infoD = ["umengDeviceToken": token, "packageName" : identif]
//        HttpRequestManager.shareIntance.HC_updateDeviceToken(infoDic: infoD as NSDictionary) { (success, msg) in
//            if success == false {
//                HCPrint(message: "上传token失败！")
//            }else{
//                HCPrint(message: "上传token成功！")
//            }
//        }
    }
    
    //收到远程推送消息
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        UMessage.didReceiveRemoteNotification(userInfo)
        self.receiveRemoteNotificationForbackground(userInfo: userInfo)
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let information = response.notification.request.content.userInfo
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.classForCoder()))! {
            UMessage.didReceiveRemoteNotification(information)
            self.receiveRemoteNotificationForbackground(userInfo: information)
        }else{
            //应用处于后台时的本地推送接受
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let information = notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.classForCoder()))! {
            UMessage.didReceiveRemoteNotification(information)
            self.receiveRemoteNotificationForbackground(userInfo: information)
        }else{
            //应用处于前台时的本地推送接受
        }
        //当应用处于前台时提示设置，需要哪个可以设置哪一个
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    
    func receiveRemoteNotificationForbackground(userInfo : [AnyHashable : Any]){
        PrintLog(userInfo)
        
        let message = userInfo["alert"] as? String ?? "alert"
        
//        let tabVC = self.window?.rootViewController as! MainTabBarController
//        let selVC = tabVC.selectedViewController as! UINavigationController
//
//        let alertController = UIAlertController(title: "新消息提醒",
//                                                message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "知道了", style: .cancel, handler: nil)
//        let okAction = UIAlertAction(title: "马上查看", style: .default, handler: {(action)->() in
//            let notificationType = userInfo["notificationType"] as? String  ?? ""
//            switch notificationType {
//            case "21" :
//                HCPrint(message: "21")
//                let url = userInfo["url"] as? String ?? "http://www.ivfcn.com"
//                let webVC = WebViewController()
//                webVC.url = url
//                selVC.pushViewController(webVC, animated: true)
//            case "22" :
//                HCPrint(message: "22")
//                selVC.pushViewController(ConsultRecordViewController(), animated: true)
//            case "23" :
//                HCPrint(message: "23")
//                let survey = userInfo["url"] as! String
//                let webVC = WebViewController()
//                webVC.url = survey
//                selVC.pushViewController(webVC, animated: true)
//            default :
//                HCPrint(message: "default")
//                selVC.pushViewController(MessageViewController(), animated: true)
//            }
//        })
//        alertController.addAction(cancelAction)
//        alertController.addAction(okAction)
        
//        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}
//
//  HCHelper.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import RxSwift

class HCHelper {
    
    enum AppKeys: String {
        /// app schame
        case appSchame = "ivf.gy3y.com"
    }
    
    static let share = HCHelper()
    
    typealias blankBlock = ()->()

    public let userInfoHasReload = PublishSubject<HCUserModel>()
    public var userInfoModel: HCUserModel?
    public var isPresentLogin: Bool = false
    
    public var enableWchatLoginSubjet = PublishSubject<Bool>()
    public var enableWchatLogin: Bool = false

    class func presentLogin(presentVC: UIViewController? = nil, _ completion: (() ->())? = nil) {
        HCHelper.share.isPresentLogin = true
        
        let loginSB = UIStoryboard.init(name: "HCLogin", bundle: Bundle.main)
        let loginControl = loginSB.instantiateViewController(withIdentifier: "loginControl")
        loginControl.modalPresentationStyle = .fullScreen
        if let presentV = presentVC {
            presentV.present(loginControl, animated: true, completion: completion)
        }else{
            NSObject().visibleViewController?.present(loginControl, animated: true, completion: completion)
        }
    }
    
    func clearUser() {
        userDefault.uid = noUID
        userDefault.token = ""
        
        userInfoModel = nil
    }
    
    class func saveLogin(user: HCUserModel) {
        userDefault.uid = user.uid
        userDefault.token = user.token
        
        PrintLog("地址111：\(AppSetup.instance.HCProvider)")
        AppSetup.instance.resetProvider()
        PrintLog("地址222：\(AppSetup.instance.HCProvider)")

        HCHelper.share.userInfoModel = user
        
        HCHelper.share.userInfoHasReload.onNext(user)
    }
}

import AVFoundation
extension HCHelper {
    
    // 相机权限
    class func checkCameraPermissions() -> Bool {
        
        let authStatus : AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.notDetermined {
            return false
        }else {
            return true
        }
    }
    
    class func authorizationForCamera(confirmBlock : @escaping blankBlock){
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
            DispatchQueue.main.async {
                if granted == true {
                    confirmBlock()
                }else{
                    NoticesCenter.alert(title: nil, message: "未能开启相机！")
                }
            }
        }
    }

}

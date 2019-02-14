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
    
    static let share = HCHelper()
    
    typealias blankBlock = ()->()

    public let userInfoHasReload = PublishSubject<HCUserModel>()
    public var userInfoModel: HCUserModel?
    public var isPresentLogin: Bool = false
    
    class func presentLogin() {
        HCHelper.share.isPresentLogin = true
        
        let loginSB = UIStoryboard.init(name: "HCLogin", bundle: Bundle.main)
        let loginControl = loginSB.instantiateViewController(withIdentifier: "loginControl")
        NSObject().visibleViewController?.present(loginControl, animated: true, completion: nil)
    }
    
    class func saveLogin(user: HCUserModel) {
        userDefault.uid = user.uid
        userDefault.token = user.token
        
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
            if granted == true {
                confirmBlock()
            }else{
                NoticesCenter.alert(title: nil, message: "未能开启相机！")
            }
        }
    }

}

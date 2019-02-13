//
//  HCHelper.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class HCHelper {
    
    static let share = HCHelper()
    
    var isPresentLogin: Bool = false
    
    class func presentLogin() {
        HCHelper.share.isPresentLogin = true
        
        let loginSB = UIStoryboard.init(name: "HCLogin", bundle: Bundle.main)
        let loginControl = loginSB.instantiateViewController(withIdentifier: "loginControl")
        NSObject().visibleViewController?.present(loginControl, animated: true, completion: nil)
    }
    
    class func saveLogin(user: HCUserModel) {
        userDefault.uid = user.uid
        userDefault.token = user.token
    }
}

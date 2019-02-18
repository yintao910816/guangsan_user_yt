//
//  UserDefault.swift
//  StoryReader
//
//  Created by 020-YinTao on 2016/11/23.
//  Copyright © 2016年 020-YinTao. All rights reserved.
//

import Foundation

let userDefault = UserDefaults.standard
let noUID = "0"

extension UserDefaults{

    var uid: String {
        get{
            guard let hcUID = (object(forKey: kUID) as? String) else {
                return noUID
            }
            return hcUID
        }
        set{
            set(newValue, forKey: kUID)
            synchronize()
        }
    }
    var token: String {
        get{
            guard let rtToken = (object(forKey: kToken) as? String) else {
                return ""
            }
            return rtToken
        }
        set{
            set(newValue, forKey: kToken)
            synchronize()
        }
    }
    
    var lanuchStatue: String {
        get {
            guard let statue = (object(forKey: kLoadLaunchKey) as? String) else {
                return ""
            }
            return statue
        }
        set {
            set(newValue, forKey: kLoadLaunchKey)
            synchronize()
        }
    }
    
}

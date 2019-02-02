//
//  BaseFilesOwner.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation

class BaseFilesOwner: NSObject {
    
    deinit {
        PrintLog("\(self) 已释放")
    }
}

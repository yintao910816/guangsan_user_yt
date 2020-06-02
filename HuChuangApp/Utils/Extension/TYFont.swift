//
//  TYFont.swift
//  HuChuangApp
//
//  Created by yintao on 2019/9/22.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation

enum FontName: String {
    /// 苹方-简 常规体
    case PingFRegular = "PingFangSC-Regular"
    /// 苹方-简 极细体
    case PingFUltralight = "PingFangSC-Ultralight"
    /// 苹方-简 细体
    case PingFLight = "PingFangSC-Light"
    /// 苹方-简 纤细体
    case PingFThin = "PingFangSC-Thin"
    /// 苹方-简 中黑体
    case PingFMedium = "PingFangSC-Medium"
    /// 苹方-简 中粗体
    case PingFSemibold = "PingFangSC-Semibold"
}

extension UIFont {
    
    class func font(fontSize: CGFloat, fontName: FontName = .PingFRegular) ->UIFont {
        guard let returnFont = UIFont.init(name: fontName.rawValue, size: fontSize) else {
            return UIFont.systemFont(ofSize: fontSize)
        }
        return returnFont
    }
}

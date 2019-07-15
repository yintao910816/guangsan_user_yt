//
//  Bundle+Extension.swift
//  StoryReader
//
//  Created by 020-YinTao on 2017/4/27.
//  Copyright © 2017年 020-YinTao. All rights reserved.
//

import Foundation

extension Bundle {
    
    /// 获取工程名字
    var projectName: String {
        get {
            return self.object(forInfoDictionaryKey: kCFBundleExecutableKey as String) as? String ?? ""
        }
    }
    
    /// 构建版本号
    var buildVersion: String {
        get {
            return self.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
        }
    }
    
    /// app版本号
    var version: String {
        get {
            return self.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        }
    }
    
    /// app 名称
    var appName: String {
        get {
            return self.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
        }
    }
    
    /// app bundle id
    var bundleIdentifier: String {
        get {
            return self.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        }
    }
    
    /// 获取int型版本号
    var intAppVersion: Int {
        get {
            let transFormVersion = transformVersion(version: version)
            guard let intVersion = NumberFormatter().number(from: transFormVersion)?.intValue else {
                return 0
            }
            return intVersion
        }
    }
    
    /// 与当前版本号比较
    func isNewest(version aVersion: String) ->Bool {
        let transFormVersion = transformVersion(version: aVersion)
        guard let intVersion = NumberFormatter().number(from: transFormVersion)?.intValue else {
            return true
        }
        return intAppVersion >= intVersion
    }
    
    private func transformVersion(version: String) ->String {
        let tempArr = version.components(separatedBy: ".")
        let tempString = tempArr.joined(separator: "")
        return tempString
    }
}

extension Bundle {
    
    func resource(fileName name: String,
                  ofType type: String = "png",
                  inDirectory dir: String = "Resources.bundle/",
                  subDirectory subDir: String = "images") ->String {
        return Bundle.main.path(forResource: name, ofType: type, inDirectory: dir + subDir) ?? ""
    }
}

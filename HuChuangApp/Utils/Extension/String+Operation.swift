//
//  String+Operation.swift
//  Potato
//
//  Created by sw on 13/06/2019.
//

import Foundation

extension String {
    
    /// 替换指定字符串
//    func replacingOccurrences(of target: String, with replacement: String) ->String {
//        
//        guard let targetRange = range(of: target) else {
//            return self
//        }
//        return replacingCharacters(in: targetRange, with: replacement)
//    }
}

/** 字符串操作相关
 var str = "Hello, playground"
 
 //String 与 NSString 转换  需要遵循严格的类型转化
 var strString: NSString = str as NSString
 var str2: String = String(strString)
 
 //字符串范围截取
 let num = "123.45"
 let deRange = num.range(of: ".")
 
 //FIXME:按某个字符串截取
 
 //截取小数点前字符(不包含小数点)  123
 let wholeNumber = num.prefix(upTo: deRange!.lowerBound)
 //截取小数点后字符(不包含小数点) 45
 let backNumber = num.suffix(from: deRange!.upperBound)
 //截取小数点前字符(包含小数点) 123.
 let wholeNumbers = num.prefix(upTo: deRange!.upperBound)
 //截取小数点后字符(包含小数点) .45
 let backNumbers = num.suffix(from: deRange!.lowerBound)
 
 //FIXME:删除字符串中的某部分  Ho
 str = "Hello"
 let startIndex = str.index(str.startIndex, offsetBy: 1)
 let endIndex = str.index(str.startIndex, offsetBy: 3)
 str.removeSubrange(startIndex...endIndex)
 //替换字符串  Hnewo
 var sig = "Hello"
 sig.replacingCharacters(in: startIndex...endIndex, with: "new")
 
 字符串插入
 let subString = “123456”
 subString.insert(Character.init("123"), at: subString.index(subString.startIndex, offsetBy: 1))  //在2后面插入123
 */

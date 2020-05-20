//
//  HCUser.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import HandyJSON

class HCUserModel: HJModel {
    
    var account: String = ""
    var ip: String = ""
    var skin: String = ""
    var status: String = ""
    var modifyDate: String = ""
    var lastLogin: String = ""
    var creates: String = ""
    var modifys: String = ""
    var bak: String = ""
    var birthday: String = ""
    var sex: Int = 1
    var synopsis: String = ""
    var bindDate: String = ""
    var mobileInfo: String = ""
    var unitName: String = ""
    var numbers: String = ""
    var identityCard: String = ""
    var unitId: String = ""
    var name: String = ""
    var enable: String = ""
    var hisNo: String = ""
    var visitCard: String = ""
    var uid: String = ""
    var token: String = ""
    var email: String = ""
    var environment: String = ""
    var age: String = ""
    var createDate: String = ""
    var headPath: String = ""
    
    var sexText: String {
        get { return sex == 1 ? "男" : "女" }
    }
        
    override func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &uid, name: "id")
    }
    
}

import SQLite

class HCLoginAccountModel {
        
    public var account: String = ""
    public var pwd: String = ""
    
    struct ExpressionKey {
        static let accountEx = Expression<String>("account")
        static let pwdEx = Expression<String>("pwd")
    }

    public func insert() {
        let filiter = HCLoginAccountModel.ExpressionKey.accountEx == account
        let setters = [HCLoginAccountModel.ExpressionKey.accountEx <- account,
                       HCLoginAccountModel.ExpressionKey.pwdEx <- pwd]
        DBQueue.share.insterOrUpdateQueue(filiter, setters, accountTB, HCLoginAccountModel.self)
    }
    
    public static func selectAll(result: @escaping (([HCLoginAccountModel]) ->())) {
        let filiter = HCLoginAccountModel.ExpressionKey.accountEx != ""
        DBQueue.share.selectQueue(filiter, accountTB, HCLoginAccountModel.self) { result(mapModel(query: $0)) }
    }
    
    private static func mapModel(query: Table?) -> [HCLoginAccountModel] {
        do {
            guard let db = HCLoginAccountModel.db else { return [HCLoginAccountModel]() }
            guard let t = query else {  return [HCLoginAccountModel]() }
            
            var datas = [HCLoginAccountModel]()
            for item in try db.prepare(t) {
                let model = HCLoginAccountModel();
                model.account = item[HCLoginAccountModel.ExpressionKey.accountEx]
                model.pwd = item[HCLoginAccountModel.ExpressionKey.pwdEx]

                datas.append(model)
            }
            return datas
            
        } catch {
            PrintLog("查询数据失败")
        }
        return [HCLoginAccountModel]()
    }

}

extension HCLoginAccountModel: DBOperation {
    
    static func dbBind(_ builder: TableBuilder) {
        builder.column(HCLoginAccountModel.ExpressionKey.accountEx)
        builder.column(HCLoginAccountModel.ExpressionKey.pwdEx)
    }
    
}

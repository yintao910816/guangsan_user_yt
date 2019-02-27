//
//  ScanViewModel.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/20.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift

class ScanViewModel: BaseViewModel, VMNavigation {
    
    let scanResultSubject = PublishSubject<String>()
    
    override init() {
        super.init()
        
        scanResultSubject
            .subscribe(onNext: { [weak self] in self?.dealScanResult(url: $0) })
            .disposed(by: disposeBag)
    }
    
    private func dealScanResult(url: String) {
//        let urlRegex = "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
//        let predt = NSPredicate.init(format: "SELF MATCHES %@", urlRegex)
//        if predt.evaluate(with: url){
//        }
        ScanViewModel.push(BaseWebViewController.self, ["url": "\(url)?app=ios&token=\(userDefault.token)"])
    }
}

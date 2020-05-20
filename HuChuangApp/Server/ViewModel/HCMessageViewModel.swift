//
//  HCMessageViewModel.swift
//  HuChuangApp
//
//  Created by yintao on 2020/5/20.
//  Copyright © 2020 sw. All rights reserved.
//

import Foundation
import RxSwift

class HCMessageViewModel: BaseViewModel {
    
    public var webURLObser = Variable(H5InfoModel())
    public let finishLoadSubject = PublishSubject<Void>()
    
    private var hudView: UIView!
    
    init(hudView: UIView) {
        super.init()
        
        self.hudView = hudView
        
        finishLoadSubject
            .subscribe(onNext: { [unowned self] in
                self.hud.noticeHidden()
            })
            .disposed(by: disposeBag)
        
        reloadSubject
            .subscribe(onNext: { [weak self] in self?.requestH5URL() })
        .disposed(by: disposeBag)
    }
    
    private func requestH5URL() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [unowned self] in
            self.hud.noticeLoading(inView: self.hudView)
        }
                
        HCProvider.request(.unitSetting(type: .notification))
            .map(model: H5InfoModel.self)
            .subscribe(onSuccess: { [weak self] in
                guard $0.setValue.count > 0 else { return }
                let url = "\($0.setValue)?token=\(userDefault.token)&unitId=\(AppSetup.instance.unitId)"
                $0.setValue = url
                self?.webURLObser.value = $0
            }) { _ in }
            .disposed(by: disposeBag)
    }
}

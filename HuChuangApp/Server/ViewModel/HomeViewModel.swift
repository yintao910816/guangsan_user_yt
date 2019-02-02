//
//  HomeViewModel.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel: BaseViewModel {
    
    override init() {
        super.init()
        
        reloadSubject.withLatestFrom(requestBanner())
            .subscribe(onNext: { [unowned self] data in
                print(data)
            })
            .disposed(by: disposeBag)
    }
    
    private func requestBanner() ->Observable<[HomeBannerModel]>{
        return HCProvider.request(.selectBanner())
            .map(models: HomeBannerModel.self)
            .asObservable()
    }
}

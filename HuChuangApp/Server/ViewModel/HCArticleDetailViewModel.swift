//
//  HCArticleDetailViewModel.swift
//  HuChuangApp
//
//  Created by yintao on 2019/12/19.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HCArticleDetailViewModel: BaseViewModel {
    
    private var articleModel: HCArticleItemModel!
    
    public let articleStatusObser = Variable(HCStoreAndStatusModel())
    public let storeEnable = Variable(false)

    init(articleModel: HCArticleItemModel,
         tap:(storeDriver: Driver<Bool>, shareDriver: Driver<Void>)) {
        super.init()
        
        self.articleModel = articleModel
        
        reloadSubject
            .subscribe(onNext: { [weak self] _ in
                self?.requestArticleStatus()
            })
            .disposed(by: disposeBag)
        
        tap.storeDriver
            ._doNext(forNotice: hud)
            .drive(onNext: { [unowned self] in
                self.storeEnable.value = false
                self.postChangeStatus(status: $0)
            })
            .disposed(by: disposeBag)
        
        tap.shareDriver
            .drive(onNext: { [unowned self] in
                let link = HCAccountManager.articleLink(forUrl: self.articleModel.hrefUrl)
                HCAccountManager.presentShare(thumbURL: self.articleModel.picPath,
                                              title: "您的孕期好帮手",
                                              descr: self.articleModel.title,
                                              webpageUrl: link)
            })
            .disposed(by: disposeBag)
    }
    
    private func requestArticleStatus() {
//        HCProvider.request(.storeAndStatus(articleId: articleModel.id))
//            .map(model: HCStoreAndStatusModel.self)
//            .asObservable()
//            .do(onNext: { [weak self] _ in self?.storeEnable.value = true })
//            .catchErrorJustReturn(HCStoreAndStatusModel())
//            .bind(to: articleStatusObser)
//            .disposed(by: disposeBag)
    }
    
    private func postChangeStatus(status: Bool) {
//        HCProvider.request(.articelStore(articleId: articleModel.id, status: status))
//            .mapResponse()
//            .subscribe(onSuccess: { [weak self] data in
//                guard let strongSelf = self else { return }
//                if data.code == RequestCode.success.rawValue {
//                    let statusModel = strongSelf.articleStatusObser.value
//                    statusModel.store = status ? statusModel.store + 1 : statusModel.store - 1
//                    statusModel.status = status
//                    
//                    strongSelf.articleStatusObser.value = statusModel
//                    
//                    strongSelf.hud.noticeHidden()
//                }else {
//                    strongSelf.hud.failureHidden(data.message)
//                }
//                
//                strongSelf.storeEnable.value = true
//            }) { [weak self] in
//                self?.hud.failureHidden(self?.errorMessage($0))
//                self?.storeEnable.value = true
//        }
//        .disposed(by: disposeBag)
    }
}

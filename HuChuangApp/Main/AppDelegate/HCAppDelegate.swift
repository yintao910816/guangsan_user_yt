//
//  AppDelegate.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class HCAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var deviceToken: String = ""
    
    var isAuthorizedPush: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        DbManager.dbSetup()
        
        setupUM(launchOptions: launchOptions)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.checkVersion()
            
//            SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
//            storeProductVC.delegate = self;
//            NSDictionary *dic = [NSDictionary dictionaryWithObject:@"1205952707" forKey:SKStoreProductParameterITunesItemIdentifier];
//            [storeProductVC loadProductWithParameters:dic completionBlock:^(BOOL result, NSError * _Nullable error) {
//            }];
//            [self presentViewController:storeProductVC animated:YES completion:nil];
        }
        return true
    }
}

import Alamofire
extension HCAppDelegate {
    
    private func checkVersion() {
        _ = HCProvider.request(.version)
            .map(model: AppVersionModel.self)
            .subscribe(onSuccess: { res in
                
                if Bundle.main.isNewest(version: res.versionName) == false
                {
                    NoticesCenter.alert(title: "有最新版本可以升级", message: "", cancleTitle: "取消", okTitle: "去更新", callBackOK: {
                        let storeProductVC = SKStoreProductViewController()
                        storeProductVC.delegate = self
                        storeProductVC.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: "1454537873"],
                                                   completionBlock:
                            { (flag, error) in
                                if flag
                                {
                                    NSObject().visibleViewController?.present(storeProductVC, animated: true, completion: nil)
                                }
                        })
                    })
                }
            }) { error in
                print("--- \(error) -- 已是最新版本")
            }
    }
}

extension HCAppDelegate: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}


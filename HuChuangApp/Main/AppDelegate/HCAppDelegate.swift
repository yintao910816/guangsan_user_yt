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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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


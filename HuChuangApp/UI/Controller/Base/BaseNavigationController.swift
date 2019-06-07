//
//  BaseNavigationController.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    /**
     * 是否开启右滑返回手势
     */
    var isSideBackEnable: Bool! {
        didSet {
            isSideBackEnable == true ? startSideBack() : stopSideBack()
        }
    }
    
    private func startSideBack() {
        interactivePopGestureRecognizer?.delegate = self
    }
    
    private func stopSideBack() {
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isSideBackEnable = true
        
        self.navigationBar.barTintColor   =  UIColor.white
        navigationBar.isTranslucent       = false
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor :UIColor.black]
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.children.count > 0
        { // 非根控制器
            viewController.hidesBottomBarWhenPushed = true
            
            let backButton : UIButton = UIButton(type : .system)
            backButton.setImage(UIImage(named :"navigationButtonReturn")?.withRenderingMode(.alwaysOriginal), for: .normal)
            backButton.setImage(UIImage(named :"navigationButtonReturnClick")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
            backButton.addTarget(self, action :#selector(backAction), for: .touchUpInside)
            backButton.sizeToFit()
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backButton)
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    //MARK
    //MARK: action
    @objc func backAction() {
        if let webVC = topViewController as? BaseWebViewController,
            webVC.webCanBack() == true
        {
            PrintLog("网页跳转返回")
        }else {
            popViewController(animated: true)
        }
    }
    
    deinit {
        PrintLog("\(self) ---- 已释放")
    }
    
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (viewControllers.count > 1 && isSideBackEnable)
    }
}

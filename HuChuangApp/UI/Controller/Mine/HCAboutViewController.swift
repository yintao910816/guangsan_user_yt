//
//  HCAboutViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2020/7/7.
//  Copyright © 2020 sw. All rights reserved.
//

import UIKit

class HCAboutViewController: BaseViewController {

    @IBOutlet weak var versionOutlet: UILabel!

    @IBAction func actions(_ sender: UIButton) {
        if sender.tag == 100 {
            // 服务协议
            let webVC = BaseWebViewController()
            webVC.url = "http://www.ivfcn.com/static/html/roujiyunbao.html"
            webVC.navigationItem.title = "服务协议"
            navigationController?.pushViewController(webVC, animated: true)
        }else if sender.tag == 101 {
            // 隐私政策
            let webVC = BaseWebViewController()
            webVC.url = "http://www.ivfcn.com/static/html/roujiyinsi.html"
            webVC.navigationItem.title = "隐私政策"
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
    
    override func setupUI() {
        versionOutlet.text = "柔济孕宝IOS版\(Bundle.main.version)"
    }
    
    override func rxBind() {
        
    }
}

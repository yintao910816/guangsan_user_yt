//
//  BaseWKWebViewViewController.swift
//  HuChuangApp
//
//  Created by sw on 14/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import WebKit

class BaseWKWebViewViewController: BaseViewController {

    var webView: WKWebView!

    lazy var hud: NoticesCenter = {
        return NoticesCenter()
    }()
    
    var url: String!{
        didSet{
            url = url + "?token=" + userDefault.token
        }
    }

    override func setupUI() {
        webView = WKWebView.init(frame: .zero, configuration: setWebConfiguration())
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        webView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
        
        guard let reqUrl = URL.init(string: url) else { return }
        
        let request = URLRequest.init(url: reqUrl)
        webView.load(request)
    }
    
    private func setWebConfiguration() ->WKWebViewConfiguration {
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
//        var jsStr = "sessionStorage.setItem('userInvalid')"
//        var userScript = WKUserScript.init(source: jsStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
//        userContentController.addUserScript(userScript)
//
//        jsStr = "sessionStorage.setItem('backHomeFnApi')"
//        userScript = WKUserScript.init(source: jsStr, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
//        userContentController.addUserScript(userScript)
//
//        jsStr = "sessionStorage.setItem('backToList')"
//        userScript = WKUserScript.init(source: jsStr, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
//        userContentController.addUserScript(userScript)

//        jsStr = "sessionStorage.setItem('isApp')"
//        userScript = WKUserScript.init(source: jsStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
//        userContentController.addUserScript(userScript)

        userContentController.add(self, name: "userInvalid")
//        userContentController.add(self, name: "backHomeFnApi")
//        userContentController.add(self, name: "backToList")
        userContentController.add(self, name: "isApp")
        
        webConfiguration.userContentController = userContentController
        
        return webConfiguration
    }
}

extension BaseWKWebViewViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        PrintLog("didStartProvisionalNavigation")
        hud.noticeLoading()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        PrintLog("didFinish")
        hud.noticeHidden()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        PrintLog("didFail -- \(error)")
        hud.failureHidden(error.localizedDescription)
    }
    
}

extension BaseWKWebViewViewController: WKUIDelegate {
    
}

extension BaseWKWebViewViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        PrintLog("WKScriptMessageHandler -- \(message.name)")
    }
}

extension BaseWKWebViewViewController {
    
    func userInvalid() {
        PrintLog("BaseWKWebViewViewController -- userInvalid")
    }
    
    func backHomeFnApi() {
        PrintLog("BaseWKWebViewViewController -- backHomeFnApi")
    }

    func backToList() {
        PrintLog("BaseWKWebViewViewController -- backToList")
    }

    func isApp() {
        PrintLog("BaseWKWebViewViewController -- isApp")
    }

}

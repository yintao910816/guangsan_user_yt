//
//  BaseWebViewController.swift
//  HuChuangApp
//
//  Created by sw on 13/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import JavaScriptCore

class BaseWebViewController: BaseViewController {

    var context : JSContext?

    lazy var hud: NoticesCenter = {
        return NoticesCenter()
    }()
    
    lazy var webView: UIWebView = {
        let w = UIWebView()
        w.backgroundColor = .clear
        w.scrollView.bounces = false
        w.delegate = self
        return w
    }()
    
    var url: String!{
        didSet{
            url = url + "?token=" + userDefault.token
        }
    }
    
    override func setupUI() {
        view.backgroundColor = .white
        if #available(iOS 11, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }

        view.addSubview(webView)
        
        webView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
        
        requestData()
    }

    private func requestData(){
        hud.noticeLoading()
        
        let request = URLRequest.init(url: URL.init(string: url)!)
        webView.loadRequest(request)
    }

    private func setTitle() {
        if let title = webView.stringByEvaluatingJavaScript(from: "document.title"){
            navigationItem.title = title
        }
    }

}

extension BaseWebViewController: UIWebViewDelegate{
   
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool{
        
        let s = request.url?.absoluteString
        if s == "app://reload"{
            webView.loadRequest(URLRequest.init(url: URL.init(string: url!)!))
            return false
        }
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        PrintLog("didStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        PrintLog("didFinishLoad")
        hud.noticeHidden()
        
        context = (webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext)
        
        let backHomeFnApi: @convention(block) () ->() = {[weak self]in
            DispatchQueue.main.async {
                PrintLog("h5 调用 - backHomeFnApi")
                
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
        context?.setObject(unsafeBitCast(backHomeFnApi, to: AnyObject.self), forKeyedSubscript: "backHomeFnApi" as NSCopying & NSObjectProtocol)
        
        let backToList: @convention(block) () ->() = { [weak self] in
            DispatchQueue.main.async {
                PrintLog("h5 调用 - backToList")
                
                if self?.webView.canGoBack == true {
                    self?.webView.goBack()
                }
            }
        }
        context?.setObject(unsafeBitCast(backToList, to: AnyObject.self), forKeyedSubscript: "backToList" as NSCopying & NSObjectProtocol)
        
        let userInvalid: @convention(block) () ->() = {
            DispatchQueue.main.async {
                PrintLog("h5 调用 - userInvalid")
                HCHelper.presentLogin()
            }
        }
        context?.setObject(unsafeBitCast(userInvalid, to: AnyObject.self), forKeyedSubscript: "userInvalid" as NSCopying & NSObjectProtocol)
        
        let isApp: @convention(block) () ->() = { [weak self] in
            PrintLog("暂时不用 - isApp")
        }
        context?.setObject(unsafeBitCast(isApp, to: AnyObject.self), forKeyedSubscript: "isApp" as NSCopying & NSObjectProtocol)
        
        let nativeOpenURL: @convention(block) () ->() = { [weak self] in
            PrintLog("暂时不用 - nativeOpenURL")
        }
        context?.setObject(unsafeBitCast(nativeOpenURL, to: AnyObject.self), forKeyedSubscript: "nativeOpenURL" as NSCopying & NSObjectProtocol)
        
        context?.exceptionHandler = {(context, value)in
            PrintLog(value)
        }
        
        setTitle()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        hud.failureHidden(error.localizedDescription)
    }
}


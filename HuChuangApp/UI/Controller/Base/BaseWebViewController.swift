//
//  BaseWebViewController.swift
//  HuChuangApp
//
//  Created by sw on 13/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import JavaScriptCore

import JXPhotoBrowser
import Kingfisher

class BaseWebViewController: BaseViewController {

    public var url: String = ""
    public var redirect_url: String?

    /// 是否需要根据h5获取标题
    public var needWebTitle: Bool = true
    
    private var context : JSContext?
    private var webTitle: String?
    
    private var needHud: Bool = true
    
    private var autoLoadRequest: Bool = true
    
    private var bridge: WebViewJavascriptBridge!
    
    public var startLoad:(()->())?
    public var finishLoad:(()->())?
    
    private var singleTap: UITapGestureRecognizer!
    
    private lazy var hud: NoticesCenter = {
        return NoticesCenter()
    }()
    
    private var webView: UIWebView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(autoLoadRequest: Bool) {
        self.init(nibName: nil, bundle: nil)
        
        self.autoLoadRequest = autoLoadRequest
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configWebView() {
        if webView != nil {
            webView.delegate = nil
            webView.removeFromSuperview()
            webView = nil
        }
        
        webView = UIWebView()
        webView.backgroundColor = .clear
        webView.scrollView.bounces = false
        webView.delegate = self
        view.addSubview(webView)
        
        if singleTap == nil {
            singleTap = UITapGestureRecognizer.init(target: self, action: #selector(signalTapAction))
            singleTap.cancelsTouchesInView = false
            singleTap.delegate = self
        }

        webView.addGestureRecognizer(singleTap)
        
        webView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }

        if #available(iOS 11, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }

        requestData()
    }
    
    @objc private func signalTapAction() {
        let pt = singleTap.location(in: webView)
        let imgURL = "document.elementFromPoint(\(pt.x), \(pt.y)).src"
        let urlToSave = webView.stringByEvaluatingJavaScript(from: imgURL)
//        PrintLog("ssssss - \(urlToSave ?? "")")
        guard let urlStr = urlToSave, url.count > 0 else {
            return
        }
        
        guard let url = URL(string: urlStr) else {
            return
        }
        
        let browser = TYImageBrower()
//        browser.imageV.setImage(urlStr)
        browser.show()
        
//        let browser = JXPhotoBrowser()
//
//        browser.numberOfItems = {
//            return 1
//        }
//
        PrintLog("图片地址：\(urlStr)")
        ImageDownloader.default.downloadImage(with: url, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, error, url, data) in
            browser.image = image
            PrintLog("图片大小：\(image?.size)")
        }
//
//        browser.show()
    }
    
    override func prepare(parameters: [String : Any]?) {
        guard let _url = parameters?["url"] as? String else {
            return
        }
        
        var charSet = CharacterSet.urlQueryAllowed
        charSet.insert(charactersIn: "#")
        let encodingURL = _url.addingPercentEncoding(withAllowedCharacters: charSet)
        
        webTitle = (parameters?["title"] as? String)
        url = encodingURL ?? ""
    }
    
    func webCanBack(_ goBack: Bool = true) -> Bool {
        if webView.canGoBack == true,
            goBack == true {
            webView.goBack()
            return true
        }
        return false
    }
    
    public func refreshWeb(needHud: Bool = true){
        self.needHud = needHud
        autoLoadRequest = true
        configWebView()
    }
    
    override func setupUI() {
        view.backgroundColor = .white
        
        configWebView()

        if #available(iOS 11, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
//        setupBridge()
        
        if webTitle?.count ?? 0 > 0 { navigationItem.title = webTitle }
                        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(wchatPayFinish),
                                               name: NotificationName.Pay.wxPaySuccess,
                                               object: nil)
    }

    @objc private func wchatPayFinish() {
        if let urlStr = redirect_url, let aUrlStr = urlStr.removingPercentEncoding, let aurl = URL.init(string: aUrlStr) {
            let mRequest = URLRequest.init(url: aurl)
            webView.loadRequest(mRequest)
            redirect_url = nil
        }
    }

    private func setupBridge() {
        WebViewJavascriptBridge.enableLogging()
        bridge = WebViewJavascriptBridge.init(forWebView: webView)
        bridge.setWebViewDelegate(self)
        bridge.registerHandler("appInfo") { [weak self] (data, responseCallBack) in
            PrintLog("appInfo - \(data) ")
            responseCallBack?(self?.stringForAppInfo() ?? "")
        }
    }
    
    private func requestData(){
        if !autoLoadRequest {
            return
        }
        
        if needHud {
            hud.noticeLoading()
        }
        
        if let requestUrl = URL.init(string: url) {
            let request = URLRequest.init(url: requestUrl)
            webView.loadRequest(request)
        }else {
            NoticesCenter.alert(message: url)
            hud.failureHidden("url错误")
        }
    }

    private func setTitle() {
        if let title = webView.stringByEvaluatingJavaScript(from: "document.title"), title.count > 0, needWebTitle == true {
            navigationItem.title = title
        }
    }

}

extension BaseWebViewController: UIWebViewDelegate{
   
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool{
        
        let s = request.url?.absoluteString
        PrintLog("shouldStartLoadWith -- \(String(describing: s))")

        if s == "app://reload"{
            webView.loadRequest(URLRequest.init(url: URL.init(string: url)!))
            return false
        }
        
        let urlString = request.url?.absoluteString
        let rs = "\(HCHelper.AppKeys.appSchame.rawValue)://".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        if urlString?.contains("wx.tenpay.com") == true && urlString?.contains("redirect_url=\(rs)") == false
        {
            let sep = s!.components(separatedBy: "redirect_url=")
            redirect_url = sep.last//sep.first(where: { !$0.contains("wx.tenpay.com") })
            let reloadUrl = sep.first(where: { $0.contains("wx.tenpay.com") })!.appending("&redirect_url=\(rs)")
            if let _url = URL.init(string: reloadUrl) {
                var mRequest = URLRequest.init(url: _url)
                mRequest.setValue("\(HCHelper.AppKeys.appSchame.rawValue)://", forHTTPHeaderField: "Referer")
                webView.loadRequest(mRequest)
            }
            return false
            
        }
        
//        if urlString?.contains("wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb") == true && (redirect_url ?? "").count > 0
//        {
//            var mRequest = URLRequest.init(url: redirect_url!)
//            mRequest.setValue("\(HCHelper.AppKeys.appSchame.rawValue)://", forHTTPHeaderField: "Referer")
//            webView.loadRequest(mRequest)
//            return false
//        }

        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        PrintLog("didStartLoad")
        startLoad?()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        PrintLog("didFinishLoad")
        hud.noticeHidden()
        
        finishLoad?()
        
        context = (webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext)

        // 设置标题
        let changeTitle: @convention(block) () ->() = {[weak self] in
            if self?.isKind(of: HCArticleDetailViewController.self) == true { return }
            guard let params = JSContext.currentArguments() else { return }
            PrintLog("h5 调用 - changeTitle")
            
            DispatchQueue.main.async {
                for idx in 0..<params.count {
                    if idx == 0 {
                        let _title = ((params[0] as AnyObject).toString()) ?? ""
                        PrintLog("h5 调用 - changeTitle -- \(_title)")
                        self?.navigationItem.title = _title
                    }
                }
            }
        }
        context?.setObject(unsafeBitCast(changeTitle, to: AnyObject.self), forKeyedSubscript: "changeTitle" as NSCopying & NSObjectProtocol)

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
                }else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        context?.setObject(unsafeBitCast(backToList, to: AnyObject.self), forKeyedSubscript: "backToList" as NSCopying & NSObjectProtocol)

        let userInvalid: @convention(block) () ->() = { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                PrintLog("h5 调用 - userInvalid")
                HCHelper.presentLogin(presentVC: strongSelf.navigationController, {
                    strongSelf.navigationController?.popToRootViewController(animated: true)
                })
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

        let appInfo: @convention(block) () ->(String) = { [weak self] in
            return self?.stringForAppInfo() ?? ""
        }
        context?.setObject(unsafeBitCast(appInfo, to: AnyObject.self), forKeyedSubscript: "appInfo" as NSCopying & NSObjectProtocol)

        if isKind(of: HCArticleDetailViewController.self) == false
        {
            setTitle()
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        hud.failureHidden(error.localizedDescription)
    }
}

extension BaseWebViewController {
    
    private func stringForAppInfo() ->String {
        let infoDic: [String : String] = ["app_version": Bundle.main.version,
                                          "app_name": Bundle.main.appName,
                                          "app_packge": Bundle.main.bundleIdentifier,
                                          "app_sign": "",
                                          "app_type": "ios"]
        guard JSONSerialization.isValidJSONObject(infoDic) else { return "" }
        guard let jsonData =  try? JSONSerialization.data(withJSONObject: infoDic, options: []) else { return "" }
        guard let jsonString =  String.init(data: jsonData, encoding: .utf8) else { return "" }
        PrintLog("app信息：\(jsonString)")
        return jsonString
    }
}

extension BaseWebViewController: UIGestureRecognizerDelegate {
  
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
}



class TYImageBrower: UIView {
    
    private var imageV = UIImageView()
    
    private var tapGes: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        imageV.clipsToBounds = true
        imageV.contentMode = .scaleAspectFit
        addSubview(imageV)
        
        tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        addGestureRecognizer(tapGes)
    }
    
    @objc private func tapAction() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { [weak self] in
            if $0 { self?.removeFromSuperview() }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var image: UIImage? {
        didSet {
            imageV.image = image
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageV.frame = bounds
    }
    
    public func show() {
        self.frame = .init(x: 0, y: 0, width: PPScreenW, height: PPScreenH)
        UIApplication.shared.keyWindow?.addSubview(self)
        
        alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1
        })
    }
}

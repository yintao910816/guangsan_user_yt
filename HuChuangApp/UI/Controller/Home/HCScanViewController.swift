//
//  HCScanViewController.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/20.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit
import AVKit

class HCScanViewController: BaseViewController {
    
    var viewModel: ScanViewModel!
    
    lazy var qRScanView: LBXScanView = {
        let _qRScanView = LBXScanView.init(frame: self.view.bounds, style: self.zhiFuBaoStyle())!
        return _qRScanView
    }()
    
    lazy var zxingObj: ZXingWrapper = {
        let videoView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        videoView.backgroundColor = .clear
        self.view.insertSubview(videoView, at: 0)
        let _zxingObj = ZXingWrapper.init(preView: videoView, block: { [weak self] (barcodeFormat, str, scanImg) in
            self?.scanResult(str ?? "")
        })
        return _zxingObj!
    }()
    
    //    lazy var remindLabel: UILabel = {
    //        let scanRect = LBXScanView.getZXingScanRect(withPreView: self.view, style: self.zhiFuBaoStyle())
    //
    //        let text = UILabel.init(frame: CGRect.init(x: 20, y: scanRect.origin.y + 20, width: self.view.bounds.width - 2 * 20, height: 20))
    //        text.textAlignment = .center
    //        text.text = "将扫描框对准二维码，即可自动扫描"
    //        text.font = UIFont.systemFont(ofSize: 15)
    //        text.textColor = .black //RGB(54, 54, 54)
    //        return text
    //    }()
    
    deinit {
        PrintLog("\(self) 释放了")
    }
    
    override func setupUI() {
        
    }
    
    override func rxBind() {
        viewModel = ScanViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "扫一扫"
        
        view.backgroundColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if canUseSystemCamera() == true && qRScanView.superview == nil {
            view.addSubview(qRScanView)
            
            //            view.addSubview(remindLabel)
            
            qRScanView.startDeviceReadying(withText: "正在启动摄像头...")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: { [weak self] in
                self?.zxingObj.start()
                self?.qRScanView.startScanAnimation()
                self?.qRScanView.stopDeviceReadying()
            })
        } else if canUseSystemCamera() == true && qRScanView.superview != nil {
            zxingObj.start()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if navigationController?.viewControllers.contains(self) == false {
            zxingObj.stop()
            
            qRScanView.stopScanAnimation()
        }
    }
    
    fileprivate func canUseSystemCamera() ->Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .restricted || authStatus == .denied {
            NoticesCenter.alert(title: "提示", message: "未能获取到摄像头")
            return false
        }
        return true
    }
    
    // 模仿支付宝
    func zhiFuBaoStyle() ->LBXScanViewStyle{
        //设置扫码区域参数
        let scanStyle = LBXScanViewStyle.init()
        scanStyle.centerUpOffset = 60
        scanStyle.xScanRetangleOffset = 30
        
        if (PPScreenH <= 480 ){
            //3.5inch 显示的扫码缩小
            scanStyle.centerUpOffset = 40
            scanStyle.xScanRetangleOffset = 20
        }
        
        scanStyle.notRecoginitonArea = RGB(0, 0, 0, 0.6)
        scanStyle.photoframeAngleStyle = .inner
        scanStyle.photoframeLineW = 2.0
        scanStyle.photoframeAngleW = 16
        scanStyle.photoframeAngleH = 16
        
        scanStyle.isNeedShowRetangle = false
        scanStyle.anmiationStyle = .netGrid
        
        //使用的支付宝里面网格图片
        scanStyle.animationImage = UIImage.init(named: "CodeScan.bundle/qrcode_scan_full_net")
        
        return scanStyle
    }
}

extension HCScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func scanResult(_ result: String) { viewModel.scanResultSubject.onNext(result) }
    
}

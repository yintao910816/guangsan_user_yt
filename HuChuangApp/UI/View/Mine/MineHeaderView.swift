//
//  MineHeader.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/13.
//  Copyright © 2019 sw. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class MineHeaderView: UIView {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var headerBgView: UIImageView!
    
    @IBOutlet weak var userIconOutlet: UIButton!
    @IBOutlet weak var nickNameOutlet: UILabel!
    @IBOutlet weak var sexOutlet: UILabel!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var yuyueOutlet: UserFunctionButton!
    @IBOutlet weak var wenzhenOutlet: UserFunctionButton!
    @IBOutlet weak var quanziOutlet: UserFunctionButton!
        
    @IBOutlet weak var shadowView: UIView!
    
    private var tap: UITapGestureRecognizer!

    public let userModel = PublishSubject<HCUserModel>()
    public let gotoEditUserInfo = PublishSubject<Void>()

    public let headerFuncPushH5 = PublishSubject<H5Type>()
    
    public var updateHeight: ((CGFloat)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = (Bundle.main.loadNibNamed("MineHeaderView", owner: self, options: nil)?.first as! UIView)
        addSubview(contentView)
        
        contentView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        if UIDevice.current.isX {
            var aframe = contentView.frame
            aframe.size.height += 44
            contentView.frame = aframe
        }
                    
        setupUI()
        rxBind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        tap = UITapGestureRecognizer.init()
        headerBgView.isUserInteractionEnabled = true
        headerBgView.addGestureRecognizer(tap)
        
        tap.rx.event
            .map{ _ in Void() }
            .bind(to: gotoEditUserInfo)
            .disposed(by: disposeBag)
    }
    
    private func rxBind() {
        yuyueOutlet.rx.tap.asDriver()
            .map{ H5Type.memberInfo }
            .drive(headerFuncPushH5)
            .disposed(by: disposeBag)
        
        wenzhenOutlet.rx.tap.asDriver()
            .map{ H5Type.memberMate }
            .drive(headerFuncPushH5)
            .disposed(by: disposeBag)

        quanziOutlet.rx.tap.asDriver()
            .map{ H5Type.fristMessage }
            .drive(headerFuncPushH5)
            .disposed(by: disposeBag)

        userModel.subscribe(onNext: { [unowned self] user in
            self.userIconOutlet.setImage(user.headPath, .userIcon)
            self.nickNameOutlet.text = user.name
            self.sexOutlet.text      = "性别：\(user.sexText)"
        })
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        shadowView.setCornerAndShaow()
        updateHeight?(shadowView.frame.maxY + 5)
    }
}

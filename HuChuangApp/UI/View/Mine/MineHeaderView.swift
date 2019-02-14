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
    
    @IBOutlet weak var userIconOutlet: UIButton!
    @IBOutlet weak var nickNameOutlet: UILabel!
    @IBOutlet weak var sexOutlet: UILabel!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var yuyueOutlet: UserFunctionButton!
    @IBOutlet weak var wenzhenOutlet: UserFunctionButton!
    @IBOutlet weak var quanziOutlet: UserFunctionButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var headerBgHeightCns: NSLayoutConstraint!
    @IBOutlet weak var headerTopCns: NSLayoutConstraint!
    
    let userModel = PublishSubject<HCUserModel>()
    let gotoEditUserInfo = PublishSubject<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = (Bundle.main.loadNibNamed("MineHeaderView", owner: self, options: nil)?.first as! UIView)
        addSubview(contentView)
        
        contentView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
        
        if UIDevice.current.isX {
            var frame = contentView.frame
            frame.size.height += 44
            contentView.frame = frame
            
            headerBgHeightCns.constant += 44
            headerTopCns.constant += 44
        }
        
        setupUI()
        rxBind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        yuyueOutlet.setTitle("我的预约", for: .normal)
        yuyueOutlet.setImage(UIImage.init(named: "mine_yuyue"), for: .normal)
        
        wenzhenOutlet.setTitle("我的问诊", for: .normal)
        wenzhenOutlet.setImage(UIImage.init(named: "mine_wenzen"), for: .normal)

        quanziOutlet.setTitle("我的圈子", for: .normal)
        quanziOutlet.setImage(UIImage.init(named: "mine_quanzi"), for: .normal)
    }
    
    private func rxBind() {
        tapGesture.rx.event
            .map{ _ in Void() }
            .bind(to: gotoEditUserInfo)
            .disposed(by: disposeBag)
        
        userModel.subscribe(onNext: { [unowned self] user in
            self.userIconOutlet.setImage(user.headPath, .userIcon)
            self.nickNameOutlet.text = user.name
            self.sexOutlet.text      = "性别：\(user.sexText)"
        })
            .disposed(by: disposeBag)
    }
}

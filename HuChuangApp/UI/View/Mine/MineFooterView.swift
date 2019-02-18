//
//  MineFooterView.swift
//  HuChuangApp
//
//  Created by yintao on 2019/2/18.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

class MineFooterView: UIView {
    
    public var loginOut: (() ->Void)?

    @IBOutlet var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        contentView = (Bundle.main.loadNibNamed("MineFooterView", owner: self, options: nil)?.first as! UIView)
        addSubview(contentView)
        
        contentView.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets.zero) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func loginOutAction(_ sender: UIButton) {
        loginOut?()
    }
}

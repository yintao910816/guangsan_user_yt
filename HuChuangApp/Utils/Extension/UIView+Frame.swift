//
//  UIView+Frame.swift
//  HuChuangApp
//
//  Created by sw on 02/02/2019.
//  Copyright © 2019 sw. All rights reserved.
//

import UIKit

extension UIView {
    
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin = .init(x: x, y: frame.origin.y)
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin = .init(x: frame.origin.x, y: y)
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = size
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = origin
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size = CGSize(width: width, height: frame.height)
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size = CGSize(width: frame.width, height: height)
        }
    }
}

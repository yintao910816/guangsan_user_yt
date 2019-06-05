//
//  PTClickedButton.swift
//  Potato
//
//  Created by sw on 09/04/2019.
//

import UIKit

class TYClickedButton: UIButton {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event)
        
        let rect = self.enlargedRect()
        if isHidden == true || isUserInteractionEnabled == false || rect.equalTo(self.bounds){
            return super.hitTest(point, with: event)
        }else {
            if rect.contains(point) {
                return self
            }else {
                return super.hitTest(point, with: event)
            }
        }
        
    }
    
    var top: NSNumber {
        get {
            return associatedObject(base: self, key: &topKey)
            { return 0 }
        }
        set {
            associateObject(base: self, key: &topKey, value: newValue)
        }
    }
    
    var bottom: NSNumber {
        get {
            return associatedObject(base: self, key: &bottomKey)
            { return 0 }
        }
        set {
            associateObject(base: self, key: &bottomKey, value: newValue)
        }
    }
    
    var left: NSNumber {
        get {
            return associatedObject(base: self, key: &leftKey)
            { return 0 }
        }
        set {
            associateObject(base: self, key: &leftKey, value: newValue)
        }
    }
    
    var right: NSNumber {
        get {
            return associatedObject(base: self, key: &rightKey)
            { return 0 }
        }
        set {
            associateObject(base: self, key: &rightKey, value: newValue)
        }
    }
    
    func setEnlargeEdge(top: Float, bottom: Float, left: Float, right: Float) {
        self.top = NSNumber.init(value: top)
        self.bottom = NSNumber.init(value: bottom)
        self.left = NSNumber.init(value: left)
        self.right = NSNumber.init(value: right)
    }
    
    func enlargedRect() -> CGRect {
        let top = self.top
        let bottom = self.bottom
        let left = self.left
        let right = self.right
        if top.floatValue >= 0, bottom.floatValue >= 0, left.floatValue >= 0, right.floatValue >= 0 {
            let pointSize = CGRect.init(x: self.bounds.origin.x - CGFloat(left.floatValue),
                                        y: self.bounds.origin.y - CGFloat(top.floatValue),
                                        width: self.bounds.size.width + CGFloat(left.floatValue) + CGFloat(right.floatValue),
                                        height: self.bounds.size.height + CGFloat(top.floatValue) + CGFloat(bottom.floatValue))
            return pointSize
        }
        else {
            return self.bounds
        }
    }
}

//extension PTClickedButton: SelfAware {
//
//    static func awake() {
//        swizzleMethod
//    }
//
//    private static let swizzleMethod: Void = {
//        let originalSelector = #selector(point(inside:with:))
//        let swizzledSelector = #selector(swizzled_point(inside:with:))
//
//        swizzlingForClass(UIViewController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
//    }()
//
//    @objc func swizzled_point(inside point: CGPoint, with event: UIEvent?) -> Bool {
////        print("swizzled_point")
////        return swizzled_point(inside: point, with: event)
////        BOOL result = [self swz_pointInside:point withEvent:event];
////        CGRect responseHitArea = [self responseHitArea];
////        BOOL ret = ( result
////            ||CGRectEqualToRect(responseHitArea, CGRectZero)
////            ||!self.isUserInteractionEnabled
////            ||self.isHidden);
////        if (ret) return result;
////        return CGRectContainsPoint(responseHitArea, point);
//        let result = swizzled_point(inside: point, with: event)
//        let responseHitArea = enlargedRect()
//        let ret = (result || !isUserInteractionEnabled || isHidden)
//        if ret { return result }
//
//        return responseHitArea.contains(point)
//    }
//
//    /**
//     /*!
//     @method 可以响应点击事件的rect
//     */
//     - (CGRect)responseHitArea {
//     CGRect extendedHitArea = [objc_getAssociatedObject(self, @selector(extendedHitArea)) CGRectValue];
//     if (!CGRectEqualToRect(extendedHitArea, CGRectZero)) {
//     return                       CGRectMake(
//     self.bounds.origin.x-extendedHitArea.origin.x,
//     self.bounds.origin.y-extendedHitArea.origin.y,
//     self.bounds.size.width+extendedHitArea.origin.x+extendedHitArea.size.width,
//     self.bounds.size.height+extendedHitArea.origin.y+extendedHitArea.size.height);
//
//     } else {
//     return self.bounds;
//     }
//     }
//
//     */
//}

func associatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        if let associated = objc_getAssociatedObject(base, key)
            as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated,
                                 .OBJC_ASSOCIATION_RETAIN)
        return associated
}
func associateObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
    objc_setAssociatedObject(base, key, value,
                             .OBJC_ASSOCIATION_RETAIN)
}

private var topKey: UInt8 = 0
private var bottomKey: UInt8 = 0
private var leftKey: UInt8 = 0
private var rightKey: UInt8 = 0


//protocol SelfAware: class {
//    static func awake()
//    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector)
//}
//
//extension SelfAware {
//
//    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
//        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
//        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
//        guard (originalMethod != nil && swizzledMethod != nil) else {
//            return
//        }
//        if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
//            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
//        } else {
//            method_exchangeImplementations(originalMethod!, swizzledMethod!)
//        }
//    }
//}
//
//class NothingToSeeHere {
//    static func harmlessFunction() {
//        let typeCount = Int(objc_getClassList(nil, 0))
//        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
//        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
//        objc_getClassList(autoreleasingTypes, Int32(typeCount))
//        for index in 0 ..< typeCount {
//            (types[index] as? SelfAware.Type)?.awake()
//        }
//        types.deallocate()
//    }
//}
//extension UIApplication {
//    private static let runOnce: Void = {
//        NothingToSeeHere.harmlessFunction()
//    }()
//    override open var next: UIResponder? {
//        UIApplication.runOnce
//        return super.next
//    }
//}

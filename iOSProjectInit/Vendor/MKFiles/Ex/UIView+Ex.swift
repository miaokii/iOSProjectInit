//
//  UIView+Ex.swift
//  healthpassport
//
//  Created by fighter on 2019/10/17.
//  Copyright © 2019 fighter. All rights reserved.
//

import UIKit

extension UIWindow {
    var topController: UIViewController? {
        let rootvc = kWindow.rootViewController
        if let nav = rootvc as? UINavigationController {
            return nav.topViewController
        } else if let tabbarVC = rootvc as? UITabBarController, let controller = tabbarVC.selectedViewController {
            if let nav = controller as? UINavigationController, let navRoot = nav.topViewController {
                return navRoot
            }
            return controller
        } else {
            return rootvc
        }
    }
}

extension UIView {
    var contrller: UIViewController? {
        get {
            var nextResponder: UIResponder?
            nextResponder = next
            repeat {
                if nextResponder?.isKind(of: UIViewController.self) == true {
                    return (nextResponder as! UIViewController)
                }else {
                    nextResponder = nextResponder?.next
                }
            } while nextResponder != nil
            return nil
        }
    }
    
    func removeAllSubviews() {
        subviews.forEach { subView in
            subView.removeFromSuperview()
        }
    }
    
    func addTapClosure(_ closure: @escaping ((UITapGestureRecognizer)->Void)) {
        let tap = UITapGestureRecognizer.init()
        tap.addTarget(self, action: #selector(tapActionSender))
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
        tapClosure = closure
    }
    
    @objc private func tapActionSender(_ tap: UITapGestureRecognizer) {
        tapClosure?(tap)
    }
    
    private static var tapClosureKey: UInt = 0
    private var tapClosure: ((UITapGestureRecognizer)->Void)? {
        set {
            objc_setAssociatedObject(self, &Self.tapClosureKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get {
            objc_getAssociatedObject(self, &Self.tapClosureKey)  as? (UITapGestureRecognizer)->Void ?? nil
        }
    }
}

// MARK: - UIView
extension UIView {
    /// 切圆角，确定frame后调用
    /// - Parameters:
    ///   - corners: 要切的角
    ///   - radius: 圆角值
    public func round(corners: UIRectCorner = UIRectCorner.allCorners, radius: CGFloat = -1) {
        let r = radius == -1 ? min(frame.width, frame.height) / 2 : radius
        round(corners: corners, size: CGSize.init(width: r, height: r))
    }
    
    /// 切圆角，确定frame后调用
    /// - Parameters:
    ///   - corners: 要切的角
    ///   - size: 圆角值
    public func round(corners: UIRectCorner = UIRectCorner.allCorners, size: CGSize) {
        layer.mask = nil
        let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: size)
        defer {
            bezierPath.close()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        layer.mask = shapeLayer
        return
    }
}

// MARK: UIView 快照
extension UIView {
    func snapshot(scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}

extension UIView {
    /// 设置阴影
    /// - Parameters:
    ///   - color: 阴影的颜色，默认灰色
    ///   - radius: 阴影的模糊度，默认为5。当它的值是0的时候，阴影就和视图一样有一个非常确定的边界线。
    ///   当值越来越大的时候，边界线看上去就会越来越模糊和自然
    ///   - offset: 阴影的方向和距离，CGSize值，宽度控制阴影横向位移，高度控制阴影纵向位移，默认(4，4)
    ///   即横向阴影向右，宽度为4，纵向阴影向下，高度为4
    ///   - opacity: 透明度 0-1，默认0.2
    func setShadow(color: UIColor = .gray,
                   radius: CGFloat = 5,
                   offset: CGSize = .init(width: 4, height: 4),
                   opacity: Float = 0.2) {
        
        guard frame.size != .zero else {
            return
        }
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity

        // 防止离屏渲染
        layer.shadowPath = UIBezierPath.init(roundedRect: bounds, cornerRadius: radius).cgPath
    }
    
    func shadow(color: UIColor = .lightGray,
                opacity: Float = 0.5,
                radius: CGFloat = 5,
                offset: CGSize = .zero) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        clipsToBounds = false
    }
    
    func cancelShadow() {
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero
        layer.shadowRadius = 0
    }
}

extension UIView {
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            frame = CGRect(x: frame.minX, y: newValue - frame.height, width: frame.width, height: frame.height)
        }
    }
    
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            frame.size.width = newValue - frame.origin.x
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    
    var centerX: CGFloat {
        set {
            center.x = newValue
        }
        
        get{
            return center.x
        }
    }
    
    var centerY: CGFloat {
        set {
            center.y = newValue
        }
        
        get {
            return center.y
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            return layer.shadowColor != nil ? UIColor(cgColor: layer.shadowColor!) : nil
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    var shadowPath: CGPath? {
        get {
            return layer.shadowPath
        }
        set {
            layer.shadowPath = newValue
        }
    }
    
    func snapshot(rect: CGRect = CGRect.zero, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    func shake(offset:CGFloat = 5, vertical: Bool = false, duration: CGFloat = 0.25) {
        /**
        // 偏移值
        let t: CGFloat = 5.0
        // 左摇
        let translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0)
        // 右摇
        let translateRight = CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0)
        // 执行动画 重复动画且执行动画回路
        transform = translateLeft
        UIView.animate(withDuration: 0.07, delay: 0, options: [.autoreverse, .repeat]) {
            UIView.setAnimationRepeatCount(2)
            self.transform = translateRight
        } completion: { finish in
            if finish {
                UIView.animate(withDuration: 0.05, delay: 0, options: .beginFromCurrentState) {
                    self.transform = CGAffineTransformIdentity
                }
            }
        }
         */
        
        let keyPath = vertical ? "transform.translation.y" : "transform.translation.x"
        
        let animation = CAKeyframeAnimation.init(keyPath: keyPath)
        animation.values = [0, -offset/2, offset/2, -offset, offset, offset/2, -offset/2, 0]
        animation.keyTimes = [0, .init(floatLiteral: 1/6.0),
                              .init(floatLiteral: 2/6.0),
                              .init(floatLiteral: 3/6.0),
                              .init(floatLiteral: 4/6.0),
                              .init(floatLiteral: 5/6.0),
                              .init(floatLiteral: 1.0)]
        animation.timingFunctions = [
            .init(name: .easeOut),
            .init(name: .easeOut),
            .init(name: .easeOut),
            .init(name: .easeOut),
            .init(name: .easeOut),
            .init(name: .easeOut),
        ]
        animation.duration = 0.5
        self.layer.addAnimation(animation)
    }
}

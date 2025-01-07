//
//  HUD.swift
//  SwiftHUD
//
//  Created by yoctech on 2024/1/17.
//

import UIKit

/// MBProgressHUD的封装类
/// 同时适配了暗黑模式
class HUD: NSObject {
    
    /// 进度条类型
    enum HUDDeterminateStyle {
        /// 环形
        case normal
        /// 内切环形
        case annular
        /// 水平进度条
        case horizontalBar
    }
    
    /// HUD类型
    enum HUDContentType {
        /// 成功 √
        case success
        /// 失败 ×
        case error
        /// 指示器，菊花
        case indicator
        /// 进度条
        case determinate(progress: Float, style: HUDDeterminateStyle, complete: (()->Void)?)
        /// 显示图片
        case image(UIImage?)
        /// 旋转图片，clockwise顺时针
        case rotatingImage(UIImage?, clockwise: Bool)
        /// 文本成功
        case labelSuccess(title: String?, detail: String?)
        /// 文本失败
        case labelError(title: String?, detail: String?)
        /// 文本警告
        case labelWarning(title: String?, detail: String?)
        /// 文本指示器，菊花
        case labelIndicator(title: String?, detail: String?)
        /// 文本进度条
        case labelDeterminate(progress: Float, style: HUDDeterminateStyle, title: String?, complete: (()->Void)?)
        /// 文本图片
        case labelImage(image: UIImage?, title: String?, detail: String?)
        /// 文本旋转图片
        case labelRotatingImage(image: UIImage?, clockwise: Bool, title: String?, detail: String?)

        /// 只显示文本
        case label(title: String?, detail: String?)
        /// 自定义内容
        case customView(view: UIView)
        /// 自定义内容带文本
        case labelCustomView(view: UIView , title: String?, detail: String?)
    }
    
    /// 背景风格
    static var bgStyle: MBProgressHUDBackgroundStyle = .solidColor
    /// 浅色模式背景颜色
    static var lightBgColor: UIColor = .init(0xf2f2f2)
    /// 浅色模式内容颜色
    static var lightContentColor: UIColor = .gray
    /// 暗黑模式背景颜色
    static var darkBgColor: UIColor = .init(0x1E2028)
    /// 暗黑模式内容颜色
    static var darkContentColor: UIColor = .init(0xf2f2f2)
    /// 阴影颜色，nil不显示阴影
    static var bgShadowColor: UIColor? = nil
    /// 是否适配暗黑模式
    static var enableDarkMode = true
    /// 蒙板颜色
    static var dimBgColor: UIColor? = nil
    /// 默认消失时间
    static var delaySec = 1.5
    /// 宽限期
    static var graceTime: TimeInterval = 0.1
    /// 内边距
    static var margin: CGFloat = 15
    /// 圆角
    static var bgRadius: CGFloat = 3
    /// 内部元素间距
    static var spacing: CGFloat = 5
    /// 延迟显示隐藏按钮，右上角，当hud异常不能关闭时，等待多少秒，显示关闭按钮
    /// -1表示不启用该功能，>0表示延迟多少秒显示
    static var exceptionDelayHideSec: TimeInterval = -1
    
    /// 当不适配暗黑模式时的
    /// 默认的背景颜色
    static var bgColor: UIColor = .init(0xf2f2f2)
    
    /// 当不适配暗黑模式时的
    /// 默认的内容颜色
    static var contentColor: UIColor = .gray
    
    /// 当进度完成时，是否隐藏hud
    static var determinateHideOnProgressComplete = true
    
    /// label样式的hud偏移比例
    static var labelHUDOffset: UIOffset = .init(horizontal: 0, vertical: 0.30)
    
    
    /// 持有的hud
    private static var hud: MBProgressHUD?
    /// 消失的回调
    private static var completion: (()->Void)?
    /// 默认显示hud的父视图
    private static var window: UIWindow {
        UIApplication.shared.windows.first!
    }
    
    // MARK: - Flash HUD
    /// 提示错误
    /// - Parameters:
    ///   - error: 错误
    ///   - onView: 显示的父视图
    ///   - delay: 显示的延迟时间
    static func flash(error: Swift.Error?, onView: UIView? = nil, delay: TimeInterval = delaySec, completion: (()->Void)? = nil) {
        HUD.flash(error: nil, detail: error?.localizedDescription, onView: onView, delay: delay, completion: completion)
    }
    
    /// 提示错误
    /// - Parameters:
    ///   - error: 错误内容
    ///   - detail: 描述
    ///   - onView: 父视图
    ///   - delay: 延迟时间
    static func flash(error: String?, detail: String? = nil, onView: UIView? = nil, delay: TimeInterval = delaySec, completion: (()->Void)? = nil) {
        HUD.flash(.labelError(title: error, detail: detail), onView: onView, delay: delay, completion: completion)
    }
    
    /// 提示成功
    /// - Parameters:
    ///   - success: 成功标题
    ///   - detail: 成功描述
    ///   - onView: 父视图
    ///   - delay: 延迟时间
    static func flash(success: String?, detail: String? = nil, onView: UIView? = nil, delay: TimeInterval = delaySec, completion: (()->Void)? = nil) {
        HUD.flash(.labelSuccess(title: success, detail: detail), onView: onView, delay: delay, completion: completion)
    }
    
    /// 提示警告
    /// - Parameters:
    ///   - warning: 警告标题
    ///   - detail: 警告描述
    ///   - onView: 父视图
    ///   - delay: 延迟时间
    static func flash(warning: String, detail: String? = nil, onView: UIView? = nil, delay: TimeInterval = delaySec, completion: (()->Void)? = nil) {
        HUD.flash(.labelWarning(title: warning, detail: detail), onView: onView, delay: delay, completion: completion)
    }
    
    
    /// 提示一条文本信息
    /// - Parameters:
    ///   - hint: 提示内容
    ///   - onView: 父视图
    ///   - delay: 延迟时间
    static func flash(hint: String?, detail: String? = nil, onView: UIView? = nil, delay: TimeInterval = delaySec, completion: (()->Void)? = nil) {
        HUD.flash(.label(title: hint, detail: detail), onView: onView, delay: delay, completion: completion)
    }
    
    /// 提示hud，默认会在延迟delaySec秒后消失，delaySec可配置
    /// - Parameters:
    ///   - content: hud类型
    ///   - onView: 父视图
    ///   - delay: 延迟时间
    static func flash(_ content: HUDContentType, onView: UIView? = nil, delay: TimeInterval = delaySec, completion: (()->Void)? = nil) {
        show(content, onView: onView)
        hide(delay: delay, completion: completion)
    }
    
    // MARK: - SHOW HUD
    /// 显示加载菊花
    /// - Parameters:
    ///   - title: 标题
    ///   - detail: 描述
    ///   - onView: 父视图
    static func show(title: String? = nil, detail: String? = nil, onView: UIView? = nil) {
        HUD.show(.labelIndicator(title: title, detail: detail), onView: onView)
    }
    
    /// 显示hud，需要自己控制隐藏
    /// - Parameters:
    ///   - content: hud类型
    ///   - onView: 父视图
    static func show(_ content: HUDContentType, onView: UIView? = nil) {
        switch content {
        case .success:
            show(.labelSuccess(title: nil, detail: nil), onView: onView)
            
        case .error:
            show(.labelError(title: nil, detail: nil), onView: onView)
            
        case let .determinate(progress, style, complete):
            show(.labelDeterminate(progress: progress, style: style, title: nil, complete: complete), onView: onView)

        case .indicator:
            show(.labelIndicator(title: nil, detail: nil), onView: onView)
        
        case .image(let image):
            show(.labelImage(image: image, title: nil, detail: nil), onView: onView)
        
        case let .rotatingImage(image, clockwise):
            show(.labelRotatingImage(image: image, clockwise: clockwise, title: nil, detail: nil), onView: onView)
            
        case .customView(let view):
            show(.labelCustomView(view: view, title: nil, detail: nil), onView: onView)
            
        case let .label(title, detail):
            textHUD(text: title, detail: detail, onView: onView)
            
        case let .labelDeterminate(progress, style, title, complete):
            determinateHUD(progress: progress, style: style, title: title, onView: onView, complete: complete)
            
        case let .labelIndicator(title, detail):
            indicatorHUD(title: title, detail: detail, onView: onView)
            
        case let .labelSuccess(title, detail):
            let successView = UIImageView.init(image: UIImage.init(named: "done")?.withRenderingMode(.alwaysTemplate))
            customHUD(view: successView, title: title, detail: detail, onView: onView)
            
        case let .labelError(title, detail):
            let errorView = UIImageView.init(image: UIImage.init(named: "error")?.withRenderingMode(.alwaysTemplate))
            customHUD(view: errorView, title: title, detail: detail, onView: onView)
            
        case let .labelWarning(title, detail):
            let errorView = UIImageView.init(image: UIImage.init(named: "warning")?.withRenderingMode(.alwaysTemplate))
            customHUD(view: errorView, title: title, detail: detail, onView: onView)
            
        case let .labelImage(image, title, detail):
            let imageView = UIImageView.init(image: image?.withRenderingMode(.alwaysTemplate))
            customHUD(view: imageView, title: title, detail: detail, onView: onView)
            
        case let .labelRotatingImage(image, clockwise, title, detail):
            let imageView = UIImageView.init(image: image?.withRenderingMode(.alwaysTemplate))
            imageView.layer.add(HUD.rotationAnimation(clockwise), forKey: "progressAnimation")
            customHUD(view: imageView, title: title, detail: detail, onView: onView)
            
        case let .labelCustomView(view, title, detail):
            customHUD(view: view, title: title, detail: detail, onView: onView)
        }
    }
    
    /// 隐藏hud
    /// - Parameters:
    ///   - delay: 延迟时间
    ///   - completion: 隐藏后的回调
    class func hide(delay: TimeInterval = 0, completion: (()->Void)? = nil) {
        self.completion = completion
        if let hud = self.hud {
            hud.hide(animated: true, afterDelay: delay)
        }
    }
    
    // MARK: - Private
    
    private static func configHUD(onView: UIView?, mode: MBProgressHUDMode = .indeterminate) -> MBProgressHUD {
        
        let hudView = onView ?? window
        var newHUD: MBProgressHUD
                
        // 确保始终只显示一个hud
        if hud == nil {
            newHUD = MBProgressHUD.init(view: hudView)
        } else {
            /// 保证同一个视图是指存在一个hud
            if let cur_hud = MBProgressHUD.forView(hudView) {
                if cur_hud != hud {
                    clearOldHUD()
                }
                newHUD = cur_hud
            } else {
                clearOldHUD()
                newHUD = MBProgressHUD.init(view: hudView)
            }
        }
        
        newHUD.removeFromSuperViewOnHide = true
        hudView.addSubview(newHUD)
        
        newHUD.mode = mode
        newHUD.graceTime = HUD.graceTime
        newHUD.margin = HUD.margin
        newHUD.removeFromSuperViewOnHide = true
        newHUD.bezelView.style = HUD.bgStyle
        newHUD.bezelView.layer.cornerRadius = bgRadius
        
        newHUD.exceptionDelayHideSec = exceptionDelayHideSec
        newHUD.spacing = spacing
        
        if let disColor = HUD.dimBgColor {
            newHUD.backgroundView.color = disColor
        }
        
        if let sColor = HUD.bgShadowColor {
            newHUD.bezelView.layer.shadowColor = sColor.cgColor
            newHUD.bezelView.layer.shadowOffset = CGSize.zero
            newHUD.bezelView.layer.shadowOpacity = 0.4
            newHUD.bezelView.clipsToBounds = false
        }
        
        if #available(iOS 13.0, *), HUD.enableDarkMode {
            newHUD.contentColor = .init(light: HUD.lightContentColor, dark: HUD.darkContentColor)
            newHUD.bezelView.color = .init(light: HUD.lightBgColor, dark: HUD.darkBgColor)
        } else {
            newHUD.contentColor = HUD.contentColor
            newHUD.bezelView.color = HUD.bgColor
        }
        
        switch mode {
        case .text:
            newHUD.offset = .init(x: newHUD.frame.width * Self.labelHUDOffset.horizontal, y: newHUD.frame.height * Self.labelHUDOffset.vertical)
        default:
            newHUD.offset = .zero
        }
        
        newHUD.completionBlock = {
            let tempComplete = self.completion
            self.completion = nil
            tempComplete?()
        }
        
        newHUD.show(animated: true)
        hud = newHUD
        return newHUD
    }
    
    private static func clearOldHUD() {
        guard let oldHUD = hud else {
            return
        }
        oldHUD.completionBlock = nil
        oldHUD.hide(animated: false)
        hud = nil
    }
    
    private static func indicatorHUD(title: String? = nil, detail: String? = nil, onView: UIView? = nil) {
        let newHUD = configHUD(onView: onView, mode: .indeterminate)
        newHUD.label.text = title
        newHUD.detailsLabel.text = detail
    }
    
    private static func customHUD(view: UIView, title: String? = nil, detail: String? = nil, onView: UIView? = nil) {
        let newHUD = configHUD(onView: onView, mode: .customView)
        newHUD.customView = view
        newHUD.label.text = title
        newHUD.detailsLabel.text = detail
    }
    
    private static func textHUD(text: String?, detail: String?, onView: UIView? = nil) {
        let newHUD = configHUD(onView: onView, mode: .text)
        newHUD.label.text = text
        newHUD.label.numberOfLines = 5
        if let detail = detail {
            newHUD.detailsLabel.text = detail
            newHUD.detailsLabel.numberOfLines = 5
            newHUD.label.numberOfLines = 1
        }
    }
    
    private static func determinateHUD(progress: Float, style: HUDDeterminateStyle, title: String? = nil, onView: UIView? = nil, complete:(()->Void)? = nil) {
        let mode: MBProgressHUDMode = (style == .normal ? .annularDeterminate : (style == .horizontalBar ? .determinateHorizontalBar : .determinate))
        let view = onView ?? window
        
        if let deterHUD = MBProgressHUD.forView(view), let oldHUD = hud, oldHUD == deterHUD {
            oldHUD.mode = mode
            oldHUD.progress = progress
            oldHUD.label.text = title
            if (progress >= 1), HUD.determinateHideOnProgressComplete {
                HUD.hide(completion: complete)
            }
        } else {
            if hud != nil {
                clearOldHUD()
            }
            let newHUD = configHUD(onView: onView, mode: mode)
            newHUD.progress = progress
            newHUD.label.text = title
        }
    }
    
    private static func rotationAnimation(_ clockwise: Bool) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 2.0 * .pi * (clockwise ? 1 : -1)
        animation.duration = 1.5
        animation.repeatCount = Float(INT_MAX)
        return animation
    }
}

fileprivate extension UIColor {
    
    convenience init(light: UIColor, dark: UIColor? = nil) {
        if #available(iOS 13.0, *) {
            if dark == nil {
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                light.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
                self.init(dynamicProvider: { $0.userInterfaceStyle == .light ? light : UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha) })
            } else {
                self.init(dynamicProvider: { $0.userInterfaceStyle == .light ? light : dark! })
            }
        } else {
            self.init(cgColor: light.cgColor)
        }
    }
}

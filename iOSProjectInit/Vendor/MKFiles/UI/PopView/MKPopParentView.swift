//
//  MKPopParentView.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/3.
//

import UIKit

enum PopStyle {
    case center
    case left
    case right
    case top
    case bottom
    case custom
}

class MKPopParentView: UIView {
    var contentView: UIView {
        return popContentView
    }
    var isShow: Bool {
        return showed
    }
    
    var appendToSuper: Bool {
        self.superview != nil
    }
    
    var popStyle: PopStyle = .center {
        didSet {
            switch popStyle {
            case .center:
                corner = .allCorners
                cornerRadii = 10
            case .bottom:
                corner = [.topLeft, .topRight]
                cornerRadii = 10
            default:
                corner = []
                cornerRadii = 0
            }
        }
    }
    var presentDuration: TimeInterval = 0.4
    var dismissDuration: TimeInterval = 0.4
    /// 是否修复显示时的动画时长，在BottomStyle情况下，如果contentView height太高时，动画可能会跳帧，设置此项回修复次问题
    var fixBottomStylePresentDuration = false;
    var hideOnTapBackground = false {
        didSet {
            tap.isEnabled = hideOnTapBackground
        }
    }
    var maskColor: UIColor = .black.withAlphaComponent(0.35)
    var layoutWhenKeyBoardShow = false {
        didSet {
            guard popStyle == .center || popStyle == .bottom || popStyle == .custom else {
                return
            }
            if layoutWhenKeyBoardShow {
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    var defaultLayoutEnable = true
    var blurEnable = false
    var corner: UIRectCorner = .allCorners
    var cornerRadii: CGFloat = 5
    
    private var popContentView = PopContentView()
    private var showed = false
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat = 0
    private var safeArea: UIEdgeInsets = .zero
    
    private lazy var tap: UITapGestureRecognizer = {
        let ges = UITapGestureRecognizer.init()
        ges.delegate = self
        ges.cancelsTouchesInView = true
        ges.addTarget(self, action: #selector(tapHide))
        addGestureRecognizer(ges)
        return ges
    }()
    private var presentComplete: NoParamBlock? = nil
    private var dismissComplete: NoParamBlock? = nil
    
    private lazy var effectView: UIVisualEffectView = {
        let blur = UIBlurEffect.init(style: .dark)
        let effView = UIVisualEffectView.init(effect: blur)
        insertSubview(effView, belowSubview: popContentView)
        return effView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        popContentView.heightUpdateClosure = { [weak self] height in
            guard let this = self else {
                return
            }
            this.contentHeight = height
            if this.popStyle == .bottom, this.fixBottomStylePresentDuration {
                var duration = height/UIScreen.main.bounds.size.height
                if (duration < 0.4) {
                    duration = 0.4
                }
                this.presentDuration = duration
            }
        }
        
        popContentView.widthUpdateClosure = { [weak self] width in
            self?.contentWidth = width
        }
        addSubview(popContentView)
        
        setDefault()
        appendSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func defaultContentLayout() {
        guard defaultLayoutEnable else {
            return
        }
        popContentView.translatesAutoresizingMaskIntoConstraints = false
        popContentView.snp.makeConstraints { make in
            switch popStyle {
            case .top:
                make.top.left.right.equalToSuperview()
            case .left:
                make.top.bottom.left.equalToSuperview()
            case .right:
                make.right.top.bottom.equalToSuperview()
            case .bottom:
                make.left.right.bottom.equalToSuperview()
            case .center:
                make.center.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.8)
            default:
                break
            }
        }
    }
    
    deinit {
        if layoutWhenKeyBoardShow {
            NotificationCenter.default.removeObserver(self)
        }
        print("deinit \(String.init(describing: Self.self))")
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        newWindow?.endEditing(true)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview else {
            return
        }
        calLayout()
        popAnimation()
    }
    
    private func calLayout() {
        frame = superview!.bounds
        if blurEnable {
            effectView.frame = frame
        }
        dynamicSubviews()
        popContentView.layoutIfNeeded()
        
        var tempContentHeight: CGFloat = 0
        var tempContentWidth: CGFloat = 0
        
        if (CGSizeEqualToSize(.zero, popContentView.frame.size)) {
            let layoutSize = popContentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            tempContentWidth = layoutSize.width
            tempContentHeight = layoutSize.height
        } else {
            tempContentWidth = popContentView.frame.width
            tempContentHeight = popContentView.frame.height
        }
        
        if tempContentHeight != 0 {
            contentHeight = tempContentHeight
        }
        
        if tempContentWidth != 0 {
            contentWidth = tempContentWidth
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if cornerRadii > 0 {
            let path = UIBezierPath.init(roundedRect: popContentView.bounds, byRoundingCorners: corner, cornerRadii: .init(width: cornerRadii, height: cornerRadii))
            let shapeLayer = CAShapeLayer.init()
            shapeLayer.path = path.cgPath
            popContentView.layer.mask = shapeLayer
        }
    }

    // MARK: - Default && Init
    func setDefault() {
        popStyle = .center;
        showed = false;
        presentDuration = 0.4;
        dismissDuration = 0.4;
        contentHeight = 200;
        contentWidth = UIScreen.main.bounds.size.width * 0.8;
        maskColor = .black.withAlphaComponent(0.6)
        layoutWhenKeyBoardShow = false;
        hideOnTapBackground = true;
        blurEnable = false;
        popContentView.backgroundColor = .white
    }
    
    func appendSubviews() {
        backgroundColor = maskColor
        isUserInteractionEnabled = true
        if hideOnTapBackground {
            tap.isEnabled = hideOnTapBackground
        }
        defaultContentLayout()
    }
    
    /// 如果子视图会随着配置变动，就在这个方法里面操作
    /// 否则可能不能获取到正确的contentview高度，导致动画异常
    /// 此方法会在show方法之前调用
    func dynamicSubviews() {
        
    }


    // MARK: - Show && Hide
    
    private func popAnimation() {
        beforePop()
        UIView.animate(withDuration: presentDuration,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut) {
            self.inPoping()
        } completion: { Bool in
            self.endPop()
        }
    }
    
    private func dismissAnimation() {
        beforeHide()
        UIView.animate(withDuration: dismissDuration,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut) {
            self.inHiding()
        } completion: { _ in
            self.removeFromSuperview()
            self.endHide()
        }
    }
    
    func show(onView: UIView? = nil, complete: NoParamBlock? = nil) {
        presentComplete = complete
        if let view = onView {
            view.addSubview(self)
        } else if let rootVC = kWindow.rootViewController {
            rootVC.view.addSubview(self)
        } else {
            kWindow.addSubview(self)
        }
    }
    
    func hide(complete: NoParamBlock? = nil) {
        dismissComplete = complete
        dismissAnimation()
    }
    
    func beforePop() {
        switch popStyle {
        case .center:
            popContentView.alpha = 0
            if let superV = superview {
                popContentView.center = .init(x: superV.width/2, y: superV.height/2)
            }
            popContentView.transform = CGAffineTransformMakeScale(1.1, 1.1)
        case .left:
            var tranWidth = contentWidth
            if isShow {
                tranWidth += popContentView.frame.minX
            }
            popContentView.transform = CGAffineTransformMakeTranslation(-tranWidth, 0)
        case .right:
            var tranWidth = contentWidth
            if isShow, let superWidth = popContentView.superview?.frame.size.width {
                tranWidth += (superWidth - popContentView.frame.maxX)
            }
            popContentView.transform = CGAffineTransformMakeTranslation(tranWidth, 0)
        case .top:
            var tranHeight = contentHeight
            if isShow {
                tranHeight += popContentView.frame.minY
            }
            popContentView.transform = CGAffineTransformMakeTranslation(0, -tranHeight)
        case .bottom:
            var tranHeight = contentHeight
            if isShow, let superHeight = popContentView.superview?.frame.size.height {
                tranHeight += (superHeight - popContentView.frame.maxY)
            }
            popContentView.transform = CGAffineTransformMakeTranslation(0, tranHeight)
        default:
            break
        }
        
        if popStyle != .custom {
            backgroundColor = .clear
            if blurEnable {
                effectView.alpha = 0
            }
        }
    }
    
    func inPoping() {
        switch popStyle {
        case .center:
            popContentView.alpha = 1
            popContentView.transform = .identity
        default:
            popContentView.transform = .identity
        }
        
        if popStyle != .custom {
            backgroundColor = maskColor
            if blurEnable {
                effectView.alpha = 0.7
            }
        }
    }
    
    func endPop() {
        showed = true
        presentComplete?()
    }
    
    func beforeHide() {
        
    }
    
    func inHiding() {
        switch popStyle {
        case .custom:
            break
        default:
            beforePop()
        }
        
        if popStyle == .center {
            popContentView.transform = CGAffineTransformMakeScale(0.8, 0.8)
        }
    }
    
    func endHide() {
        if (popStyle != .custom) {
            backgroundColor = maskColor
            if blurEnable {
                effectView.alpha = 0.7
            }
            popContentView.transform = .identity
        }
        showed = false
        dismissComplete?()
    }

    // MARK: - Keyboard Show Hide
    @objc func keyboardWillShow(notification: NSNotification){
        guard showed else {
            return
        }
        
        guard let keyRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
        let aniOption = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        let keyHeight = keyRect.size.height
        var offsetY: CGFloat = 0
        
        if popStyle == .center {
            offsetY = keyHeight / 2
        }
        else if popStyle == .bottom {
            offsetY = keyHeight
        }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: aniOption) ) {
            self.popContentView.transform = CGAffineTransformMakeTranslation(0, -offsetY);
        } completion: { _ in
            
        }
    }

    @objc func keyboardWillHide(notification:  NSNotification) {
        guard showed else {
            return
        }
        
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
        let aniOption = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: aniOption)) {
            self.popContentView.transform = CGAffineTransformIdentity;
        } completion: { _ in
            
        }
    }
}

// MARK: - Gesture
extension MKPopParentView: UIGestureRecognizerDelegate {
    @objc private func tapHide() {
        self.hide()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: popContentView)
        return !popContentView.layer.contains(point)
    }
}

///
fileprivate class PopContentView: UIView {
    var heightUpdateClosure: ((CGFloat)->Void)? = nil
    var widthUpdateClosure: ((CGFloat)->Void)? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let heightUpdate = heightUpdateClosure, self.frame.height > 0 {
            heightUpdate(self.frame.height)
        }
        if let widthUpdate = widthUpdateClosure, self.frame.width > 0 {
            widthUpdate(self.frame.width)
        }
    }
}

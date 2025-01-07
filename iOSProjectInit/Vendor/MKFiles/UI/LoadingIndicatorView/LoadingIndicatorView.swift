//
//  LoadingIndicatorView.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/1.
//

import UIKit

/// NVActivityIndicatorView
/// https://github.com/ninjaprox/NVActivityIndicatorView

enum LoadingIndicatorType: CaseIterable {
    /// 正方形上下左右翻转
    case squareFlip
    /// 两个正方形沿路径旋转缩放
    case cubeTransition
    /// 9个方块如波浪一样变幻大小
    case cubeGirdScale
    /// 三个球依次大小
    case ballPulse
    /// 两球绕一球旋转，缩放
    case ballRotate
    /// 三个球依次弹跳
    case ballPulseSync
    /// 三个球依次减淡
    case ballBeat
    /// 左右球来回移动，中间球不动
    case ballTranslation
    /// 环形球旋转，渐变，大小变化
    case ballSpinFadeScale
    /// 环形球旋转，渐变
    case ballSpinFade
    /// 球旋转追逐
    case ballRotateChase
    /// 两球大小透明变换
    case ballDoubleBounce
    /// 五条线段依次变换长短
    case lineScale
    /// 半环形
    case circleClipRotate
    /// 系统样式
    case lineSpinFadeLoader
    /// 吃豆人
    case pacman
    /// 安卓加载样式
    case circleStrokeSpin
    
    func animation() -> LoadingIndicatorAnimation {
        switch self {
        case .squareFlip:
            return SquareFlipAnimation()
        case .cubeTransition:
            return CubeTransitionAnimation()
        case .cubeGirdScale:
            return CubeGirdScaleAnimation()
        case .ballPulse:
            return BallPulseAnimation()
        case .ballRotate:
            return BallRotateAnimation()
        case .ballPulseSync:
            return BallPulseSyncAnimation()
        case .ballBeat:
            return BallBeatAnimation()
        case .ballDoubleBounce:
            return BallDoubleBounceAnimation()
        case .circleClipRotate:
            return CircleClipRotateAnimation()
        case .ballSpinFadeScale:
            return BallSpinFadeScaleAnimation()
        case .ballSpinFade:
            return BallSpinFadeAnimation()
        case .ballTranslation:
            return BallTranslationAnimation()
        case .lineSpinFadeLoader:
            return LineSpinFadeLoaderAnimation()
        case .lineScale:
            return LineScaleAnimation()
        case .pacman:
            return PacmanAnimation()
        case .ballRotateChase:
            return BallRotateChaseAnimation()
        case .circleStrokeSpin:
            return CircleStrokeSpinAnimation()
        }
    }
    
    var typeName: String {
        String(describing: self)
    }
}

enum LoadingIndicatorShape {
    /// 矩形
    case square
    /// 圆球
    case circle
    /// 四分之三环
    case ringThirdFour
    /// 线条
    case line
    /// 吃豆人
    case pacman
    ///
    case stroke
    
    func layer(size: CGSize, color: UIColor) -> CALayer {
        let layer = CAShapeLayer()
        var path = UIBezierPath()
        let lineWidth: CGFloat = 2
        
        switch self {
        case .square:
            path = UIBezierPath(rect: .init(x: 0, y: 0, width: size.width, height: size.height))
            layer.fillColor = color.cgColor
        case .circle:
            path.addArc(withCenter: .init(x: size.width/2, y: size.height/2),
                        radius: size.width/2,
                        startAngle: 0,
                        endAngle: CGFloat(2*Double.pi),
                        clockwise: false)
            layer.fillColor = color.cgColor
        case .ringThirdFour:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: CGFloat(-3 * Double.pi / 4),
                        endAngle: CGFloat(-Double.pi / 4),
                        clockwise: false)
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = lineWidth
        case .line:
            path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height),
                                cornerRadius: size.width / 2)
            layer.fillColor = color.cgColor
        case .pacman:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 4,
                        startAngle: 0,
                        endAngle: CGFloat(2 * Double.pi),
                        clockwise: true)
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = size.width / 2
        case .stroke:
            path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                        radius: size.width / 2,
                        startAngle: -(.pi / 2),
                        endAngle: .pi + .pi / 2,
                        clockwise: true)
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = lineWidth
        }
        
        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = .init(x: 0, y: 0, width: size.width, height: size.height)
        return layer
    }
}

class LoadingIndicatorView: UIView {
    
    var hideWhenStopAnimation = false
    private(set) var isAnimating: Bool = false
    
    init(frame: CGRect, type: LoadingIndicatorType = .ballPulse, color: UIColor = .white, padding: CGFloat = 0, hideWhenStopAnimation: Bool = false) {
        super.init(frame: frame)
        self.type = type
        self.color = color
        self.padding = padding
        self.hideWhenStopAnimation = hideWhenStopAnimation
        if hideWhenStopAnimation {
            isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        if hideWhenStopAnimation {
            isHidden = true
        }
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: bounds.width, height: bounds.height)
    }
    
    override var frame: CGRect {
        didSet {
            guard frame != .zero, oldValue != frame else {
                return
            }
            setUpAnimation()
        }
    }
    
    var type: LoadingIndicatorType = .ballPulse {
        didSet {
            guard oldValue != type else {
                return
            }
            setUpAnimation()
        }
    }
    var color: UIColor = .white  {
        didSet {
            guard oldValue != color else {
                return
            }
            setUpAnimation()
        }
    }
    var padding: CGFloat = 0  {
        didSet {
            guard oldValue != padding else {
                return
            }
            setUpAnimation()
        }
    }
    
    func startAnimation() {
        guard !isAnimating else {
            return
        }
        if hideWhenStopAnimation {
            isHidden = false
        }
        
        isAnimating = true
        layer.speed = 1
    }
    
    func stopAnimation() {
        guard isAnimating else {
            return
        }
        
        if hideWhenStopAnimation {
            isHidden = true
        }
        isAnimating = false
        layer.speed = 0
    }
    
    private func setUpAnimation() {
        var animationRect = frame.inset(by: .init(top: padding, left: padding, bottom: padding, right: padding))
        let minEdge = min(animationRect.width, animationRect.height)
        animationRect.size = CGSize(width: minEdge, height: minEdge)
        layer.sublayers = nil
        layer.speed = 0
        DispatchQueue.main.async {
            self.type.animation().animation(layer: self.layer, size: animationRect.size, color: self.color)
        }
    }
}

//
//  BallRotateAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/1.
//

import UIKit

class BallRotateAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        /// 大小
        let circleSize = size.width / 5
        /// 动画时间
        let duration: CFTimeInterval = 1
        /// 函数
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.7, -0.13, 0.22, 0.86)
        /// y
        let y = (size.height - circleSize) / 2
        
        let scaleAnimation = CAKeyframeAnimation.transform(with: .scale)
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [1, 0.6, 1]
        scaleAnimation.duration = duration
        
        let rotateAnimation = CAKeyframeAnimation.transform(with: .rotationZ)
        rotateAnimation.keyTimes = [0, 0.5, 1]
        rotateAnimation.timingFunctions = [timingFunction, timingFunction]
        rotateAnimation.values = [0, Double.pi, 2 * Double.pi]
        rotateAnimation.duration = duration
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, rotateAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        let leftCircle = LoadingIndicatorShape.circle.layer(size: .square(width: circleSize), color: color)
        let rightCircle = LoadingIndicatorShape.circle.layer(size: .square(width: circleSize), color: color)
        let centerCircle = LoadingIndicatorShape.circle.layer(size: .square(width: circleSize), color: color)
        
        leftCircle.opacity = 0.8
        rightCircle.opacity = 0.8
        
        let circle = CALayer()
        let frame = CGRectMake((layer.bounds.size.width-size.width)/2, (layer.bounds.size.height-size.height)/2, size.width, size.height)
        circle.frame = frame
        
        circle.addSublayer(leftCircle)
        circle.addSublayer(rightCircle)
        circle.addSublayer(centerCircle)
        
        leftCircle.frame = .init(x: 0, y: y, width: circleSize, height: circleSize)
        rightCircle.frame = .init(x: size.width-circleSize, y: y, width: circleSize, height: circleSize)
        centerCircle.frame = .init(x: (size.width-circleSize)/2, y: y, width: circleSize, height: circleSize)
        
        circle.addAnimation(animation)
        layer.addSublayer(circle)
    }
}

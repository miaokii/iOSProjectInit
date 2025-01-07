//
//  BallBeatAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/1.
//

import UIKit

class BallBeatAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 5
        let circleSize = (size.width - circleSpacing*2)/3
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - circleSize) / 2
        let duration: CFTimeInterval = 0.7
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.35, 0, 0.35]
        
        let scaleAnimation = CAKeyframeAnimation.transform(with: .scale)
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.values = [1, 0.75, 1]
        scaleAnimation.duration = duration
        
        let opacityAnimation = CAKeyframeAnimation.opacity()
        opacityAnimation.keyTimes = [0, 0.5, 1]
        opacityAnimation.values = [1, 0.2, 1]
        opacityAnimation.duration = duration
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        for i in 0..<3 {
            let circle = LoadingIndicatorShape.circle.layer(size: .square(width: circleSize), color: color)
            let frame = CGRectMake(x + circleSize * CGFloat(i) + circleSpacing * CGFloat(i), y, circleSize, circleSize)
            animation.beginTime = beginTime + beginTimes[i]
            circle.frame = frame
            circle.addAnimation(animation)
            layer.addSublayer(circle)
        }
    }
}

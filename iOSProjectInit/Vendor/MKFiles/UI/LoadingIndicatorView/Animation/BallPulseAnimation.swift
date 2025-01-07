//
//  BallPulseAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/1.
//

import UIKit

class BallPulseAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        // 圆间隔
        let circleSpacing: CGFloat = 3
        // 圆尺寸
        let circleSize: CGFloat = (size.width - 2 * circleSpacing) / 3
        // 开始x坐标
        let x = (layer.bounds.size.width - size.width) / 2
        // y坐标
        let y = (layer.bounds.size.height - circleSize) / 2
        // 动画持续时间
        let duration: CFTimeInterval = 1
        // 动画开始时间
        let beginTime = CACurrentMediaTime()
        // 三个圆动画间隔时间
        let beginTimes: [CFTimeInterval] = [0.36, 0.24, 0.12]
        // 动画方程
//        let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)
        let timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let animation = CAKeyframeAnimation.transform(with: .scale)
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [0, 1, 0]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        for i in 0..<3 {
            let circle = LoadingIndicatorShape.circle.layer(size: .square(width: circleSize), color: color)
            let frame = CGRect.init(x: x + CGFloat(i) * (circleSize + circleSpacing), y: y, width: circleSize, height: circleSize)
            animation.beginTime = beginTime - beginTimes[i]
            circle.frame = frame
            circle.addAnimation(animation)
            layer.addSublayer(circle)
        }
    }
}


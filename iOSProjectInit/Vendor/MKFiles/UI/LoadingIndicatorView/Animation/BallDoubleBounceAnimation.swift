//
//  BallDoubleBounceAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/2.
//

import UIKit

class BallDoubleBounceAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 1
        let circleSize = size.width * 0.8
        let timingFuncation = CAMediaTimingFunction(name: .easeInEaseOut)
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0, duration/2]
        
        let scaleAnimation = CAKeyframeAnimation.transform(with: .scale)
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.values = [1, 0, 1]
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.duration = duration
        scaleAnimation.timingFunctions = [timingFuncation, timingFuncation]
        
        for i in 0..<2 {
            let circle = LoadingIndicatorShape.circle.layer(size: .square(width: circleSize), color: color)
            circle.frame = .init(x: (layer.bounds.width - circleSize) / 2,
                                 y: (layer.bounds.height - circleSize) / 2,
                                 width: circleSize,
                                 height: circleSize)
            circle.opacity = 0.5
            scaleAnimation.beginTime = beginTime + beginTimes[i]
            circle.addAnimation(scaleAnimation)
            
            layer.addSublayer(circle)
        }
        
        
    }
}

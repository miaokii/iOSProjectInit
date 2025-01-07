//
//  BallTranslationAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/3.
//

import UIKit

class BallTranslationAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        /// 大小
        let circleSize = size.width / 5
        /// 动画时间
        let duration: CFTimeInterval = 1
        /// 函数
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.7, -0.13, 0.22, 0.86)
        /// y
        let y = (size.height - circleSize) / 2
        /// 每俩球心相聚
        let ballSpacing = (size.width - circleSize)/2
        let beginTime = CACurrentMediaTime()
        
        let leftCircle = LoadingIndicatorShape.circle.layer(size: .square(width: circleSize), color: color)
        let rightCircle = LoadingIndicatorShape.circle.layer(size: .square(width: circleSize), color: color)
        let centerCircle = LoadingIndicatorShape.circle.layer(size: .square(width: circleSize), color: color)
        
        leftCircle.opacity = 0.8
        rightCircle.opacity = 0.8
        
        layer.addSublayer(leftCircle)
        layer.addSublayer(rightCircle)
        layer.addSublayer(centerCircle)
        
        leftCircle.frame = .init(x: (layer.bounds.width - size.width)/2, y: layer.bounds.midY - circleSize/2, width: circleSize, height: circleSize)
        rightCircle.frame = .init(x: leftCircle.frame.minX + 2 * ballSpacing, y: leftCircle.frame.minY, width: circleSize, height: circleSize)
        centerCircle.frame = .init(x: leftCircle.frame.minX + ballSpacing, y: leftCircle.frame.minY, width: circleSize, height: circleSize)
        
        leftCircle.addAnimation(translationAnimation(toRight: true, distance: 2*ballSpacing))
        
        rightCircle.addAnimation(translationAnimation(toRight: false, distance: 2*ballSpacing))
    }
    
    private func translationAnimation(toRight: Bool, distance: CGFloat) -> CAKeyframeAnimation {
        let duration: CFTimeInterval = 1
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.7, -0.13, 0.22, 0.86)
        
        let translationAnimation = CAKeyframeAnimation.transform(with: .translationX)
        translationAnimation.duration = duration
        translationAnimation.keyTimes = [0, 0.5, 1]
        translationAnimation.values = [0, (toRight ? 1 : -1)*distance, 0]
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.timingFunctions = [timingFunction, timingFunction]
        translationAnimation.repeatCount = HUGE
        return translationAnimation
    }
}

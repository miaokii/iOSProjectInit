//
//  BallSpinFadeRotateAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/3.
//

import UIKit

class BallSpinFadeAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 1
        let circleSize = (size.width - 4 * circleSpacing) / 5
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0.84, 0.72, 0.6, 0.48, 0.36, 0.24, 0.12, 0.0]
        let timingFuncation = CAMediaTimingFunction(name: .easeInEaseOut)

        let opacityAnimaton = CAKeyframeAnimation.opacity()
        opacityAnimaton.keyTimes = [0, 0.5, 1]
        opacityAnimaton.values = [1, 0.5, 0]
        opacityAnimaton.duration = duration
        opacityAnimaton.repeatCount = HUGE
        opacityAnimaton.isRemovedOnCompletion = false
        opacityAnimaton.timingFunctions = [timingFuncation, timingFuncation]

        for i in 0 ..< 8 {
            let circle = circleAt(angle: CGFloat(Double.pi / 4) * CGFloat(i),
                                  size: circleSize,
                                  origin: CGPoint(x: x, y: y),
                                  containerSize: size,
                                  color: color)

            opacityAnimaton.beginTime = beginTime - beginTimes[i]
            circle.addAnimation(opacityAnimaton)
            layer.addSublayer(circle)
        }
    }
    
    private func circleAt(angle: CGFloat, size: CGFloat, origin: CGPoint, containerSize: CGSize, color: UIColor) -> CALayer {
        let radius = containerSize.width / 2 - size / 2
        let circle = LoadingIndicatorShape.circle.layer(size: .square(width: size), color: color)
        let frame = CGRect(
            x: origin.x + radius * (cos(angle) + 1),
            y: origin.y + radius * (sin(angle) + 1),
            width: size,
            height: size)

        circle.frame = frame

        return circle
    }}

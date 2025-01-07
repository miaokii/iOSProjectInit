//
//  PacmanAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/1.
//

import UIKit

class PacmanAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        circleInLayer(layer, size: size, color: color)
        pacmanInLayer(layer, size: size, color: color)
    }

    private func pacmanInLayer(_ layer: CALayer, size: CGSize, color: UIColor) {
        
        let pacmanSize = 2 * size.width / 3
        let pacmanDuration: CFTimeInterval = 0.5
        let timingFunction = CAMediaTimingFunction(name: .default)

        // Stroke start animation
        let strokeStartAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
        strokeStartAnimation.keyTimes = [0, 0.5, 1]
        strokeStartAnimation.timingFunctions = [timingFunction, timingFunction]
        strokeStartAnimation.values = [0.125, 0, 0.125]
        strokeStartAnimation.duration = pacmanDuration

        // Stroke end animation
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.keyTimes = [0, 0.5, 1]
        strokeEndAnimation.timingFunctions = [timingFunction, timingFunction]
        strokeEndAnimation.values = [0.875, 1, 0.875]
        strokeEndAnimation.duration = pacmanDuration

        // Animation
        let animation = CAAnimationGroup()
        animation.animations = [strokeStartAnimation, strokeEndAnimation]
        animation.duration = pacmanDuration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        // Draw pacman
        let pacman = LoadingIndicatorShape.pacman.layer(size: CGSize(width: pacmanSize, height: pacmanSize), color: color)
        let frame = CGRect(
            x: (layer.bounds.size.width - size.width) / 2,
            y: (layer.bounds.size.height - pacmanSize) / 2,
            width: pacmanSize,
            height: pacmanSize
        )

        pacman.frame = frame
        pacman.addAnimation(animation)
        layer.addSublayer(pacman)
    }

    private func circleInLayer(_ layer: CALayer, size: CGSize, color: UIColor) {
        let circleSize = size.width / 5
        let circleDuration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0, 0.5]

        // Translate animation
        let translateAnimation = CABasicAnimation.transform(with: .translationX)

        translateAnimation.fromValue = 0
        translateAnimation.toValue = -size.width
        translateAnimation.duration = circleDuration

        // Opacity animation
        let opacityAnimation = CABasicAnimation.opacity()
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0.8
        opacityAnimation.duration = circleDuration

        // Animation
        let animation = CAAnimationGroup()

        animation.animations = [translateAnimation, opacityAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = circleDuration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        let dotLayer = CALayer.init()
        dotLayer.frame = .init(x: (layer.bounds.size.width - size.width) / 2,
                               y: (layer.bounds.size.height - size.height) / 2,
                               width: size.width, height: size.height)
        dotLayer.masksToBounds = true
        layer.addSublayer(dotLayer)

        for i in 0..<2 {
            let circle = LoadingIndicatorShape.circle.layer(size: CGSize(width: circleSize, height: circleSize), color: color)
            let frame = CGRect(
                x: size.width,
                y: (size.height - circleSize) / 2,
                width: circleSize,
                height: circleSize
            )

            circle.frame = frame
            animation.beginTime = beginTime + beginTimes[i]
            circle.addAnimation(animation)
            dotLayer.addSublayer(circle)
        }
    }
}

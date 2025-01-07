//
//  SquareFlipAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/2.
//

import UIKit

class SquareFlipAnimation: LoadingIndicatorAnimation {
    
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
//        transformAnimation(layer: layer, size: size, color: color)
        rotationXYAnimation(layer: layer, size: size, color: color)
    }
    
    private func transformAnimation(layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 3
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.09, 0.57, 0.49, 0.9)
        let keyTimes: [NSNumber] = [0, 0.25, 0.5, 0.75, 1]
        
        let animation = CAKeyframeAnimation.transform(with: .transform)
        animation.keyTimes = keyTimes
        animation.timingFunctions = Array.init(repeating: timingFunction, count: keyTimes.count - 1)
        animation.values = [
            CATransform3DConcat(rotateXTransform(angle: 0), rotateYTransform(angle: 0)),
            CATransform3DConcat(rotateXTransform(angle: .pi), rotateYTransform(angle: 0)),
            CATransform3DConcat(rotateXTransform(angle: .pi), rotateYTransform(angle: .pi)),
            CATransform3DConcat(rotateXTransform(angle: 0), rotateYTransform(angle: .pi)),
            CATransform3DConcat(rotateXTransform(angle: 0), rotateYTransform(angle: 0)),
        ]

        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        let square = LoadingIndicatorShape.square.layer(size: size, color: color)
        square.frame = .init(x: (layer.bounds.width - size.width)/2,
                             y: (layer.bounds.height - size.height)/2,
                             width: size.width,
                             height: size.height)
        square.addAnimation(animation)
        square.cornerRadius = 3
        layer.addSublayer(square)
    }
    
    private func rotateXTransform(angle: Double) -> CATransform3D {
        var transform = CATransform3DMakeRotation(angle, 1, 0, 0)
        transform.m34 = -1/100
        return transform
    }
    
    private func rotateYTransform(angle: Double) -> CATransform3D {
        var transform = CATransform3DMakeRotation(angle, 0, 1, 0)
        transform.m34 = -1/100
        return transform
    }
    
    private func rotationXYAnimation(layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 1.3
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.09, 0.57, 0.49, 0.9)
        var transform = CATransform3DIdentity
        // 正值将增强透视效果，负值将减弱透视效果
        // 设置 m34 的值为 -1.0 / distance，其中 distance 是观察者到屏幕的距离
        // 较小的 distance 值会产生更强烈的透视效果，而较大的 distance 值则会减弱透视效果
        transform.m34 = -1/200
        
        let flipVertical = CAKeyframeAnimation.transform(with: .rotationX)
        flipVertical.duration = duration
        flipVertical.keyTimes = [0, 0.5, 1]
        flipVertical.timingFunctions = [timingFunction, timingFunction]
        flipVertical.values = [0, -Double.pi, -Double.pi]
        flipVertical.isRemovedOnCompletion = false
        flipVertical.repeatCount = HUGE
        
        let flipHorizontal = CAKeyframeAnimation.transform(with: .rotationY)
        flipHorizontal.duration = duration
        flipHorizontal.keyTimes = [0, 0.5, 1]
        flipHorizontal.values = [0, 0, Double.pi]
        flipHorizontal.timingFunctions = [timingFunction, timingFunction]
        flipHorizontal.isRemovedOnCompletion = false
        flipHorizontal.repeatCount = HUGE

        let animation = CAAnimationGroup.init()
        animation.animations = [flipVertical, flipHorizontal]
        animation.duration = 2*duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        let cubeLayer = LoadingIndicatorShape.square.layer(size: size, color: color)
        cubeLayer.frame = .init(x: (layer.bounds.width - size.width)/2,
                                y: (layer.bounds.height - size.height)/2,
                                width: size.width,
                                height: size.height)
        cubeLayer.addRotationAnimation(animation)
        cubeLayer.transform = transform
        cubeLayer.cornerRadius = 3
        
        layer.addSublayer(cubeLayer)
    }
}

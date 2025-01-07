//
//  CircleClipRotateAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/1.
//

import UIKit

class CircleClipRotateAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 0.75

        let animation = CAKeyframeAnimation.transform(with: .rotationZ)
        animation.keyTimes = [0, 0.5, 1]
        animation.values = [0, Double.pi, 2 * Double.pi]
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        let circle = LoadingIndicatorShape.ringThirdFour.layer(size: CGSize(width: size.width, height: size.height), color: color)
        let frame = CGRect(x: (layer.bounds.size.width - size.width) / 2,
                           y: (layer.bounds.size.height - size.height) / 2,
                           width: size.width,
                           height: size.height)

        circle.frame = frame
        circle.addAnimation(animation)
        layer.addSublayer(circle)
    }
}

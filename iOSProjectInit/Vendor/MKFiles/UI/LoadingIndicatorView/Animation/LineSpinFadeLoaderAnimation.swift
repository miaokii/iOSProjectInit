//
//  LineSpinFadeLoaderAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/1.
//

import UIKit

class LineSpinFadeLoaderAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        let lineSpacing: CGFloat = 2
        let lineSize = CGSize(width: (size.width - 4 * lineSpacing) / 7.5, height: (size.height - 2 * lineSpacing) / 3)
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime() - 1
        
        let beginTimes: [CFTimeInterval] = [1, 0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125]
        let timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let animation = CAKeyframeAnimation.opacity()
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.1, 1]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        for i in 0 ..< 8 {
            let line = lineAt(angle: CGFloat(Double.pi / 4 * Double(i)),
                              size: lineSize,
                              origin: CGPoint(x: x, y: y),
                              containerSize: size,
                              color: color)

            animation.beginTime = beginTime - beginTimes[i]
            line.addAnimation(animation)
            layer.addSublayer(line)
        }
    }

    func lineAt(angle: CGFloat, size: CGSize, origin: CGPoint, containerSize: CGSize, color: UIColor) -> CALayer {
        let radius = containerSize.width / 2 - max(size.width, size.height) / 2
        let lineContainerSize = CGSize(width: max(size.width, size.height), height: max(size.width, size.height))
        let lineContainer = CALayer()
        let lineContainerFrame = CGRect(
            x: origin.x + radius * (cos(angle) + 1),
            y: origin.y + radius * (sin(angle) + 1),
            width: lineContainerSize.width,
            height: lineContainerSize.height)
        let line = LoadingIndicatorShape.line.layer(size: size, color: color)
        let lineFrame = CGRect(
            x: (lineContainerSize.width - size.width) / 2,
            y: (lineContainerSize.height - size.height) / 2,
            width: size.width,
            height: size.height)

        lineContainer.frame = lineContainerFrame
        line.frame = lineFrame
        lineContainer.addSublayer(line)
        lineContainer.sublayerTransform = CATransform3DMakeRotation(CGFloat(Double.pi / 2) + angle, 0, 0, 1)

        return lineContainer
    }
}


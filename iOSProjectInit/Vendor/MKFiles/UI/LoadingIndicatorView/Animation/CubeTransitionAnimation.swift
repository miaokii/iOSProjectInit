//
//  CubeTransitionAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/3.
//

import UIKit

class CubeTransitionAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        let cubeSize = size.width / 5
        let duration: CFTimeInterval = 1.5
        let center = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        let spacingCenter: CGFloat = size.width/2 - cubeSize/2
        let beginTime = CACurrentMediaTime()
        
        let timingFunctions = Array.init(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 4)
        let keyTimes: [NSNumber] = [0, 0.25, 0.5, 0.75, 1]
        
        let scaleAnimation = CAKeyframeAnimation.transform(with: .scale)
        scaleAnimation.keyTimes = keyTimes
        scaleAnimation.values = [1, 0.5, 1, 0.5, 1]
        scaleAnimation.timingFunctions = timingFunctions
        scaleAnimation.duration = duration
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.isRemovedOnCompletion = false
        
        let rotateAnimation = CAKeyframeAnimation.transform(with: .rotationZ)
        rotateAnimation.keyTimes = keyTimes
        rotateAnimation.values = [0, Double.pi/2, Double.pi, Double.pi*3/2, Double.pi*2]
        rotateAnimation.timingFunctions = timingFunctions
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = HUGE
        rotateAnimation.isRemovedOnCompletion = false
        
        /*
        let cube1Rect = CGRect.init(x: center.x - spacingCenter, y: center.y - spacingCenter,
                                    width: cubeSize, height: cubeSize)
        let cube2Rect = CGRect.init(x: center.x + spacingCenter - cubeSize,
                                    y: center.y + spacingCenter - cubeSize,
                                    width: cubeSize, height: cubeSize)
        let pathWidth = 2 * spacingCenter - cubeSize
        let pathRect = CGRect.init(x: cube1Rect.midX, y: cube1Rect.midY, width: pathWidth, height: pathWidth)
        
        let positionAnimation = CAKeyframeAnimation.position()
        positionAnimation.keyTimes = keyTimes
        positionAnimation.values = [
            pathRect.origin,
            CGPoint(x: pathRect.maxX, y: pathRect.minY),
            CGPoint(x: pathRect.maxX, y: pathRect.maxY),
            CGPoint(x: pathRect.minX, y: pathRect.maxY),
            pathRect.origin
        ]
        positionAnimation.timingFunctions = timingFunctions
        positionAnimation.duration = duration
        positionAnimation.isRemovedOnCompletion = false
        positionAnimation.repeatCount = HUGE
        positionAnimation.rotationMode = .rotateAuto
         */
        
        let translateWidth = 2 * spacingCenter - cubeSize
        let translateAnimation = CAKeyframeAnimation.transform(with: .translation)
        translateAnimation.keyTimes = keyTimes
        translateAnimation.timingFunctions = timingFunctions
        translateAnimation.values = [
            CGSize(width: 0, height: 0),
            CGSize(width: translateWidth, height: 0),
            CGSize(width: translateWidth, height: 2 * spacingCenter - cubeSize),
            CGSize(width: 0, height: translateWidth),
            CGSize(width: 0, height: 0),
        ]
        translateAnimation.duration = duration
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, rotateAnimation, translateAnimation]
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        animation.duration = duration
        
        for i in 0..<2 {
            let cube = LoadingIndicatorShape.square.layer(size: .square(width: cubeSize), color: color)
            cube.frame = CGRect.init(x: center.x - spacingCenter, y: center.y - spacingCenter,
                                     width: cubeSize, height: cubeSize)
            // 提早开始，所以是-
            animation.beginTime = beginTime - duration/2*CFTimeInterval(i)
            cube.addAnimation(animation)
            layer.addSublayer(cube)
        }
    }
}

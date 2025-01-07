//
//  CubeGirdScaleAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/3.
//

import UIKit

class CubeGirdScaleAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        
        let delayTimes: [Int: CFTimeInterval] = [
            0: 0.6,
            1: 0.8,
            2: 1,
            3: 0.4,
            4: 0.6,
            5: 0.8,
            6: 0.2,
            7: 0.4,
            8: 0.6
        ]
        
        let cubeSize = ceil(size.width / 3)
        let timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        let beginTime = CACurrentMediaTime()
        
        let scaleAnimation = CAKeyframeAnimation.transform(with: .scale)
        scaleAnimation.keyTimes = [0, 0.3, 0.6, 1]
        scaleAnimation.values = [1, 0, 1, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.duration = 1
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.isRemovedOnCompletion = false
        
        for i in 0..<9 {
            let cube = LoadingIndicatorShape.square.layer(size: .square(width: cubeSize), color: color)
            let frame = CGRectMake(floor((layer.bounds.width-size.width)/2+cubeSize*CGFloat(i%3)),
                                   (layer.bounds.width-size.width)/2+cubeSize*CGFloat(i/3),
                                   cubeSize, cubeSize)
            cube.frame = frame
            scaleAnimation.beginTime = beginTime + (delayTimes[i] ?? 0) / 3
            cube.addAnimation(scaleAnimation)
            layer.addSublayer(cube)
        }
    }
}

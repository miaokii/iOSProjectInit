//
//  LineScaleAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/2.
//

import UIKit

class LineScaleAnimation: LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor) {
        let duration: CFTimeInterval = 1

        let offx = (layer.bounds.size.width - size.width) / 2
        let lineSpacing: CGFloat = 3
        let lineWidth = (size.width - lineSpacing*4) / 5
        let lineHeight = size.height / 3
        
        let timeBegin = CACurrentMediaTime()
        let timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let scaleAnimation = CAKeyframeAnimation.transform(with: .scaleY)
        scaleAnimation.duration = duration
        scaleAnimation.repeatCount = HUGE
                
        scaleAnimation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        scaleAnimation.values = [1, 2.5, 1, 1, 1]
        scaleAnimation.timingFunctions = Array.init(repeating: timingFunction, count: 4)
        scaleAnimation.isRemovedOnCompletion = false
        
        for i in 0..<5 {
            let squre = LoadingIndicatorShape.square.layer(size: .init(width: lineWidth, height: lineHeight), color: color)
            let frame = CGRectMake(offx + CGFloat(i)*(lineWidth+lineSpacing), (layer.bounds.height - size.height)/2+(size.height-lineHeight)/2, lineWidth, lineHeight)
            squre.frame = frame
            squre.cornerRadius = 3
            
            scaleAnimation.beginTime = timeBegin + 0.1*CFTimeInterval(i)
            squre.addAnimation(scaleAnimation)
            layer.addSublayer(squre)
        }
        
    }
}

//
//  UIImageView+Ex.swift
//  MuYunControl
//
//  Created by miaokii on 2023/3/17.
//

import UIKit

extension UIImageView {
    
    /// 渐变显示图片
    /// - Parameters:
    ///   - image: 图片
    ///   - duration: 渐变时长
    func transition(duration: TimeInterval = 0.25, config: @escaping ((UIImageView)->Void)) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve) {
            config(self)
        }
    }
}

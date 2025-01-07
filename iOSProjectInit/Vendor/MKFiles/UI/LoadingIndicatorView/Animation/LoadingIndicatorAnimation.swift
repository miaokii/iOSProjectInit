//
//  LoadingIndicatorAnimation.swift
//  SwiftLib
//
//  Created by yoctech on 2023/11/1.
//

import UIKit

protocol LoadingIndicatorAnimation {
    func animation(layer: CALayer, size: CGSize, color: UIColor)
}

enum AnimationTransformKey: String {
    case transform = "transform"
    case translation = "transform.translation"
    case scale = "transform.scale"
    case scaleX = "transform.scale.x"
    case scaleY = "transform.scale.y"
    case translationX = "transform.translation.x"
    case translationY = "transform.translation.y"
    case rotationX = "transform.rotation.x"
    case rotationY = "transform.rotation.y"
    case rotationZ = "transform.rotation.z"
}

extension CAPropertyAnimation {
    static func transform(with key: AnimationTransformKey) -> Self {
        Self.init(keyPath: key.rawValue)
    }
    
    static func opacity() -> Self {
        Self.init(keyPath: "opacity")
    }
    
    static func position() -> Self {
        Self.init(keyPath: "position")
    }
}

extension CALayer {
    func addAnimation(_ animation: CAAnimation) {
        add(animation, forKey: "animation")
    }
    
    func addRotationAnimation(_ animation: CAAnimation) {
        add(animation, forKey: "rotationAnimation")
    }
}

extension CGSize {
    static func square(width: CGFloat) -> Self {
        .init(width: width, height: width)
    }
}



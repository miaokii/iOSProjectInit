//
//  UILabel+Ex.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/26.
//

import UIKit


extension UILabel {
//    func setGradientText(colors:[UIColor], start: CGPoint = .init(x: 0, y: 0), end: CGPoint = .init(x: 1, y: 0)) {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = bounds
//        gradientLayer.colors = colors.map{$0.cgColor}
//        gradientLayer.startPoint = start
//        gradientLayer.endPoint = end
//
//        let renderer = UIGraphicsImageRenderer(size: gradientLayer.bounds.size)
//        let gradientImage = renderer.image { context in
//            gradientLayer.render(in: context.cgContext)
//        }
//        textColor = UIColor(patternImage: gradientImage)
//    }
    
    func setGradientText(colors: [UIColor], start: CGPoint = .zero, end: CGPoint = .init(x: 1, y: 1)) {
        // 设置 CATextLayer
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.font = font
        textLayer.fontSize = font.pointSize
        textLayer.contentsScale = UIScreen.main.scale
        switch textAlignment {
        case .left: textLayer.alignmentMode = .left
        case .right: textLayer.alignmentMode = .right
        case .center: textLayer.alignmentMode = .center
        case .natural: textLayer.alignmentMode = .natural
        case .justified: textLayer.alignmentMode = .justified
        @unknown default:
            textLayer.alignmentMode = .left
        }
        textLayer.frame = bounds
        
        // 设置渐变颜色
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
        gradientLayer.mask = textLayer // 将 textLayer 作为 mask
        
        // 添加渐变层到视图
        gradientLayer.name = "gradientTextLayer"
        layer.sublayers?.filter{$0.name=="gradientTextLayer"}.forEach{$0.removeFromSuperlayer()}
        layer.addSublayer(gradientLayer)
        textColor = .clear
    }
}


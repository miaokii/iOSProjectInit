//
//  Theme.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/25.
//

import UIKit

// MARK: - 颜色配置
extension UIColor {
    /// 主题色
    static var theme = UIColor.init(0x1ECA87)
    /// 背景色
    static var background = UIColor.dynamic(light: .init(0xF3F3F3), dark: .init(0x000000))
    /// viewcontroller背景颜色，浅色模式0xffffff，暗黑模式0x000000
    static let separator = UIColor.dynamic(light: .init(0xF4F4F4), dark: .init(0x1F1F1E))
    /// 一级文字颜色，浅色模式黑色，暗黑模式是0x999999
    static let textColorBlack = UIColor.dynamic(light: .black, dark: .init(0x999999))
    static let textColorDarkGray = UIColor.init(0x333333)
    /// 二级文字颜色，0x666666
    static let textColorGray = UIColor.init(0x666666)
    static let textColorLightGray = UIColor.init(0x999999)
    
    static let placeHolderColor = UIColor.init(0xC5C5C7)
}

extension UIFont {
    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size+1, weight: .regular)
    }
    static func medium(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size+1, weight: .medium)
    }
    static func bold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size+1, weight: .bold)
    }
    static func heavy(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size+1, weight: .heavy)
    }
    static func dinBold(_ size: CGFloat) -> UIFont {
        return UIFont.init(name: "DINAlternate-Bold", size: size+1) ?? .bold(size)
    }
}

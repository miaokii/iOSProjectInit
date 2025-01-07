//
//  UIColor+Ex.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/25.
//

import UIKit

public extension UIColor {
    /// hex
    convenience init(_ hex: UInt32) {
        var red, green, blue, alpha: UInt32
        if hex > 0xffffff {
            blue = hex & 0x000000ff
            green = (hex & 0x0000ff00) >> 8
            red = (hex & 0x00ff0000) >> 16
            alpha = (hex & 0xff000000) >> 24
        } else {
            blue = hex & 0x0000ff
            green = (hex & 0x00ff00) >> 8
            red = (hex & 0xff0000) >> 16
            alpha = 255
        }
        self.init(red: CGFloat(red) / (255.0), green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
    
    /// hex Str
    /*
    convenience init(hexStr: String) {
        var red: UInt32 = 0, green: UInt32 = 0, blue: UInt32 = 0
        var hex = hexStr
        
        if hex.hasPrefix("#") {
            hex[0..<1] = ""
        }
        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            hex[0..<2] = ""
        }
        
        Scanner(string: String(hex[hex.startIndex..<hex.index(hex.startIndex, offsetBy: 2)])).scanHexInt32(&red)
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.index(hex.startIndex, offsetBy: 4)])).scanHexInt32(&green)
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 4)...])).scanHexInt32(&blue)
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
     */
    
    /// 设置普通模式和暗黑模式
    class func dynamic(light: UIColor, dark: UIColor? = nil) -> UIColor {
        if #available(iOS 13.0, *) {
            guard let darkColor = dark else {
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                light.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return Self.init(dynamicProvider: { $0.userInterfaceStyle == .light ? light : UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha) })
            }
            return Self.init(dynamicProvider: { $0.userInterfaceStyle == .light ? light : darkColor })
        } else {
            return light
        }
    }
    
    /// 随机颜色
    class var random: UIColor {
        get {
            return UIColor(arc4random() % 0xffffff)
        }
    }
    
    /// 分割线颜色
    class var sysSeparator: UIColor {
        get {
            if #available(iOS 13.0, *) {
                return .separator
            } else {
                return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.29)
            }
        }
    }
    
    /// 背景颜色
    class var sysBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    static var sysTableGroupedBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGroupedBackground
        } else {
            return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        }
    }
    
    class var sysTableCellGroupedBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.value(forKey: "tableCellGroupedBackgroundColor") as! UIColor
        }
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}



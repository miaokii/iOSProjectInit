//
//  UIImage+Ex.swift
//  healthpassport
//
//  Created by fighter on 2019/10/17.
//  Copyright © 2019 fighter. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Init Color
public extension UIImage {
    
    static func hex(_ hex: UInt32) -> UIImage? {
        .init(color: .init(hex))
    }
    
    /// 根据颜色生成图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 图片大小
    convenience init(color: UIColor, size: CGSize = CGSize(width: 10.0, height: 10.0)){
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect.init(origin: CGPoint.zero, size: size))
        context?.setShouldAntialias(true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
    
    convenience init?(base64: String) {
        guard let base64String = base64.components(separatedBy: ",").last,
           let data = Data(base64Encoded: base64String) else {
            return nil
        }
        self.init(data: data)
    }
    
    func saveToAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAsset(from: self)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    HUD.flash(success: "保存成功")
                } else {
                    HUD.flash(error: "保存失败")
                }
            }
        }
    }
}

// MARK: Tint Image
public extension UIImage {
    
    func tintTo(tintColor: UIColor, blendModel: CGBlendMode = .destinationIn, alpha: CGFloat = 1.0) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        tintColor.setFill()
        UIRectFill(imageRect)
        self.draw(in: imageRect, blendMode: blendModel, alpha: alpha)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func withColor(_ color: UIColor) -> UIImage {
        self.withTintColor(color, renderingMode: .alwaysOriginal)
    }
}

// MARK: 图片缩放
public extension UIImage {
    
    /// 缩放图片
    /// - Parameter size: 目的大小
    /// - Returns: 缩放后图片
    func scale(to size: CGSize) -> UIImage {
        // 获得原图像的 大小 宽  高
        let imageSize = self.size
        let width = imageSize.width
        let height = imageSize.height
        
        // 计算图像新尺寸与旧尺寸的宽高比例
        let widthFactor = size.width/width
        let heightFactor = size.height/height
        // 获取最小的比例
        let scalerFactor = (widthFactor < heightFactor) ? widthFactor : heightFactor
        
        // 计算图像新的高度和宽度，并构成标准的CGSize对象
        let scaledWidth = width * scalerFactor
        let scaledHeight = height * scalerFactor
        let targetSize = CGSize(width: scaledWidth, height: scaledHeight)
        
        // 创建绘图上下文环境
        UIGraphicsBeginImageContext(targetSize)
        self.draw(in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))
        
        // 获取上下文里的内容，将视图写入到新的图像对象
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
    }
}

// MARK:- 添加水印
public extension UIImage {
    
    /// 添加文字水印
    func addWaterMark(text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> UIImage? {
        return addWaterMark(text: text, corner: .bottomRight, font: font, textColor: UIColor.white, shadowColor: UIColor.black)
    }
    
    func addWaterMark(text: String, corner: UIRectCorner, font: UIFont, textColor: UIColor, shadowColor: UIColor?) -> UIImage? {
        
        // 图片尺寸
        let width = self.size.width, height = self.size.height
        
        // 文字大小相对于图片大小而言的，所以要做换算
        let fontP = width / (UIScreen.main.bounds.width / font.pointSize)
        
        // 段落属性，右对齐
        let paragraph = NSMutableParagraphStyle.init()
        paragraph.alignment = .right
    
        // 文字属性
        var attr: [NSAttributedString.Key : Any] = [.foregroundColor : textColor, .font : UIFont.systemFont(ofSize: fontP), .paragraphStyle : paragraph]
        
        // 添加阴影
        if shadowColor != nil {
            let shadow = NSShadow.init()
            shadow.shadowColor = shadowColor!
            shadow.shadowBlurRadius = 1.0;
            shadow.shadowOffset = CGSize.init(width: 1, height: 1)
            attr[.shadow] = shadow
        }
        
        let textSize = text.sizeWidth(font: UIFont.systemFont(ofSize: fontP), maxWidth: width)
        
        // 开始绘制
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect.init(x: 0, y: 0, width: width, height: height))
        switch corner {
        case .topLeft:
            text.draw(in: CGRect.init(x: 5, y: 5, width: textSize.width, height: textSize.height), withAttributes: attr)
        case .topRight:
            text.draw(in: CGRect.init(x: width - 10 - textSize.width, y: 5, width: textSize.width, height: textSize.height), withAttributes: attr)
        case .bottomLeft:
            text.draw(in: CGRect.init(x: 5, y: height - 10 - textSize.height, width: textSize.width, height: textSize.height), withAttributes: attr)
        case .bottomRight:
            text.draw(in: CGRect.init(x: width - 10 - textSize.width, y: height - 10 - textSize.height, width: textSize.width, height: textSize.height), withAttributes: attr)
        default:
            break
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


//
//  UIImage+DC.swift
//  healthpassport
//
//  Created by fighter on 2019/10/11.
//  Copyright © 2019 fighter. All rights reserved.
//

import UIKit.UIImage
import Photos

extension UIImage {
   
    func ellipse() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: rect)
        context?.clip()
        draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self;
    }
    
    func fixOrientation() -> UIImage {
        if imageOrientation != .up {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(in: CGRect(origin: .zero, size: size))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage ?? self
        }
        return self
    }
    
    func render(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)
        draw(in: rect, blendMode: .overlay, alpha: 1)
        draw(in: rect, blendMode: .destinationIn, alpha: 1)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    //压缩图片质量
    func reduceImageWithPercent(_ percent: CGFloat) -> UIImage? {
        if let imageData = self.jpegData(compressionQuality: percent){
            //UIImageJPEGRepresentation(self, percent) {
            let newImage =  UIImage(data: imageData)
            return newImage
        } else {
            return nil
        }
    }
}

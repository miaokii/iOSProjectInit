//
//  QRMaker.swift
//  MuYunControl
//
//  Created by miaokii on 2023/3/4.
//

import UIKit

class QRMaker {
    enum QRType: String {
        case qrcode = "CIQRCodeGenerator"
        case barcode = "CICode128BarcodeGenerator"
    }
    
    class func createQr(_ content: String, type: QRType = .qrcode, size: CGSize = CGSize.init(width: 200, height: 200), logo: UIImage? = nil) -> UIImage? {
        //1.将字符串转出NSData
        let imageData = content.data(using: .utf8)!
        //2.将字符串变成二维码滤镜
        let filter = CIFilter(name: type.rawValue)
        //3.恢复滤镜的默认属性
        filter?.setDefaults()
        //4.设置滤镜的 inputMessage
        filter?.setValue(imageData, forKey: "inputMessage")
        //5.获得滤镜输出的图像
        guard let ciImage = filter?.outputImage else { return nil }
        
        //6.此时获得的二维码图片比较模糊，通过下面函数转换成高清
        let scaleX = size.width / ciImage.extent.width
        let scaleY = size.height / ciImage.extent.height
        let scaleImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        return creatImage(bgImage: UIImage(ciImage: scaleImage), iconImage: logo)
    }
    
    //MARK: - 根据背景图片和头像合成头像二维码, 即是中间带头像的二维码
    class func creatImage(bgImage: UIImage, iconImage: UIImage?) -> UIImage? {
        //开启图片上下文
        UIGraphicsBeginImageContext(bgImage.size)
        defer {
            //关闭上下文
            UIGraphicsEndImageContext()
        }
        //绘制背景图片
        bgImage.draw(in: CGRect(origin: .zero, size: bgImage.size))
        //绘制头像
        let width: CGFloat = 70
        let height: CGFloat = width
        let x = (bgImage.size.width - width) * 0.5
        let y = (bgImage.size.height - height) * 0.5
        iconImage?.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //返回合成好的图片
        return newImage
    }
}

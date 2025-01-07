//
//  UIButton+Ex.swift
//  znjtys
//
//  Created by miaokai on 2018/12/5.
//  Copyright © 2018 联颐. All rights reserved.
//

import UIKit

/*  ======================= Style =======================  */
public extension UIButton {
    func setTitleColor(normal: UIColor?,
                       highlighted: UIColor?,
                       disable: UIColor?) {
        setTitleColor(normal, for: .normal)
        setTitleColor(highlighted, for: .highlighted)
        setTitleColor(disable, for: .disabled)
    }
}

/*  ======================= Init =======================  */

// MARK:- TitleLabel Alignment
public extension UIButton {
    func setTitleLabel(horizontalAlignmnet: UIControl.ContentHorizontalAlignment,
                       verticalAlignment: UIControl.ContentVerticalAlignment,
                       contentEdgeInset: UIEdgeInsets) {
        self.contentVerticalAlignment = verticalAlignment
        self.contentHorizontalAlignment = horizontalAlignmnet
        self.contentEdgeInsets = contentEdgeInset
    }
}

// MARK:- Title color
public extension UIButton {
    func setNormal(titleColor: UIColor) {
        setTitleColor(titleColor, for: .normal)
    }
    
    func normalTitleColor() -> UIColor? {
        return self.titleColor(for: .normal)
    }
    
    func setHighlighted(titleColor: UIColor) {
        setTitleColor(titleColor, for: .highlighted)
    }
    
    func highlightedTitleColor() -> UIColor? {
        return self.titleColor(for: .highlighted)
    }
    
    func setDisabled(titleColor: UIColor) {
        setTitleColor(titleColor, for: .disabled)
    }
    
    func disabledTitleColor() -> UIColor? {
        return self.titleColor(for: .disabled)
    }
    
    func setSelected(titleColor: UIColor) {
        setTitleColor(titleColor, for: .selected)
    }
    
    func selectedTitleColor() -> UIColor? {
        return self.titleColor(for: .selected)
    }
}

// MARK:- target action
public extension UIControl {
    func add(_ target: Any?, _ action: Selector) {
        self.addTarget(target, action: action, for: .touchUpInside)
    }
}

// MARK:- title
public extension UIButton {
    func setNormal(title: String) {
        self.setTitle(title, for: .normal)
    }
    
    func normalTitle() -> String? {
        return self.title(for: .normal)
    }
    
    func setHighlighted(title: String) {
        setTitle(title, for: .highlighted)
    }
    
    func highlightedTitle() -> String? {
        return title(for: .highlighted)
    }
    
    func setDisabled(title: String) {
        setTitle(title, for: .disabled)
    }
    
    func disabledTitle() -> String? {
        return title(for: .disabled)
    }
    
    func setSelected(title: String) {
        setTitle(title, for: .selected)
    }
    
    func selectedTitle() -> String? {
        return title(for: .selected)
    }
}

// MARK:- image
public extension UIButton {
    func setNormal(image: UIImage?) {
        setImage(image, for: .normal)
    }
    
    func normalImage() -> UIImage? {
        return image(for: .normal)
    }
    
    func setHighted(image: UIImage?) {
        setImage(image, for: .highlighted)
    }
    
    func hightedImage() -> UIImage? {
        return image(for: .highlighted)
    }
    
    func setDisabled(image: UIImage?) {
        setImage(image, for: .disabled)
    }
    
    func disabledImage() -> UIImage? {
        return image(for: .disabled)
    }
    
    func setSelected(image: UIImage?) {
        setImage(image, for: .selected)
    }
    
    func selectedImage() -> UIImage? {
        return image(for: .selected)
    }
}

// MARK:- background image
public extension UIButton {
    func setNormal(backgroundImage: UIImage?) {
        setBackgroundImage(backgroundImage, for: .normal)
    }
    
    func normalBackgroundImage() -> UIImage? {
        return backgroundImage(for: .normal)
    }
    
    func setHighlighted(backgroundImage: UIImage?) {
        setBackgroundImage(backgroundImage, for: .highlighted)
    }
    
    func highlightedBackgroundImage() -> UIImage? {
        return backgroundImage(for: .highlighted)
    }
    
    func setDisabled(backgroundImage: UIImage?) {
        setBackgroundImage(backgroundImage, for: .disabled)
    }
    
    func disabledBackgroundImage() -> UIImage? {
        return backgroundImage(for: .disabled)
    }
    
    func setSelected(backgroundImage: UIImage?) {
        setBackgroundImage(backgroundImage, for: .selected)
    }
    
    func selectedBackgroundImage() -> UIImage? {
        return backgroundImage(for: .selected)
    }
    
    @IBInspectable var backgroundImageColor: UIColor {
        get {
            return UIColor.init(patternImage: backgroundImage(for: .normal) ?? UIImage())
        }
        
        set {
            self.setNormal(backgroundImage: UIImage.init(color: newValue))
        }
    }
}

// MARK: - 更改图片位置
public extension UIButton {
    enum ImageTitleStyle {
        case imageTopTitleBottom
        case imageLeftTitleRight
        case imageBottomTitleTop
        case imageRightTitleLeft
    }
    
    func set(imageTitleStyle: ImageTitleStyle) {
        
        guard let imageSize = self.imageView?.image?.size, let titleSize = self.titleLabel?.bounds.size  else {
            return
        }
        
        switch imageTitleStyle {
        case .imageLeftTitleRight:
            return
        case .imageTopTitleBottom:
            self.titleEdgeInsets = UIEdgeInsets.init(top: titleSize.height,
                                                     left: -imageSize.width,
                                                     bottom: 0,
                                                     right: 0)
            self.imageEdgeInsets = UIEdgeInsets.init(top: -titleSize.height / 2,
                                                     left: titleSize.width / 2,
                                                     bottom: titleSize.height / 2,
                                                     right: -titleSize.width / 2)
        case .imageBottomTitleTop:
            self.titleEdgeInsets = UIEdgeInsets.init(top: -titleSize.height,
                                                     left: -imageSize.width,
                                                     bottom: 0,
                                                     right: 0)
            self.imageEdgeInsets = UIEdgeInsets.init(top: titleSize.height / 2,
                                                     left: titleSize.width / 2,
                                                     bottom: -titleSize.height / 2,
                                                     right: -titleSize.width / 2)
        case .imageRightTitleLeft:
            self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -imageSize.width, bottom: 0, right: imageSize.width)
            self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -titleSize.width, bottom: 0, right: titleSize.width)
        }
    }
}

// MARK: - 点击事件
private var click_closure: Void?
public extension UIControl {
    
    typealias ClickActionClosure = (_ sender: UIControl) -> Void
    
    func setClosure(_ closure: @escaping ClickActionClosure) {
        objc_setAssociatedObject(self, &click_closure, closure, .OBJC_ASSOCIATION_RETAIN)
        self.add(self, #selector(clickAction(_:)))
    }
    
    @objc private func clickAction(_ sender: UIControl) {
        if let clickClosure = objc_getAssociatedObject(self, &click_closure) as? ClickActionClosure {
            clickClosure(sender)
        }
    }
}

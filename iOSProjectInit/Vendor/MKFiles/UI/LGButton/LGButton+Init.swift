//
//  LGButton+Init.swift
//  RXCustomer
//
//  Created by yoctech on 2023/3/2.
//

import UIKit

extension LGButton {
    
    class func button(superView: UIView? = nil, title: String = "", titleColor: UIColor = .black, font: UIFont = .systemFont(ofSize: 15), normalImage: UIImage? = nil, imageSize:CGSize? = nil, bgColor: UIColor = .white, isVertical: Bool = false, space: CGFloat = 8) -> LGButton {
        return button(superView: superView, normalTitle: title, normalTitleColor: titleColor, font: font, normalImage: normalImage, imageSize: imageSize, backgroundColor: bgColor, vertical: isVertical, titleImgSpace: space)
    }
    

    class func button(superView: UIView? = nil, normalTitle: String = "", normalTitleColor: UIColor = .black, selectedTitle: String? = nil, selectedTitleColor: UIColor? = nil, font: UIFont = .systemFont(ofSize: 15), normalImage: UIImage? = nil, selectedImage: UIImage? = nil, imageSize:CGSize? = nil, backgroundColor: UIColor = .white, vertical: Bool = false, titleImgSpace: CGFloat = 8, contentInset: UIEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: 10)) -> LGButton {
        let button = LGButton.init()
        
        button.normalTitle = normalTitle
        button.normalTitleColor = normalTitleColor
        
        if let selTitle = selectedTitle {
            button.selectedTitle = selTitle
        }
        if let selTitleColor = selectedTitleColor {
            button.selectedTitleColor = selTitleColor
        }
        
        button.font = font
        
        if let normalImg = normalImage {
            button.normalLeftImage = normalImg
        }
        
        if let selImg = selectedImage {
            button.selectedLeftImage = selImg
        }
        
        if let size = imageSize {
            button.leftImageWidth = size.width
            button.leftImageHeight = size.height
            button.rightImageWidth = size.width
            button.rightImageHeight = size.height
        }
        
        button.bgColor = backgroundColor
        button.verticalOrientation = vertical
        button.spacingTitleIcon = titleImgSpace
        button.contentInset = contentInset
        
        if let superV = superView {
            superV.addSubview(button)
        }
        return button
    }
    
    @objc class func button(title: String = "", image: UIImage? = nil, vertical: Bool = false) -> LGButton {
        self.button(superView: nil, normalTitle: title, normalImage: image, vertical: vertical)
    }
    
    private static var normalLeftImgKey: UInt8 = 0
    @objc var normalLeftImage: UIImage? {
        get {
            objc_getAssociatedObject(self, &Self.normalLeftImgKey) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &Self.normalLeftImgKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if !isSelected {
                leftImageSrc = normalLeftImage
            }
        }
    }
    
    private static var selectedLeftImgKey: UInt8 = 0
    @objc var selectedLeftImage: UIImage? {
        get {
            objc_getAssociatedObject(self, &Self.selectedLeftImgKey) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &Self.selectedLeftImgKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if isSelected {
                leftImageSrc = selectedLeftImage
            }
        }
    }
    
    private static var normalRightImgKey: UInt8 = 0
    @objc var normalRightImage: UIImage? {
        get {
            objc_getAssociatedObject(self, &Self.normalRightImgKey) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &Self.normalRightImgKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if !isSelected {
                rightImageSrc = normalRightImage
            }
        }
    }
    
    private static var selectedRightImgKey: UInt8 = 0
    @objc var selectedRightImage: UIImage? {
        get {
            objc_getAssociatedObject(self, &Self.selectedRightImgKey) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &Self.selectedRightImgKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if isSelected {
                rightImageSrc = selectedRightImage
            }
        }
    }
    
    private static var normalTitleKey: UInt8 = 0
    @objc var normalTitle: String? {
        get {
            objc_getAssociatedObject(self, &Self.normalTitleKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &Self.normalTitleKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if !isSelected, let title = normalTitle {
                titleString = title
            }
        }
    }
    
    private static var selectedTitleKey: UInt8 = 0
    @objc var selectedTitle: String? {
        get {
            objc_getAssociatedObject(self, &Self.selectedTitleKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &Self.selectedTitleKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if isSelected, let title = selectedTitle {
                titleString = title
            }
        }
    }
    
    private static var normalTitleColorKey: UInt8 = 0
    @objc var normalTitleColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &Self.normalTitleColorKey) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &Self.normalTitleColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if !isSelected, let color = normalTitleColor {
                titleColor = color
            }
        }
    }
    
    private static var contentInsetKey: UInt8 = 0
    var contentInset: UIEdgeInsets? {
        get {
            objc_getAssociatedObject(self, &Self.contentInsetKey) as? UIEdgeInsets
        }
        set {
            objc_setAssociatedObject(self, &Self.contentInsetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let inset = newValue {
                spacingLeading = inset.left
                spacingTrailing = inset.right
                spacingTop = inset.top
                spacingBottom = inset.bottom
            }
        }
    }
    
    private static var selectedTitleColorKey: UInt8 = 0
    @objc var selectedTitleColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &Self.selectedTitleColorKey) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &Self.selectedTitleColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if isSelected, let color = selectedTitleColor {
                titleColor = color
            }
        }
    }
    
    private static var normalBgColorKey: UInt8 = 0
    @objc var normalBgColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &Self.normalBgColorKey) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &Self.normalBgColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if !isSelected, let color = normalBgColor {
                bgColor = color
            }
        }
    }
    
    private static var selectedBgColorKey: UInt8 = 0
    @objc var selectedBgColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &Self.selectedBgColorKey) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &Self.selectedBgColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if isSelected, let color = selectedBgColor {
                bgColor = color
            }
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if (isSelected) {
                if let selTitle = selectedTitle {
                    titleString = selTitle
                }
                if let selTitleColor = selectedTitleColor {
                    titleColor = selTitleColor
                }
                if let selLeftImg = selectedLeftImage {
                    leftImageSrc = selLeftImg
                }
                if let selRightImg = selectedRightImage {
                    rightImageSrc = selRightImg
                }
                if let selBgColor = selectedBgColor {
                    bgColor = selBgColor
                }
            } else {
                if let title = normalTitle {
                    titleString = title
                }
                if let tColor = normalTitleColor {
                    titleColor = tColor
                }
                if let leftImg = normalLeftImage {
                    leftImageSrc = leftImg
                }
                if let rightImg = normalRightImage {
                    rightImageSrc = rightImg
                }
                if let normalBgColor = normalBgColor {
                    bgColor = normalBgColor
                }
            }
        }
    }
    
    open override var isEnabled: Bool {
        didSet {
            if (isEnabled) {
                self.alpha = 1;
            } else {
                self.alpha = 0.7
            }
        }
    }
}


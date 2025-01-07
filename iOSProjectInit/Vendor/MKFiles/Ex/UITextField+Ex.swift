//
//  UITextField+Ex.swift
//  Extensions
//
//  Created by miaokai on 2019/4/19.
//  Copyright © 2019 lianyi. All rights reserved.
//

import UIKit

extension UITextField {
    typealias TextFieldConfig = (UITextField) -> Void
    
    func config(textField configurate: TextFieldConfig?) {
        configurate?(self)
    }
    
    func left(image: UIImage?, color: UIColor = .black) {
        if let image = image {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
    }
    
    func right(image: UIImage?, color: UIColor = .black) {
        if let image = image {
            rightViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
            rightView = imageView
        } else {
            rightViewMode = UITextField.ViewMode.never
            rightView = nil
        }
    }
    
    func addBlank(left: Bool = true, width: CGFloat = 20) {
        let blankView = UIView.init(frame: .init(x: 0, y: 0, width: width, height: 20))
        if left {
            leftViewMode = .always
            leftView = blankView
        } else {
            rightViewMode = .always
            rightView = blankView
        }
    }
    
    func addRightAccess(image: UIImage?, leftSpace: CGFloat = 0, rightSpace: CGFloat = 10) {
        addIcon(image: image, isLeft: false, leftSpace: 0, rightSpace: 10)
    }
    
    func addIcon(image: UIImage?, isLeft: Bool = true, leftSpace: CGFloat = 10, rightSpace: CGFloat = 10) {
        guard let image = image else {
            return
        }
        
        let accessView = UIImageView.init(image: image)
        
        let accessSuperView = UIView.init()
        accessSuperView.addSubview(accessView)
        accessView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-rightSpace)
            make.left.equalTo(leftSpace)
        }
        
        if isLeft {
            leftViewMode = .always
            leftView = accessSuperView
        } else {
            rightViewMode = .always
            rightView = accessSuperView
        }
    }
    
    func addTapAction(action: @escaping (_ textField: UITextField) -> Void) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
        
        objc_setAssociatedObject(self, UnsafeRawPointer(bitPattern: "tapAction".hashValue)!, action, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
    }
    
    @objc private func handleTap() {
        if let action = objc_getAssociatedObject(self, UnsafeRawPointer(bitPattern: "tapAction".hashValue)!) as? (UITextField) -> Void {
            action(self)
        }
    }
}

extension UITextField {
    func setPlaceHolderColor(_ color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [.foregroundColor : color])
    }
    
    func placeHolder(text value: String, color: UIColor, font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)) {
        self.attributedPlaceholder = NSAttributedString(string: value, attributes: [ .foregroundColor : color, .font: font])
    }
}

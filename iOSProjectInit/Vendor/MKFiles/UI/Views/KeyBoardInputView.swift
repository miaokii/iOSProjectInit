//
//  FollowinputView.swift
//  RXClient4
//
//  Created by yoctech on 2024/5/10.
//

import UIKit
import SnapKit

class KeyBoardInputView: MKPopParentView, UITextViewDelegate {
    
    var inputClosure: ((String)->Void)?
    var maxCount = 300
    var placeHolder = "请输入"
    var text = ""
    var returnKeyType: UIReturnKeyType = .send
    
    private var textView: MKTextView!
    private var inset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    private var textViewHeightConstraint: Constraint!
    private var confirmed = false
    
    override func setDefault() {
        popStyle = .custom
        layoutWhenKeyBoardShow = true
        hideOnTapBackground = true
        corner = []
        defaultLayoutEnable = false
    }
    
    override func appendSubviews() {
        super.appendSubviews()
        
        contentView.backgroundColor = .white
        
        textView = .init(super: contentView, backgroundColor: .background)
        textView.font = .regular(15)
        textView.delegate = self
        textView.textContainerInset = inset
        textView.textContainer.lineFragmentPadding = 0
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.tintColor = .theme
        textView.contentInset = .zero
        textView.enablesReturnKeyAutomatically = true
        textView.cornerRadius = 8
        textView.clipsToBounds = true
        textView.placeholder = "请输入"
        textView.placeholderTextColor = .textColorLightGray
        textView.maxLength = 100
        textView.showTextCount = true
        textView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(10)
            textViewHeightConstraint = make.height.equalTo(100).constraint
            make.bottom.equalTo(-10)
        }
        
        resetTextViewHeight(100)
        
        textView.textChangedClosure = { [weak self] text in
            self?.textChanged(text: text)
        }
    }
    
    override func dynamicSubviews() {
        textView.maxLength = maxCount
        textView.placeholder = placeHolder
        textView.text = text
        textView.returnKeyType = returnKeyType
        super.dynamicSubviews()
    }
    
    private func resetTextViewHeight(_ height: CGFloat, offsetY: CGFloat = 0) {
        textView.frame = .init(x: 15, y: 10, width: screenWidth-30, height: height)
        var frame = CGRect.init(x: 0, y: screenHeight-offsetY-height-20, width: screenWidth, height: height+20)
        if frame.maxY == screenHeight {
            frame.origin.y = screenHeight
        }
        contentView.frame = frame
    }
    
    /// 文本改变
    @objc private func textChanged(text: String) {
        var theight = text.size(using: textView.font!, availableWidth: textView.width - inset.left - inset.right).height
        if theight + 42 > 100 {
            theight += 42
        } else {
            theight = 100
        }
        
        if theight > 200 {
            theight = 200
        }
        
        guard textView.frame.height != theight else {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.resetTextViewHeight(theight, offsetY: screenHeight-self.contentView.frame.maxY)
        }
    }
    
    override func beforePop() {
        backgroundColor = .clear
        contentView.alpha = 1
    }
    
    override func inPoping() {
        backgroundColor = maskColor
    }
    
    override func inHiding() {
        backgroundColor = .clear
        contentView.alpha = 0
    }
    
    override func show(onView: UIView? = nil, complete: NoParamBlock? = nil) {
        super.show(onView: kWindow, complete: complete)
        textView.becomeFirstResponder()
    }
    
    override func hide(complete: NoParamBlock? = nil) {
        textView.resignFirstResponder()
        if confirmed || textView.text.isEmpty {
            super.hide(complete: complete)
        } else {
            let alert = MKAlertView.alertView(title: "温馨提示", message: "尚有内容未提交，是否退出？", style: .alert)
            alert.addCancelAction { _ in
                self.textView.becomeFirstResponder()
            }
            alert.add(action: .action(title: "退出", color: .textColorLightGray, handler: { _ in
                super.hide(complete: complete)
            }))
            alert.maskColor = .clear
            alert.show(onView: kWindow)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            confirmed = true
            inputClosure?(textView.text)
            hide()
        }
        return true
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        guard let keyRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }
        resetTextViewHeight(textView.height, offsetY: keyRect.size.height)
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        resetTextViewHeight(textView.height, offsetY: 0)
    }
}

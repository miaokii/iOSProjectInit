//
//  MKTextView.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/27.
//

import UIKit

class MKTextView: UITextView {
    
    /// 最大长度
    var maxLength: Int = -1
    /// 文本长度
    var length: Int {
        var markCount = 0
        if let markedRange = markedTextRange {
            markCount = offset(from: markedRange.start, to: markedRange.end)
        }
        return self.text.count - markCount
    }
    /// 提示文字
    var placeholder = "" {
        didSet {
            placeholderLabel.text = placeholder
            refreshPlaceHolder()
        }
    }
    /// 提示文字颜色
    var placeholderTextColor = UIColor.init(0x999999) {
        didSet {
            placeholderLabel.textColor = placeholderTextColor
        }
    }
    /// 提示富文本
    var attributedPlaceholder: NSAttributedString? {
        didSet {
            placeholderLabel.attributedText = attributedPlaceholder
            refreshPlaceHolder()
        }
    }
    /// 设置文字实时长度显示 默认为 当前长度/最大长度
    var textCountClosure:((_ label: UILabel, _ maxLength: Int, _ textCount: Int)->Void)?
    /// 文本改变
    var textChangedClosure: ((String)->Void)?
    
    override var text: String! {
        didSet {
            refreshPlaceHolder()
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            refreshPlaceHolder()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// 实时显示文本长度
    var showTextCount = false
        
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = placeholderTextColor
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = font
        label.textAlignment = textAlignment
        label.backgroundColor = .clear
        label.alpha = 0
        addSubview(label)
        return label
    }()
    
    private lazy var textCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = placeholderTextColor
        label.font = font
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .right
        label.backgroundColor = self.backgroundColor
        label.cornerRadius = 2
        label.clipsToBounds = true
        self.superview?.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -self.textContainerInset.right),
                label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.textContainerInset.bottom)
            ]
        )
        return label
    }()
    
    fileprivate var placeholderInsets: UIEdgeInsets {
        return .init(top: textContainerInset.top, left: textContainerInset.left + textContainer.lineFragmentPadding, bottom: textContainerInset.bottom, right: textContainerInset.right + textContainer.lineFragmentPadding)
    }
    
    override var delegate: UITextViewDelegate? {
        set {
            super.delegate = newValue
        }
        get {
            refreshPlaceHolder()
            return super.delegate
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPlaceHolder), name: UITextView.textDidChangeNotification, object: self)
        textCountClosure = { label, max, count in
            label.text = "\(count)/\(max)"
        }
        
        font = .systemFont(ofSize: 15)
    }
    
    @objc private func refreshPlaceHolder() {
        editDidChange()
        
        if placeholder.count == 0 {
            return
        }
        
        let markRange = markedTextRange ?? .init()
        let markEmpty = offset(from: markRange.start, to: markRange.end) == 0
        
        if length > 0 || !markEmpty {
            placeholderLabel.alpha = 0
        } else {
            placeholderLabel.alpha = 1;
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func editDidChange() {
        if maxLength <= 0 {
            return
        }
        
        if markedTextRange == nil, length > maxLength {
            let idx = text.index(text.startIndex, offsetBy: maxLength)
            text = String(text[..<idx])
        }
        
        textChangedClosure?(text)
        
        if let countBlock = textCountClosure {
            countBlock(textCountLabel, maxLength, length)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if length == 0 {
            placeholderLabel.frame = placeholderExpectedFrame()
        }
        if showTextCount {
            textCountLabel.isHidden = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func placeholderExpectedFrame() -> CGRect {
        let maxWidth = frame.width - placeholderInsets.left - placeholderInsets.right
        let expectedSize = placeholderLabel.sizeThatFits(.init(width: maxWidth, height: frame.height-placeholderInsets.top-placeholderInsets.bottom))
        return .init(x: placeholderInsets.left, y: placeholderInsets.top, width: maxWidth, height: expectedSize.height)
    }
    
    private func countLabelExpectedFrame() -> CGRect {
        let maxWidth = frame.width - placeholderInsets.left - placeholderInsets.right
        let expectedSize = textCountLabel.sizeThatFits(.init(width: maxWidth, height: frame.height-placeholderInsets.top-placeholderInsets.bottom))
        return .init(x: frame.width-placeholderInsets.right-expectedSize.width, y: frame.height-placeholderInsets.bottom-expectedSize.height, width: expectedSize.width, height: expectedSize.height)
    }
    
    override var intrinsicContentSize: CGSize {
        if hasText {
            return super.intrinsicContentSize
        }
        
        var newSize = super.intrinsicContentSize
        newSize.height = placeholderExpectedFrame().size.height + placeholderInsets.top + placeholderInsets.bottom
        return newSize
    }
}

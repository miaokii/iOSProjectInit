//
//  SearchBar.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/12/25.
//

import UIKit
import SnapKit

class SearchBar: UIView, UITextFieldDelegate {
    var inSearch: Bool! {
        return textField.text?.notEmpty ?? false
    }
    
    var textField: MKTextField {
        searchField
    }
    
    var horizontalSpacing: CGFloat = 15 {
        didSet {
            textField.snp.updateConstraints { make in
                make.left.equalTo(horizontalSpacing)
                make.right.equalTo(-horizontalSpacing)
            }
        }
    }
    
    var searchHeight: CGFloat = 34 {
        didSet {
            heightConstraint.layoutConstraints.first?.constant = searchHeight
            if (searchField.cornerRadius > 0) {
                searchField.cornerRadius = searchHeight / 2
            }
        }
    }
    
    var cancelAlwaysShow: Bool = false {
        didSet {
            textField.rightViewMode = cancelAlwaysShow ? .always : .whileEditing
        }
    }
    
    /// 搜索文字变化
    var searchTextChanged: ((String)->Void)?
    /// 执行搜索
    var confirmSearchClosure: ((String)->Void)?
    /// 取消
    var cancelSearchClosure: NoParamBlock?
    
    private var heightConstraint: Constraint!
    
    override var backgroundColor: UIColor? {
        didSet {            
            searchField.backgroundColor = backgroundColor
        }
    }
    
    private var searchField: MKTextField!
    override init(frame: CGRect) {
        super.init(frame: frame)
        searchField = MKTextField.init(superView: self, textColor: .textColorDarkGray, placeHolder: "搜索客户姓名/ID/手机号", font: .regular(14), cornerRadius: 17)
        searchField.returnKeyType = .search
        searchField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            heightConstraint = make.height.equalTo(searchHeight).constraint
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        let leftView = UIView.init()
        searchField.leftView = leftView
        searchField.leftViewMode = .always
        searchField.delegate = self
        let searchIcon = UIImageView.init(superView: leftView, image:
                .init(named: "img_search")?.withColor(.placeHolderColor))
        searchIcon.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
        }
        searchField.addTarget(self, action: #selector(searchTextDidChanged), for: .editingChanged)
        
        let rightView = UIView.init()
        searchField.rightView = rightView
        searchField.rightViewMode = .whileEditing
        
        let cancelBtn = UIButton.init(superView: rightView, title: "取消", titleColor: .textColorGray, font: textField.font!)
        cancelBtn.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
        cancelBtn.setClosure { [weak self] sender in
            self?.textField.text = ""
            self?.textField.resignFirstResponder()
            self?.cancelSearchClosure?()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: screenWidth-50, height: navBarHeight)
    }
    
    @objc private func searchTextDidChanged() {
        if let range = searchField.markedTextRange, !range.isEmpty {
            return
        }
        let text = searchField.text ?? ""
        searchTextChanged?(text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.notEmpty {
            confirmSearchClosure?(text)
        } else {
            cancelSearchClosure?()
        }
    }
}


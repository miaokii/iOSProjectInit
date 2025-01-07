//
//  FromCell.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/2.
//

import UIKit
import SnapKit

class FromBaseCell: KKTableCell {
    
    var titleLabel = UILabel.init()
    var formModel: FormModel!
    
    override func setup() {
        contentView.addSubview(titleLabel)
        
        titleLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width*0.3
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.numberOfLines = 0
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(55)
        }
    }
    
    func set(form: FormModel) {
        self.formModel = form
        
        backgroundColor = form.backgroundColor
        
        if form.necessary, form.showNecessary {
            let attributeString = NSMutableAttributedString()
            attributeString.append(.init(string: form.title, attributes: [.foregroundColor : form.titleColor, .font: form.titleFont]))
            attributeString.append(.init(string: " *", attributes: [.foregroundColor : form.necessaryColor, .font: form.titleFont]))
            titleLabel.attributedText = attributeString
        } else {
            titleLabel.text = form.title
            titleLabel.textColor = form.titleColor
            titleLabel.font = form.titleFont
        }
        
        accessoryType = form.accessoryType
        accessoryView = form.accessoryView
    }
}


class FormInputTextCell: FromBaseCell {
    
    var valueField = MKTextField()
    /// 结束编辑
    var didEndEdit: ((String) -> Void)?
    /// 开始编辑，实现此属性不会弹出键盘，自定义输入方式
    var customInput: (()->Void)?
    /// 内容改变
    var valueChanged: ((String)->Void)?
    
    override func setup() {
        super.setup()
                
        valueField.delegate = self
        valueField.clearsOnBeginEditing = true
        valueField.textAlignment = .left
        contentView.addSubview(valueField)
        valueField.snp.makeConstraints { (snp) in
            snp.left.equalTo(titleLabel.snp.right).offset(10)
            snp.top.bottom.equalToSuperview()
            snp.right.equalTo(-10)
        }
        
        valueField.addTarget(self, action: #selector(textFieldValueChanged), for: .editingChanged)
    }
    
    override func set(form: FormModel) {
        super.set(form: form)

        valueField.placeholder = form.placeholder
        valueField.clearsOnBeginEditing = form.clearsOnBeginEditing
        valueField.clearButtonMode = form.showClear ? .whileEditing : .never
        valueField.textColor = form.valueColor
        valueField.font = form.valueFont
        valueField.text = form.label
        valueField.isSecureTextEntry = form.isSecureTextEntry
        valueField.keyboardType = form.keyboardType
        valueField.inputView = form.inputView
        valueField.isEnabled = form.isEditEnable
        valueField.textAlignment = form.aligment
        
        if form.length > 0 {
            valueField.maxLength = form.length
        }
        
        customInput = form.customInput
        didEndEdit = form.didEndEdit
        valueChanged = form.valueChanged
    }
    
    @objc func textFieldValueChanged(_ field: MKTextField) {
        
    }
}

extension FormInputTextCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let beginEditClosure = customInput else {
            return true
        }
        beginEditClosure()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == valueField else {
            return true
        }
        guard let numModel = formModel as? NumberFormModel else {
            return true
        }
        
        if let max = numModel.max {
            let text = (textField.text ?? "") + string
            let value = Float(text) ?? 0
            
            if value > max {
                return false
            } else if value == max {
                return string != "."
            } else {
                // 限制小数位数
                if let precision = numModel.precision, precision > 0 {
                    // 小数点分隔
                    let decimals = text.components(separatedBy: ".")
                    // 如果没有小数点
                    if decimals.count == 1 {
                        return true
                    }
                    // 如果只有一个小数点
                    else if decimals.count == 2 {
                        // 判断小数点后的位数
                        return decimals[1].count <= precision
                    }
                    // 小数点多于一个
                    else {
                        return false
                    }
                }
                return true
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField == valueField else { return }
        self.didEndEdit?(textField.text ?? "")
    }
}

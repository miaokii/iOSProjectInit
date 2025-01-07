//
//  MKVerifyCodeView.swift
//  MuYunControl
//
//  Created by yoctech on 2023/8/16.
//

import UIKit

// MARK: - 输入码的输入框
class MKVerifyCodeView: UIStackView, UITextFieldDelegate {
    
    var codeBlock: ((String) -> Void)?
    var verifyCount: Int = 4 {
        didSet {
            setLabels()
        }
    }
    
    private var codeLabels = [UILabel]()
    private let textfield = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        spacing = -1
        distribution = .fillEqually
        alignment = .fill
        borderColor = .init(0xCCCCCC)
        borderWidth = 1
        cornerRadius = 5
        clipsToBounds = true
        
        textfield.isHidden = true
        textfield.keyboardType = .numberPad
        textfield.delegate = self
        addSubview(textfield)
        textfield.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        setLabels()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLabels() {
        guard verifyCount > 0 else {
            return
        }
        codeLabels.removeAll()
        arrangedSubviews.forEach { subView in
            removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
        for _ in Range(0...verifyCount - 1) {
            let codeLabel = UILabel(superView: nil, textColor: .textColorBlack, font: .bold(17), aligment: .center)
            codeLabel.borderWidth = borderWidth
            codeLabel.borderColor = borderColor
            codeLabels.append(codeLabel)
            addArrangedSubview(codeLabel)
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard verifyCount > 0, codeLabels.count == verifyCount else {
            return
        }
        
        guard textField.text!.count <= verifyCount else {
            textField.text = String(textField.text!.prefix(4))
            return
        }
        
        var index = 0
        for char in textField.text! {
            codeLabels[index].text = String(char)
            index += 1
        }
        guard index < verifyCount else {
            
            self.endEditing(true)
            
            if let complete = self.codeBlock {
                complete(textField.text!)
            }
            return
        }
        for i in Range(index...verifyCount-1) {
            codeLabels[i].text = ""
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textfield.becomeFirstResponder()
    }
}

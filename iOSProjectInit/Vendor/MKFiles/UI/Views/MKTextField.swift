//
//  MKTextField.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/26.
//

import UIKit

class MKTextField: UITextField {
    
    /// 设置最大文本长度
    var maxLength: UInt = .max
    
    /// 输入文本的长度
    var length: Int {
        get {
            guard let text = text else {
                return 0
            }
            guard let markRange = markedTextRange else {
                return text.count
            }
            return text.count - self.offset(from: markRange.start, to: markRange.end)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addTarget(self, action: #selector(self.editDidChanged), for: .editingChanged)
    }
    
    @objc private func editDidChanged() {
        if self.maxLength == 0 {
            return
        }
        
        let textLength = self.text?.count ?? 0
        
        // 如果正在编辑，不计算在内
        if let range = markedTextRange, !range.isEmpty {
                        
        } else if (textLength > maxLength) {
            self.text = text?.subString(range: 0..<Int(self.maxLength))
        }
    }
}

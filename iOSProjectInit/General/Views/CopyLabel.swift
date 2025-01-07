//
//  CopyLabel.swift
//  RXCSaaS
//
//  Created by yoctech on 2024/1/5.
//

import UIKit

/// 带有复制功能的label
class CopyLabel: UILabel {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.addGestureRecognizer(longPressGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        guard let text = text, text.notEmpty, text != "-" else {
            return
        }
        if sender.state == .began {
            self.becomeFirstResponder()
            
            let menu = UIMenuController.shared
            let copyItem = UIMenuItem(title: "复制", action: #selector(copyText))
            menu.menuItems = [copyItem]
            menu.showMenu(from: self, rect: self.bounds)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copyText)
    }

    @objc func copyText() {
        guard let text = self.text else { return }
        UIPasteboard.general.string = text
    }
}


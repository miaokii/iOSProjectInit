//
//  Extension.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/11/20.
//

import UIKit
import Kingfisher

// MARK: - 通知
extension Notification.Name {
    /// 刷新用户信息
    static let refreshUserInfo = Notification.Name.init(rawValue: "refreshUserInfo")
    
    /// 刷新应用
    static let refreshApplications = Notification.Name.init(rawValue: "refreshApplications")
    /// 刷新paas表单
    static let refreshPAAS = Notification.Name.init(rawValue: "refreshPAAS")
    
    /// 刷新消息
    static let messageRefresh = Notification.Name.init(rawValue: "messageRefresh")
    
    /// 轮呼呼叫下一个
    static let pollCallNext = Notification.Name.init(rawValue: "pollCallNext")
    /// 轮呼停止
    static let pollCallStop = Notification.Name.init(rawValue: "pollCallStop")
    /// 轮呼不等待倒计时配置
    static let pollCallImmediately = Notification.Name.init(rawValue: "pollCallImmediately")
    /// 轮呼刷新
    static let pollCallRefresh = Notification.Name.init(rawValue: "pollCallRefresh")
    /// 轮呼开关操作
    static let pollCallSwitch = Notification.Name.init(rawValue: "pollCallSwitch")
    
    /// 联系情况更改了
    static let callMarkUpdated = Notification.Name.init(rawValue: "callMarkUpdated")
}

extension String {
    var dictionary: AFParam? {
        guard let data = data(using: .utf8),
              let jsonDic = try? JSONSerialization.jsonObject(with: data) as? AFParam else {
            return nil
        }
        return jsonDic
    }
    
    var array: [Any]? {
        guard let data = data(using: .utf8),
              let jsonArr = try? JSONSerialization.jsonObject(with: data) as? [Any] else {
            return nil
        }
        return jsonArr
    }
    
    var jsonObj: Any? {
        guard let data = data(using: .utf8),
              let jsonObj = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        return jsonObj
    }
    
    var boolValue: Bool? {
        switch self.lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    /// 电话号码加密显示
    var phoneEncryption: String {
        guard isPhone else {
            return self
        }
        return "\(self[0..<3])****\(self[7..<11])"
    }
    
    /// 身份证号码加密显示
    var idCardEncryption: String {
        guard isIdCardStrict else {
            return self
        }
        return "\(self[0..<2])**************\(self[count-2..<count])"
    }
    
    /// 子子字符串位置
    func intRange(of subString: String) -> Range<Int>? {
        guard let range = self.range(of: subString) else { return nil }
        let lowerBound = distance(from: self.startIndex, to: range.lowerBound)
        let upperBound = distance(from: self.startIndex, to: range.upperBound)
        
        return lowerBound..<upperBound
    }
    
    /// 子子字符串位置
    func nsRange(of subString: String) -> NSRange? {
        guard let range = self.range(of: subString) else { return nil }
        let lowerBound = distance(from: self.startIndex, to: range.lowerBound)
        let upperBound = distance(from: self.startIndex, to: range.upperBound)
        
        return .init(location: lowerBound, length: upperBound-lowerBound)
    }
}

extension TimeInterval {
    var durationTime: String {
        let duration = Int32(self)
        var durationString = ""
        if duration < 60 {
            durationString = String.init(format: "00:%.2d", duration)
        } else if duration < 3600 {
            durationString = String.init(format: "%.2d:%.2d", duration / 60, duration % 60)
        } else {
            durationString = String.init(format: "%.2d:%.2d:%.2d", duration / 3600, duration % 3600,(duration % 3600) % 60)
        }
        return durationString
    }
}

extension Set where Element == String {
    mutating func insert(contentsOf array: [String]) {
        array.forEach{ self.insert($0) }
    }
    
    mutating func remove(contentsOf array: [String]) {
        array.forEach{ self.remove($0) }
    }
}

extension UITableView {
    func reloadNoAnimation(sections: IndexSet) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        reloadSections(sections, with: .none)
        CATransaction.commit()
    }
    
    func reloadNoAnimation(indexpaths: [IndexPath]) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        reloadRows(at: indexpaths, with: .none)
        CATransaction.commit()
    }
}

extension UIColor {
    static let danger: UIColor = .init(0xF53F3F)
    static let primary: UIColor = .theme
    static let primary_light: UIColor = .init(0xE7F4FE)
}

extension UIButton {

    static func primaryLightBtn(superView: UIView? = nil,
                                title: String = "取消",
                                font: UIFont = .systemFont(ofSize: 14),
                                cornerRadius: CGFloat = 3,
                                target_selector: (Any, Selector)? = nil) -> UIButton {
        UIButton.init(superView: superView, title: title, titleColor: .theme, backgroundImage: .init(color: .primary_light), font: font, cornerRadius: cornerRadius, target_selector: target_selector)
    }
}

extension UIImage {
    static let chevronLeft: UIImage? = .init(systemName: "chevron.left")
    static let chevronRight: UIImage? = .init(systemName: "chevron.right")
    static let chevronUp: UIImage? = .init(systemName: "chevron.up")
    static let chevronDown: UIImage? = .init(systemName: "chevron.down")
    
    static let plus: UIImage? = .init(systemName: "plus")
    
    static let xmark: UIImage? = .init(systemName: "xmark")
    static let checkmark: UIImage? = .init(systemName: "checkmark")
    static let folderPlus: UIImage? = .init(systemName: "folder.badge.plus")
    
    static let checkSquare: UIImage? = .init(systemName: "square")
    static let checkSquareFill: UIImage? = .init(systemName: "checkmark.square.fill")
    
    static let checkCircle: UIImage? = .init(systemName: "circle")
    static let checkCircleFill: UIImage? = .init(systemName: "checkmark.circle.fill")
}

extension UIImageView {
    func set(image: Any) {
        if let image = image as? UIImage {
            self.image = image
        }
        else if let url = image as? String {
            kf.indicatorType = .activity
            kf.setImage(with: ossFullUrl(url))
        }
    }
}

extension Array {
    var notEmpty: Bool {
        !isEmpty
    }
}

import SnapKit
extension Constraint {
    var constant: CGFloat! {
        get {
            self.layoutConstraints.first?.constant ?? 0
        }
        
        set {
            self.layoutConstraints.first?.constant = newValue
        }
    }
}

extension ConstraintPriority {
    static var extremely: ConstraintPriority {
        return 999.0
    }
}

import TextAttributes
extension NSMutableAttributedString {
    
    
    func setAlignment(_ alignment: NSTextAlignment = .left, lineSpacing: CGFloat = 5) {
        addAttributes(TextAttributes().alignment(alignment).lineSpacing(lineSpacing), range: .init(location: 0, length: length))
    }
    
    func append(string: String, color: UIColor, font: UIFont? = nil) {
        let att = TextAttributes().foregroundColor(color).lineSpacing(5)
        if let font = font {
            att.font(font)
        }
        append(.init(string: string, attributes: att))
    }
    
    func appendAttachment(image: UIImage?, size: CGSize, font: UIFont?) {
        
        let attachment = NSTextAttachment.init()
        attachment.image = image
        var attachOrigin = CGPoint.zero
        if let font = font {
            attachOrigin = CGPoint.init(x: 0, y: -(size.height - font.ascender - font.descender) / 2)
        } else {
            attachOrigin = CGPoint.init(x: 0, y: -size.height/2)
        }
        attachment.bounds = CGRect(origin: attachOrigin, size: size)
        append(.init(attachment: attachment))
    }
}


extension MKAlertView {
    
    enum AlertMsgType {
        case danger
        case success
        case warning
        case error
        
        var image: UIImage? {
            switch self {
            case .danger:
                return .init(named: "img_alert_danger")
            default:
                return .init(named: "img_alert_warning")
            }
        }
    }
    
    static func alert(type: AlertMsgType, message: String = "成功", attributeMessage: NSAttributedString? = nil, cancelTitle: String? = "取消", cancel: NoParamBlock? = nil, confirmTitle: String = "确定", confirm: NoParamBlock? = nil) {
        
        let alertView = MKAlertView.alertView(title: nil, message: nil, style: .alert)
        if let cancelTitle = cancelTitle {
            alertView.add(action: .action(title: cancelTitle, color: .textColorGray, style: .cancel, handler: { _ in
                cancel?()
            }))
        }
        alertView.add(action: .action(title: confirmTitle, color: .theme, style: .confirm, handler: { _ in
            confirm?()
        }))
        
        let attTitleMsg = NSMutableAttributedString()
        attTitleMsg.appendAttachment(image: type.image, size: .init(width: 42, height: 42), font: nil)
        alertView.attributeTitle = attTitleMsg
        
        if let attributeMessage = attributeMessage {
            alertView.attributeMessage = attributeMessage
        } else {
            let attMessage = NSMutableAttributedString()
            attMessage.append(string: message, color: .textColorBlack, font: .medium(16))
            attMessage.setAlignment(.center)
            alertView.attributeMessage = attMessage
        }
        
        alertView.space = 20
        alertView.show()
    }
    
    static func alertDanger(message: String = "删除后数据无法恢复，确定要删除吗？", attributeMessage: NSAttributedString? = nil, cancelTitle: String? = "取消", cancel: NoParamBlock? = nil, confirmTitle: String = "确定", confirm: NoParamBlock? = nil) {
        
        alert(type: .danger, message: message, attributeMessage: attributeMessage, cancelTitle: cancelTitle, cancel: cancel, confirmTitle: confirmTitle, confirm: confirm)
    }
}

extension UIView {
    private static let redDotTag = 100110
    func addRedDot() {
        guard !subviews.contains(where: { $0.tag == Self.redDotTag }) else {
            return
        }
        
        let redDot = UIView.init(super: self, backgroundColor: .init(0xE25049), cornerRadius: 4)
        redDot.tag = Self.redDotTag
        redDot.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.size.equalTo(8)
        }
    }
    
    func removeRedDot() {
        guard let redDot = subviews.first(where: { $0.tag == Self.redDotTag }) else {
            return
        }
        redDot.removeFromSuperview()
    }
}

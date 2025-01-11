//
//  FormModel.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/2.
//

import UIKit

/// 表单数据model
class FormModel {
    /// key
    var key: String = ""
    /// 标题
    var title: String = ""
    /// 值
    var label: String = ""
    /// 值
    var value: String = ""
    /// 限制长度
    var length: UInt = .max
    /// 标题字号
    var titleFont: UIFont = UIFont.systemFont(ofSize: 16)
    /// 标题颜色
    var titleColor: UIColor = .black
    /// 内容字号
    var valueFont: UIFont = UIFont.systemFont(ofSize: 16)
    /// 内容颜色
    var valueColor: UIColor = .black
    /// 背景色
    var backgroundColor: UIColor = .white
    /// 提示文本
    var placeholder: String? = nil
    /// 键盘类型
    var keyboardType: UIKeyboardType = .default
    /// 输入的view
    var inputView: UIView? = nil
    /// 允许编辑
    var isEditEnable = true
    /// cell类型
    var cellType: FormBaseCell.Type = FormBaseCell.self
    /// 对齐方式
    var aligment: NSTextAlignment = .left
    /// 必填项 显示为 红色的 *
    var necessary = true
    /// 是否显示 必填 红色的 *
    var showNecessary = false
    /// 必填标记颜色
    var necessaryColor = UIColor.red
    /// 安全显示
    var isSecureTextEntry = false
    /// 清空按钮
    var showClear = false
    /// 编辑时清空
    var clearsOnBeginEditing = false
    /// 附件类型
    var accessoryType: UITableViewCell.AccessoryType = .none
    /// 附件视图
    var accessoryView: UIView? = nil
    
    /// 存储值
    var object: Any?
    /// 存储值，多个
    var objects: [Any]?
    
    /// 附属
    var param: [String: Any?] = [:]
    /// 是否为空
    var isEmpty: Bool {
        return self.label.count == 0
    }
    
    var errMsg: String? {
        "\(placeholder ?? "")\(title)"
    }
    
    /// 实现此属性不会弹出键盘，自定义输入方式
    var customInput: (()->Void)? = nil
    /// 结束编辑
    var didEndEdit: ((String) -> Void)? = nil
    /// 内容改变
    var valueChanged: ((String) -> Void)? = nil
    
    init() {
        self.didEndEdit = { [unowned self] (value) in
            self.label = value
            self.value = value
        }
    }
    
    func update(value: String, label: String? = nil) {
        self.value = value
        if let l = label {
            self.label = l
        } else {
            self.label = value
        }
    }
    
    func clear() {
        value = ""
        label = ""
        object = nil
        objects = nil
    }
}

extension FormModel: Equatable {
    static func == (lhs: FormModel, rhs: FormModel) -> Bool {
        return lhs.key == rhs.key && lhs.title == rhs.title;
    }
}

class PickerFormModel: FormModel {
    var options = [String]()
}

class NumberFormModel: FormModel {
    var max: Float?
    var min: Float?
    var number: NSNumber = 0
    var precision: UInt? {
        didSet {
            guard let val = precision else {
                return
            }
            if val <= 0 {
                keyboardType = .numberPad
            }
        }
    }
    
    override init() {
        super.init()
        keyboardType = .decimalPad
    }
}

extension Array where Element: FormModel {
    func registerCellType(to tableView: UITableView) {
        self.forEach { form in
            tableView.register(cellType: form.cellType)
        }
    }
}


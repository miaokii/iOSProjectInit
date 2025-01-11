//
//  StaticTableModel.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/2.
//

import UIKit

typealias NoParamBlock = ()->Void

class StaticTableModel: FormModel {
    /// 图标
    var icon: UIImage? = nil
    /// 描述
    var detail: String? = nil
    /// 允许复制
    var copyEnable = true
    /// 点击事件
    var tapBlock: NoParamBlock? = nil
    var detailRedDot: Bool = false
    
    static func model(icon: UIImage? = nil, title: String, detail: String? = nil, showAccess: Bool = true, tapBlock: NoParamBlock? = nil) -> StaticTableModel {
        let model = StaticTableModel.init()
        model.cellType = StaticTableCell.self
        model.title = title
        model.icon = icon
        model.detail = detail
        model.backgroundColor = .white
        model.tapBlock = tapBlock
        model.copyEnable = false
        model.titleFont = .regular(16)
        model.titleColor = .black
        
        if showAccess {
            model.accessoryType = .disclosureIndicator
        }
        
        return model
    }
}

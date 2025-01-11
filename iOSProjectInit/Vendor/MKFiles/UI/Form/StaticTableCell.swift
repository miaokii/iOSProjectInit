//
//  StaticTableCell.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/2.
//

import UIKit

class StaticTableCell: FormBaseCell {
    
    var iconView: UIImageView!
    var detailLabel: UILabel!
    var model: StaticTableModel!
    var detailRedDotView: UIView!
    
    override func setup() {
        iconView = UIImageView.init(superView: contentView)
        iconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        detailLabel = UILabel.init(superView: contentView)
        detailLabel.font = .systemFont(ofSize: 15)
        detailLabel.textColor = .gray
        detailLabel.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(55)
        }
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        detailRedDotView = .init(super: contentView, backgroundColor: .red, cornerRadius: 3)
        detailRedDotView.snp.makeConstraints { make in
            make.centerY.equalTo(detailLabel)
            make.left.equalTo(detailLabel.snp.right)
            make.size.equalTo(6)
        }
        
        titleLabel = UILabel.init(superView: contentView)
        titleLabel.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(iconView.snp.right).offset(10)
            make.right.lessThanOrEqualTo(detailLabel.snp.left).offset(-10)
        }
    }
    
    override func set(form: FormModel) {
        super.set(form: form)
        self.model = form as? StaticTableModel
        
        iconView.isHidden = model.icon == nil
        if let image = model.icon {
            iconView.image = image
        }
        
        titleLabel.font = model.titleFont
        titleLabel.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            if iconView.isHidden {
                make.left.equalTo(15)
            } else {
                make.left.equalTo(iconView.snp.right).offset(10)
            }
            if let _ = detailLabel.superview {
                make.right.lessThanOrEqualTo(detailLabel.snp.left).offset(-10)
            }
        }
        
        detailLabel.isHidden = model.detail == nil
        if let detail = model.detail {
            detailLabel.text = detail
            detailLabel.font = model.valueFont
            detailLabel.textColor = model.valueColor
        } else {
            detailLabel.text = ""
        }
        
        accessoryType = model.accessoryType
        accessoryView = model.accessoryView
        
        titleLabel.textColor = model.isEditEnable ? model.titleColor : .textColorGray
        detailRedDotView.isHidden = !model.detailRedDot
    }
}

class StaticSwitchCell: StaticTableCell {
    
    private var switchView: UIButton!
    private var switchClosure: NoParamBlock?
    
    override func setup() {
        super.setup()
        
        switchView = UIButton(superView: contentView, normalImage: .init(named: "img_switch_off"), selectedImage: .init(named: "img_switch_on"))
        switchView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
        
        switchView.setClosure { [weak self] sender in
            self?.switchClosure?()
        }
    }
    
    override func set(form: FormModel) {
        super.set(form: form)
        guard let model = form as? StaticTableModel else {
            switchClosure = nil
            return
        }
        switchClosure = model.tapBlock
        switchView.isSelected = model.object as? Bool ?? false
        switchView.isEnabled = model.isEditEnable
    }
}

//
//  PopBottomView.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/12/12.
//

import UIKit

/// 定制样式，取消和确认在底下，标题栏靠左
class PopBottomView: MKPopBottomView {
        
    override func setDefault() {
        super.setDefault()
        
        showNavBarSeparator = true
        
        titleLabel.font = .medium(16)
        cancelBtn.borderColor = .theme
        cancelBtn.setBackgroundImage(.init(color: .white), for: .normal)
        cancelBtn.setBackgroundImage(.init(color: .background), for: .highlighted)
        cancelBtn.borderWidth = 1
        cancelBtn.cornerRadius = 3
        cancelBtn.contentHorizontalAlignment = .center
        cancelBtn.setNormal(title: "取消")
        cancelBtn.setNormal(titleColor: .theme)
        
        confirmBtn.setBackgroundImage(.init(color: .theme), for: .normal)
        confirmBtn.cornerRadius = 3
        confirmBtn.clipsToBounds = true
        confirmBtn.contentHorizontalAlignment = .center
        confirmBtn.setNormal(title: "确认")
        confirmBtn.setNormal(titleColor: .white)
        
        contentView.addSubview(cancelBtn)
        contentView.addSubview(confirmBtn)
    }
    
    override func appendSubviews() {
        super.appendSubviews()
        
        cancelBtn.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.bottom.equalTo(-offsetBottom(value: 15))
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.height.equalTo(45)
        }
        confirmBtn.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.bottom.height.equalTo(cancelBtn)
        }
        titleLabel.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
    }
}

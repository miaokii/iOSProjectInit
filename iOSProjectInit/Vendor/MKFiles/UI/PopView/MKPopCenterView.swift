//
//  MKPopCenterView.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/11/28.
//

import UIKit

class MKPopCenterView: MKPopParentView {

    var cancelBtn = LGButton.button(title: "取消", titleColor: .textColorGray, font: UIFont.medium(16), bgColor: .white)
    var confirmBtn = LGButton.button(title: "确认", titleColor: .theme, font: UIFont.medium(16), bgColor: .white)
    var centerContainer = UIView()
    
    override func setDefault() {
        super.setDefault()
        popStyle = .center
        cornerRadii = 10
        corner = .allCorners
        layoutWhenKeyBoardShow = true
        hideOnTapBackground = false
    }
    
    override func appendSubviews() {
        super.appendSubviews()
        
        contentView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        contentView.addSubview(centerContainer)
        centerContainer.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        
        let line = UIView(super: contentView, backgroundColor: .background)
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(centerContainer.snp.bottom)
        }
        
        let cline = UIView.init(super: contentView, backgroundColor: .background)
        cline.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
            make.top.equalTo(line.snp.bottom)
        }
        
        contentView.addSubview(cancelBtn)
        cancelBtn.setClosure { [weak self] sender in
            self?.hide()
        }
        cancelBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.top.equalTo(cline)
            make.right.equalTo(cline.snp.left)
        }
        
        contentView.addSubview(confirmBtn)
        confirmBtn.setClosure {[weak self] sender in
            self?.confirmAction()
        }
        confirmBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(cline)
            make.left.equalTo(cline.snp.right)
            make.right.equalToSuperview()
        }
    }
    
    func confirmAction() {
        self.hide()
    }
}

//
//  MKPopBottomView.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/6.
//

import UIKit

class MKPopBottomView: MKPopParentView {

    var title: String?
    var cancelTitle: String?
    var confirmTitle: String?

    var confirmButtonConfig:((UIButton)->Void)? = nil
    var cancelButtonConfig:((UIButton)->Void)? = nil
    var titleLabelConfig:((UILabel)->Void)? = nil
    
    var cancelBlock: NoParamBlock?
    
    var fullScreen = false
    
    lazy var navBarView: UIView = {
        let navView = UIView.init()
        navView.backgroundColor = .white
        contentView.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            if fullScreen {
                make.height.equalTo(navAllHeight)
            } else {
                make.height.equalTo(60)
            }
        }
        return navView
    }()
    
    lazy var cancelBtn: UIButton = {
        let button = UIButton.init()
        button.setTitleColor(.init(0x666666), for: .normal)
        button.titleLabel?.font = .medium(16)
        navBarView.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.bottom.equalTo(titleLabel)
        }
        button.setClosure { [weak self] sender in
            self?.cancelBlock?()
            self?.hide()
        }
        return button
    }()
    
    lazy var confirmBtn: UIButton = {
        let button = UIButton.init()
        button.setTitleColor(.theme, for: .normal)
        button.titleLabel?.font = .medium(16)
        navBarView.addSubview(button)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(confirmHandle), for: .touchUpInside)
        button.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.top.bottom.equalTo(titleLabel)
        }
        return button
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        navBarView.addSubview(label)
        label.textColor = .black
        label.font = .medium(16)
        label.numberOfLines = 0
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            if fullScreen {
                make.top.equalTo(statusBarHeight)
            } else {
                make.top.equalToSuperview()
            }
        }
        return label
    }()
    
    lazy var separatorView: UIView! = {
        let separator = UIView.init(super: navBarView, backgroundColor: .background)
        separator.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        return separator
    }()
    
    var showNavBarSeparator: Bool = false {
        didSet {
            separatorView.isHidden = !showNavBarSeparator
            navBarView.bringSubviewToFront(separatorView)
        }
    }
    
    override func setDefault() {
        super.setDefault()
        popStyle = .bottom
        
        cancelTitle = "取消"
        confirmTitle = "确认"
    }
    
    override func appendSubviews() {
        super.appendSubviews()
        if fullScreen {
            contentView.snp.remakeConstraints { make in
                make.edges.equalTo(0)
            }
        }
    }
    
    override func dynamicSubviews() {
        super.dynamicSubviews()
        
        if let title = title {
            titleLabel.text = title
        }
        if let titleConfig = titleLabelConfig {
            titleConfig(titleLabel)
        }
        
        if let cancelTitle = cancelTitle {
            cancelBtn.setTitle(cancelTitle, for: .normal)
        }
        if let cancelConfig = cancelButtonConfig {
            cancelConfig(cancelBtn)
        }
        
        if let confirmTitle = confirmTitle {
            confirmBtn.setTitle(confirmTitle, for: .normal)
        }
        if let confirmConfig = confirmButtonConfig {
            confirmConfig(confirmBtn)
        }
    }
    
    @objc func confirmHandle() {
        hide()
    }
}

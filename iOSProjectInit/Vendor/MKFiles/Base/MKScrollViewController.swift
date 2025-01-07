//
//  ScrollViewController.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/26.
//

import UIKit

class MKScrollViewController: MKBaseViewController {

    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init()
        scroll.backgroundColor = .background
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .never
        view.addSubview(scroll)
        scroll.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        return scroll
    }()
    
    lazy var scrollContainer: UIView = {
        let container = UIView.init()
        scrollView.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalTo(0)
            make.width.equalTo(view)
        }
        return container
    }()
    
    var mjheader: RefreshHeader? {
        scrollView.mj_header as? RefreshHeader
    }
    
    var allowRefresh: Bool = true {
        didSet {
            mjRefresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addScrollSubviews()
    }
    
    func addScrollSubviews() {
        
    }
    
    private func mjRefresh() {
        if allowRefresh {
            scrollView.mj_header = RefreshHeader.init(refreshingBlock: { [weak self] in
                self?.requestData()
            })
        } else {
            scrollView.mj_header = nil
        }
    }
     
    /// 下拉刷新
    func requestData() {
        
    }
    
    func reloadData() {
        if allowRefresh {
            scrollView.mj_header?.endRefreshing()
        }
    }
    
    func appendField(superView: UIView? = nil, title: String, place: String = "", maxLenght: Int, keyBoardType: UIKeyboardType = .numberPad, isLast: Bool = false) -> MKTextField {
        let fatherView = superView ?? scrollContainer
        let lastView = fatherView.subviews.last
        let sview = UIView.init(super: fatherView, backgroundColor: .white)
        sview.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            if let lastView = lastView {
                make.top.equalTo(lastView.snp.bottom).offset(1)
            } else {
                make.top.equalTo(1)
            }
            
            if isLast {
                make.bottom.equalToSuperview()
            }
        }
        
        let label = UILabel.init(superView: sview, text: title, textColor: .textColorBlack, font: .regular(15))
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.width.equalTo(100)
        }
        
        var placeHolder = place
        if placeHolder.isEmpty {
            placeHolder = "请输入\(title)"
        }
        
        let textField = MKTextField.init(superView: sview, textColor: .textColorBlack, placeHolder: placeHolder, font: .regular(15), aligment: .left, keyboardType: keyBoardType)
        textField.snp.makeConstraints { make in
            make.left.equalTo(label.snp.right).offset(15)
            make.height.top.bottom.equalToSuperview()
            make.right.equalTo(-15)
        }
        
        return textField
    }

}


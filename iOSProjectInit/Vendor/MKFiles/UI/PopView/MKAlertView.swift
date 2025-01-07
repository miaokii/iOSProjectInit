//
//  MKAlertView.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/6.
//

import UIKit

enum MKAlertStyle {
    case alert
    case sheet
}

enum MKAlertActionType {
    case cancel
    case confirm
    case `default`
}

fileprivate extension UIColor {
    /// 确定
    static let confirm = UIColor.theme
    /// 取消
    static let cancel = UIColor.textColorGray
    /// 分割线
    static let alertSeparator = UIColor.init(0xF3F7FC)
    /// 标题
    static let title = UIColor.init(0x333333)
    /// message
    static let message = UIColor.init(0x666666)
}

typealias MKAlertActionHandler = (MKAlertAction) -> Void

// MARK: - AlertView
class MKAlertView: MKPopParentView {
    
    var attributeTitle: NSAttributedString?
    var attributeMessage: NSAttributedString?
    var space: CGFloat = 15
    
    private var style: MKAlertStyle = .alert
    private var actions = [MKAlertAction]()
    private lazy var headerView: UIView = {
        let header = UIView.init()
        contentView.addSubview(header)
        header.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        return header
    }()
    
    private lazy var footerView: UIView = {
        let footer = UIView.init()
        contentView.addSubview(footer)
        footer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            if style == .sheet {
                make.bottom.equalTo(-safeAreaBottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        return footer
    }()
    private lazy var tableView: UITableView = {
        let table = UITableView.init()
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.tableFooterView = UIView()
        table.bounces = false
        table.estimatedRowHeight = 50
        table.register(cellType: MKAlertCell.self)
        contentView.addSubview(table)
        table.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        return table
    }()
    private var cancelAction: MKAlertAction?
    private var otherAction: MKAlertAction?
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func alertView(title: String? = nil, message: String? = nil, style: MKAlertStyle = .alert) -> MKAlertView {
        let alert = MKAlertView.init()
        alert.style = style
        alert.space = style == .alert ? 25 : 15
        alert.hideOnTapBackground = style == .sheet
        
        if let title = title {
            let attTitle = NSMutableAttributedString.init(string: title, attributes: [.foregroundColor: UIColor.title, .font: UIFont.bold(15)])
            alert.attributeTitle = attTitle
        }
        
        if let message = message {
            let attMsg = NSMutableAttributedString.init(string: message, attributes: [.foregroundColor: UIColor.message, .font: UIFont.regular(13)])
            alert.attributeMessage = attMsg
        }

        if (style == .alert) {
            alert.popStyle = .center
            alert.corner = .allCorners
        } else {
            alert.popStyle = .bottom
            alert.corner = [.topLeft, .topRight]
        }
        
        alert.contentView.snp.remakeConstraints { make in
            if (style == .alert) {
                make.center.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.8)
            } else {
                make.left.right.bottom.equalToSuperview()
            }
        }
        alert.cornerRadii = 10
        
        return alert
    }
    
    override func setDefault() {
        super.setDefault()
        defaultLayoutEnable = false
        actions = []
    }
    
    func add(action: MKAlertAction) {
        let contain = actions.contains { item in
            item == action
        }
        
        guard !contain else {
            return
        }
        
        if action.style == .cancel {
            if let _ = cancelAction {
                assert(false, "只能添加一个MKAlertActionStyleCancel类型的Action")
            }
            cancelAction = action
            actions.append(action)
        } else {
            actions.append(action)
        }
    }
    
    func add(actions: [MKAlertAction]) {
        actions.forEach { action in
            add(action: action)
        }
    }
    
    override func dynamicSubviews() {
        
        let needHeader = attributeTitle != nil || attributeMessage != nil
        
        if needHeader {
            var lastView: UIView? = nil
            if let attTitle = attributeTitle {
                let titleLabel = UILabel()
                titleLabel.numberOfLines = 0
                titleLabel.textAlignment = .center
                titleLabel.attributedText = attTitle
                headerView.addSubview(titleLabel)
                titleLabel.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.left.greaterThanOrEqualTo(30)
                    make.top.equalTo(space)
                    if (attributeMessage == nil) {
                        make.bottom.equalTo(-space)
                    }
                }
                lastView = titleLabel
            }
            
            if let attMsg = attributeMessage {
                let messageLable = UILabel()
                messageLable.numberOfLines = 0
                messageLable.textAlignment = .center
                messageLable.attributedText = attMsg
                headerView.addSubview(messageLable)
                messageLable.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.left.greaterThanOrEqualTo(20)
                    if let last = lastView {
                        make.top.equalTo(last.snp.bottom).offset(15)
                    } else {
                        make.top.equalTo(space)
                    }
                    make.bottom.equalTo(-space)
                }
            }
        }
        
        if let cancel = cancelAction {
            let divideView = UIView.init()
            divideView.backgroundColor = .alertSeparator
            footerView.addSubview(divideView)
            divideView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(style == .alert ? 1 : 10)
            }
            
            let cancelBtn = UIButton()
            cancelBtn.setAttributedTitle(cancel.attributedTitle, for: .normal)
            cancelBtn.setBackgroundImage(.init(color: .white), for: .normal)
            cancelBtn.setBackgroundImage(.init(color: .alertSeparator), for: .highlighted)
            footerView.addSubview(cancelBtn)
            cancelBtn.addTarget(self, action: #selector(cancelActionHandler), for: .touchUpInside)
            
            // sheet类型，底部只展示取消action
            if (style == .sheet) {
                cancelBtn.snp.makeConstraints { make in
                    make.left.right.bottom.equalToSuperview()
                    make.height.equalTo(50)
                    make.top.equalTo(divideView.snp.bottom)
                }
                actions.removeAll(where: {$0 == cancel})
            }
            // alert类型，取消类型靠左展示，只有两个action时，并列展示，
            // 多于两个，竖列展示
            else {
                // 只有一个取消action，或多于两个action
                if (actions.count != 2) {
                    cancelBtn.snp.makeConstraints { make in
                        make.top.equalTo(divideView.snp.bottom)
                        make.left.bottom.right.equalToSuperview()
                        make.height.equalTo(50)
                    }
                    actions.removeAll(where: {$0 == cancel})
                }
                // 一个取消一个其他，取消左，其他右
                else if (actions.count == 2) {

                    let otherAC = actions.first == cancel ? actions[1] : actions[0]
                    otherAction = otherAC
                    actions = []
                    
                    let centerDivide = UIView.init()
                    centerDivide.backgroundColor = .alertSeparator
                    footerView.addSubview(centerDivide)
                    centerDivide.snp.makeConstraints { make in
                        make.centerX.equalToSuperview()
                        make.top.equalTo(divideView.snp.bottom)
                        make.width.equalTo(1)
                        make.bottom.equalToSuperview()
                    }
                    
                    cancelBtn.snp.makeConstraints { make in
                        make.top.equalTo(divideView.snp.bottom)
                        make.left.bottom.equalToSuperview()
                        make.height.equalTo(50)
                        make.right.equalTo(centerDivide.snp.left)
                    }
                    
                    let otherBtn = UIButton.init()
                    otherBtn.setBackgroundImage(.init(color: .white), for: .normal)
                    otherBtn.setBackgroundImage(.init(color: .alertSeparator), for: .highlighted)
                    otherBtn.setAttributedTitle(otherAC.attributedTitle, for: .normal)
                    footerView.addSubview(otherBtn)
                    otherBtn.snp.makeConstraints { make in
                        make.top.bottom.equalTo(cancelBtn)
                        make.left.equalTo(centerDivide.snp.right)
                        make.right.equalToSuperview()
                    }
                    otherBtn.addTarget(self, action: #selector(otherActionHandler), for: .touchUpInside)
                }
            }
        }
        
        tableView.reloadData()
//        tableView.setNeedsLayout()
//        tableView.layoutIfNeeded()
        
        var tableHeight = CGFloat(actions.count) * tableView(tableView, heightForRowAt: .init())
        var headFootHeight = needHeader ? headerView.frame.height : 0
        if let _ = cancelAction {
            headFootHeight += footerView.frame.height
        }
        let maxTableHeight = UIScreen.main.bounds.height * 0.6
        
        if tableHeight > maxTableHeight {
            tableView.isScrollEnabled = true
            tableHeight = maxTableHeight - CGFloat(actions.count)
            tableView.bounces = true
        }
        tableView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            if needHeader {
                make.top.equalTo(headerView.snp.bottom)
            } else {
                make.top.equalToSuperview()
            }
            if let _ = cancelAction {
                make.bottom.equalTo(footerView.snp.top)
            } else {
                if style == .sheet {
                    make.bottom.equalTo(-safeAreaBottom)
                } else {
                    make.bottom.equalToSuperview()
                }
            }
            make.height.equalTo(tableHeight)
        }
    }
    
    @objc private func cancelActionHandler() {
        hide()
        cancelAction?.doHander()
    }
    
    @objc private func otherActionHandler() {
        hide()
        otherAction?.doHander()
    }
    
    func addCancelAction(cancelHandler: MKAlertActionHandler? = nil) {
        add(action: .cancelAction(cancelHandler))
    }
}

extension MKAlertView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: MKAlertCell.self)
        cell.set(model: actions[indexPath.row].attributedTitle ?? .init())
        cell.topLine.isHidden = style == .sheet
        
        if style == .sheet {
            cell.bottomLine.isHidden = indexPath.row == actions.count
        } else {
            cell.bottomLine.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hide()
        actions[indexPath.row].doHander()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        style == .alert ? 45 : 55
    }
}

// MARK: - ActionMode
class MKAlertAction: Equatable {
    
    var title: String {
        return attributedTitle?.string ?? ""
    }
    var attributedTitle: NSAttributedString?
    
    fileprivate var style: MKAlertActionType = .default
    private var handler: MKAlertActionHandler? = nil
    
    init(attributedTitle: NSMutableAttributedString? = nil) {
        self.attributedTitle = attributedTitle
    }
    
    static func action(title: String, color: UIColor = .title, style: MKAlertActionType = .default, handler: MKAlertActionHandler? = nil) -> MKAlertAction {
        
        let action = MKAlertAction.init()
        action.style = style
        action.handler = handler
        
        let attTitle = NSMutableAttributedString.init(string: title, attributes: [.foregroundColor: color, .font: UIFont.medium(16)])
        
        if style == .cancel {
            attTitle.setAttributes([.foregroundColor: UIColor.cancel, .font: UIFont.medium(16)], range: .init(location: 0, length: attTitle.length))
        }
        else if style == .confirm {
            attTitle.setAttributes([.foregroundColor: UIColor.confirm, .font: UIFont.medium(16)], range: .init(location: 0, length: attTitle.length))
        }
        action.attributedTitle = attTitle
        return action
    }
    
    static func cancelAction(_ handler: MKAlertActionHandler? = nil) -> MKAlertAction {
        .action(title: "取消", style: .cancel, handler: handler)
    }
    
    func doHander() {
        handler?(self)
    }
    
    static func == (lhs: MKAlertAction, rhs: MKAlertAction) -> Bool {
        lhs.title == rhs.title
    }
}

// MARK: - ActionCell
fileprivate class MKAlertCell: KKTableCell {
    private var titleLabel: UILabel!
    fileprivate var topLine: UIView!
    fileprivate var bottomLine: UIView!
    
    override func setup() {
        topLine = UIView.init(super: contentView, backgroundColor: .alertSeparator)
        topLine.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        titleLabel = UILabel.init(superView: contentView, aligment: .center, numLines: 0)
        titleLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(20)
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        bottomLine = UIView.init(super: contentView, backgroundColor: .background)
        bottomLine.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    override func set(model: Any) {
        guard let attTitle = model as? NSAttributedString else {
            return
        }
        titleLabel.attributedText = attTitle
    }
}

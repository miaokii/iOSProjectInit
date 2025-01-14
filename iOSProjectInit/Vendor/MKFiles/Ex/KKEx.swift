//
//  KKEx.swift
//  HuaiNanWiseMedical
//
//  Created by miaokii on 2020/12/16.
//  Copyright © 2020 Ly. All rights reserved.
//

import UIKit

// MARK: - UIImage
public extension UIImage {
    
    /// 使用主题色生成的照片
    static let themeImage = UIImage.init(color: .theme)
}

// MARK: - cell
extension UICollectionReusableView {
    /// 复用id
    static var reuseID: String {
        return String.init(describing: Self.self)
    }
    @objc func set(model: Any) {  }
}

extension UITableViewCell {
    /// 复用id
    static var reuseID: String {
        return String.init(describing: Self.self)
    }
    @objc func set(model: Any) {  }
}

class KKView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup() {}
    func set(model: Any) {  }
}

class KKCollectionReusableView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup() {}
}

class KKCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backColor = .white
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 背景色
    var backColor: UIColor? {
        didSet {
            contentView.backgroundColor = backColor
            backgroundColor = backColor
            if #available(iOS 14.0, *) {
                backgroundConfiguration?.backgroundColor = backColor
            }
        }
    }
    
    func setup() {}
}

class KKTableCell: UITableViewCell {
    
    lazy var roundContentView: UIView = {
        let container = UIView.init()
        contentView.addSubview(container)
        container.backgroundColor = .white
        container.layer.cornerRadius = 5
        container.clipsToBounds = true
        container.snp.makeConstraints { (make) in
            make.left.top.equalTo(15)
            make.bottom.equalToSuperview()
            make.right.equalTo(-15)
            make.height.greaterThanOrEqualTo(20)
        }
        return container
    }()
    
    lazy var segmentLine: UIView = {
        let line = UIView.init(super: contentView, backgroundColor: .separator)
        line.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.7)
        }
        return line
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backColor = .white
        selectionStyle = .none
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 背景色
    var backColor: UIColor? {
        didSet {
            contentView.backgroundColor = backColor
            backgroundColor = backColor
            if #available(iOS 14.0, *) {
                backgroundConfiguration?.backgroundColor = backColor
            }
        }
    }
    
    func setup() {
    }
}

typealias KKTableViewCombineDelegate = UITableViewDataSource & UITableViewDelegate
extension UITableView {
    
    /// 遍历构造tableview
    /// - Parameters:
    ///   - superView: 父视图
    ///   - frame: 默认zero
    ///   - style: 默认plain
    ///   - object: 代理，默认nil
    ///   - backgroundColor: 默认table_bg
    ///   - separatorColor: 默认table_bg
    ///   - separatorStyle: 分割线风格 默认singleLine
    ///   - allowsSelection: 允许选中 默认true
    ///   - contentInset: 内缩 默认zero
    convenience init(superView: UIView?,
                     frame: CGRect = .zero,
                     style: Style = .plain,
                     delegate object: KKTableViewCombineDelegate? = nil,
                     backgroundColor: UIColor = .background,
                     separatorColor: UIColor = .separator,
                     separatorStyle: UITableViewCell.SeparatorStyle = .singleLine,
                     allowsSelection: Bool = true,
                     contentInset: UIEdgeInsets = .zero){
        self.init(frame: frame, style: style)
        self.backgroundColor = backgroundColor
        tableFooterView = UIView()
        self.separatorColor = separatorColor
        self.separatorStyle = separatorStyle
        self.contentInset = contentInset
        self.allowsSelection = allowsSelection
        
        if let target = object {
            delegate = target
            dataSource = target
        }
        
        if let sv = superView {
            sv.addSubview(self)
            if style == .grouped {
                tableHeaderView = .init(frame: .init(x: 0, y: 0, width: sv.frame.width, height: 0.001))
            }
        }
    }
    
    /// 注册nib cell
    /// - Parameters:
    ///   - name: nib名称
    ///   - cellType: cell类
    func register(nib name: String, cellType: UITableViewCell.Type) {
        register(UINib.init(nibName: name, bundle: nil), forCellReuseIdentifier: cellType.reuseID)
    }
    
    /// 注册cell
    /// - Parameter cellType: cell类型
    func register(cellType: UITableViewCell.Type) {
        register(cellType.classForCoder(), forCellReuseIdentifier: cellType.reuseID)
    }
    
    /// 寻找复用cell
    /// - Parameters:
    ///   - type: cell类型
    ///   - indexPath: 位置
    /// - Returns: type类型的cell
    func dequeueCell<T: UITableViewCell>(type: T.Type, at indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: type.reuseID, for: indexPath) as! T
    }
    
    /// 寻找复用cell，如果没找到会创建
    /// - Parameter type: cell类型
    /// - Returns: type类型的cell
    func dequeueCell<T: UITableViewCell>(type: T.Type) -> T {
        var cell = dequeueReusableCell(withIdentifier: type.reuseID) as? T
        if cell == nil {
            cell = type.init(style: .default, reuseIdentifier: type.reuseID)
        }
        return cell!
    }
    
    /// 寻找复用cell，如果没找到会创建
    /// - Parameter type: cell类型
    /// - Returns: type类型的cell
    func dequeueCell<T: UITableViewCell>(type: T.Type, style: UITableViewCell.CellStyle = .default) -> T {
        var cell = dequeueReusableCell(withIdentifier: type.reuseID) as? T
        if cell == nil {
            cell = type.init(style: style, reuseIdentifier: type.reuseID)
        }
        return cell!
    }
}

typealias KKCollectionViewCombineDelegate = UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension UICollectionView {
    
    func register(nib name: String, cellType: UICollectionViewCell.Type) {
        register(UINib.init(nibName: name, bundle: nil), forCellWithReuseIdentifier: cellType.reuseID)
    }
    
    func register(nib name: String, headerType: UICollectionReusableView.Type) {
        register(UINib.init(nibName: name, bundle: nil),
                 forSupplementaryViewOfKind: Self.elementKindSectionHeader,
                 withReuseIdentifier: headerType.reuseID)
    }
    
    func register(nib name: String, footerType: UICollectionReusableView.Type) {
        register(UINib.init(nibName: name, bundle: nil),
                 forSupplementaryViewOfKind: Self.elementKindSectionFooter,
                 withReuseIdentifier: footerType.reuseID)
    }
    
    func register(cellType: UICollectionViewCell.Type) {
        register(cellType.classForCoder(), forCellWithReuseIdentifier: cellType.reuseID)
    }
    
    func register(headerType: UICollectionReusableView.Type) {
        register(headerType.classForCoder(),
                 forSupplementaryViewOfKind: Self.elementKindSectionHeader,
                 withReuseIdentifier: headerType.reuseID)
    }
    
    func register(footerType: UICollectionReusableView.Type) {
        register(footerType.classForCoder(),
                 forSupplementaryViewOfKind: Self.elementKindSectionFooter,
                 withReuseIdentifier: footerType.reuseID)
    }
    
    func dequeueCell<T: UICollectionViewCell>(type: T.Type, at indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: type.reuseID, for: indexPath) as! T
    }
    
    func dequeueHeaderView<T: UICollectionReusableView>(type: T.Type,
                                                        at indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: Self.elementKindSectionHeader,
                                                withReuseIdentifier: type.reuseID,
                                                for: indexPath) as! T
    }
    
    func dequeueFooterView<T: UICollectionReusableView>(type: T.Type,
                                                        at indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: Self.elementKindSectionFooter,
                                                withReuseIdentifier: type.reuseID,
                                                for: indexPath) as! T
    }
}

extension UILabel {
    convenience init(superView: UIView? = nil,
                     text: String = "",
                     textColor: UIColor = .textColorBlack,
                     font: UIFont = .systemFont(ofSize: 14),
                     aligment: NSTextAlignment = .left,
                     numLines: Int = 0) {
        self.init()
        self.textColor = textColor
        self.font = font
        self.font = font
        self.textAlignment = aligment
        self.numberOfLines = numLines
        self.text = text
        
        if let sview = superView {
            sview.addSubview(self)
        }
    }
}

extension UIButton {
    convenience init(superView: UIView? = nil,
                     title: String = "",
                     titleColor: UIColor = .textColorBlack,
                     normalImage: UIImage? = nil,
                     selectedImage: UIImage? = nil,
                     backgroundImage: UIImage? = nil,
                     highlightBackgroundImage: UIImage? = nil,
                     backgroundColor: UIColor? = nil,
                     font: UIFont = .systemFont(ofSize: 17),
                     borderWidth: CGFloat = 0,
                     borderColor: UIColor? = nil,
                     cornerRadius: CGFloat = 0,
                     target_selector: (Any, Selector)? = nil) {
        self.init()
        if self.title(for: .normal) == nil {
            self.setTitle(title, for: .normal)
        }
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        self.setImage(normalImage, for: .normal)
        self.setImage(selectedImage, for: .selected)
        self.setBackgroundImage(backgroundImage, for: .normal)
        self.setBackgroundImage(highlightBackgroundImage, for: .highlighted)
        self.backgroundColor = backgroundColor
        
        if let (target, selector) = target_selector {
            self.addTarget(target, action: selector, for: .touchUpInside)
        }
        
        if borderWidth > 0 {
            self.layer.borderWidth = borderWidth
        }
        
        if let bcolor = borderColor {
            self.layer.borderColor = bcolor.cgColor
        }
        
        if cornerRadius > 0 {
            self.layer.cornerRadius = cornerRadius
        }
        self.clipsToBounds = cornerRadius > 0
        
        if let sView = superView as? UIStackView {
            sView.addArrangedSubview(self)
        }
        else if let sview = superView {
            sview.addSubview(self)
        }
    }
    
    static func themeBtn(superView: UIView?,
                         title: String,
                         font: UIFont = .regular(15),
                         cornerRadius: CGFloat = 3,
                         target_selector: (Any, Selector)? = nil) -> UIButton {
        let btn = UIButton.init(superView: superView,
                                title: title,
                                titleColor: .white,
                                backgroundImage: UIImage.themeImage,
                                font: font,
                                cornerRadius: cornerRadius,
                                target_selector: target_selector)
        return btn
    }
    
    static func themeBorderBtn(superView: UIView? = nil,
                               title: String = "",
                               font: UIFont = .regular(15),
                               borderColor: UIColor = .theme,
                               cornerRadius: CGFloat = 3,
                               target_selector: (Any, Selector)? = nil) -> UIButton {
        let btn = UIButton.init(superView: superView,
                                title: title,
                                titleColor: borderColor,
                                font: font,
                                borderWidth: 1,
                                borderColor: borderColor,
                                cornerRadius: cornerRadius,
                                target_selector: target_selector)
        return btn
    }
}

extension UIImageView {
    convenience init(superView: UIView?,
                     image: UIImage? = nil,
                     backgroundColor: UIColor?  = nil,
                     contentMode: ContentMode = .scaleAspectFill,
                     cornerRadius: CGFloat = 0) {
        self.init(image: image)
        self.contentMode = contentMode
        if cornerRadius > 0 {
            self.layer.cornerRadius = cornerRadius
        }
        self.clipsToBounds = true
        if let color = backgroundColor {
            self.backgroundColor = color
        }
        
        if let sview = superView {
            sview.addSubview(self)
        }
    }
}
extension UIView {
    
    convenience init(super view: UIView? = nil,
                     backgroundColor: UIColor? = .white,
                     cornerRadius: CGFloat = 0) {
        self.init()
        self.backgroundColor = backgroundColor
        if cornerRadius > 0 {
            self.layer.cornerRadius = cornerRadius
        }
        
        if let sview = view {
            sview.addSubview(self)
        }
    }
}

extension UITextField {
    
    var isEmpty: Bool {
        return (self.text ?? "").isEmpty
    }
    
    convenience init(superView: UIView?,
                     text: String = "",
                     textColor: UIColor = .textColorBlack,
                     placeHolder: String = "",
                     placeHolderColor: UIColor = .placeHolderColor,
                     font: UIFont = .systemFont(ofSize: 14),
                     aligment: NSTextAlignment = .left,
                     tintColor: UIColor = .blue,
                     backgroundColor: UIColor? = .white,
                     delegate: UITextFieldDelegate? = nil,
                     keyboardType: UIKeyboardType = .default,
                     borderStyle: BorderStyle = .none,
                     borderWidth: CGFloat = 0,
                     borderColor: UIColor? = nil,
                     cornerRadius: CGFloat = 0,
                     clipsToBounds: Bool = false) {
        self.init()
        self.text = text
        self.font = .boldSystemFont(ofSize: 32)
        self.keyboardType = keyboardType
        self.tintColor = tintColor
        self.borderStyle = .none
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.placeholder = placeHolder
        self.delegate = delegate
        self.borderStyle = borderStyle
        self.font = font
        self.textAlignment = aligment
        
        self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [.foregroundColor : placeHolderColor])
        
        if borderWidth > 0 {
            self.layer.borderWidth = borderWidth
        }
        
        if let bcolor = borderColor {
            self.layer.borderColor = bcolor.cgColor
        }
        
        if cornerRadius > 0 {
            self.layer.cornerRadius = cornerRadius
        }
        self.clipsToBounds = clipsToBounds
        self.autocorrectionType = .no
        
        if let sview = superView {
            sview.addSubview(self)
        }
    }
}

extension UIStackView {
    convenience init(superView: UIView? = nil, axis: NSLayoutConstraint.Axis = .horizontal, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 10) {
        self.init()
        self.backgroundColor = .clear
        self.spacing = spacing
        self.axis = axis;
        self.alignment = alignment;
        self.distribution = distribution;
        if let superView = superView {
            superView.addSubview(self)
        }
    }
}

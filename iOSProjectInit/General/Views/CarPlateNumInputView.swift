//
//  CarPlateNumInputView.swift
//  XinCar
//
//  Created by yoctech on 2025/1/8.
//

import UIKit

fileprivate let padding: CGFloat = 15
class CarPlateNumInputView: MKPopBottomView {

    var carPlateNumBlock: ((String)->Void)?
    
    private var numViews = [PlateNumView]()
    private var proviceView: PlateNumProviceInputView!
    private var alphabetView: PlateNumAlphabatInputView!
    
    private var currentIdx = 0
    
    override func setDefault() {
        super.setDefault()
        title = "请输入车牌号"
        confirmTitle = nil
    }
    
    override func appendSubviews() {
        super.appendSubviews()
        let spacing: CGFloat = 5
        let dotSize: CGFloat = 4
        
        let stackView = UIStackView(superView: contentView, axis: .horizontal, alignment: .center, distribution: .equalSpacing, spacing: spacing)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom)
            make.left.equalTo(padding)
            make.right.equalTo(-padding)
            make.height.equalTo(45)
        }
        
        numViews = [PlateNumView(), PlateNumView(), PlateNumView(), PlateNumView(),
                    PlateNumView(), PlateNumView(), PlateNumView(), PlateNumView()]
        numViews.last?.newEngry = true
        for (idx, view) in numViews.enumerated() {
            view.tag = idx
            view.backgroundColor = .background
            view.cornerRadius = 4
        }
        
        let dotView = UIView.init(super: nil, backgroundColor: .textColorBlack, cornerRadius: 2)
        var allViews: [UIView] = numViews
        allViews.insert(dotView, at: 2)
        allViews.forEach { view in
            stackView.addArrangedSubview(view)
            if view == dotView {
                dotView.snp.makeConstraints { make in
                    make.width.equalTo(dotSize)
                    make.height.equalTo(dotSize)
                }
            } else if let numView = view as? PlateNumView {
                numView.inputing = false
                numView.addTarget(self, action: #selector(plateInput(sender: )), for: .touchUpInside)
                numView.snp.makeConstraints { make in
                    make.height.equalToSuperview()
                    make.width.equalTo((screenWidth-2*padding-dotSize-8*spacing)/8)
                }
            }
        }
        
        proviceView = .init(height: 200, rows: 4, column: 9, spacing: 5)
        contentView.addSubview(proviceView)
        proviceView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(proviceView.height)
            make.bottom.equalTo(-safeAreaBottom-10)
        }
        
        alphabetView = .init(height: 200, rows: 4, column: 10, spacing: 3)
        contentView.addSubview(alphabetView)
        alphabetView.snp.makeConstraints { make in
            make.edges.equalTo(proviceView)
        }
        contentView.sendSubviewToBack(alphabetView)
        
        proviceView.proviceInputBlock = { [unowned self] text in
            self.numViews[self.currentIdx].value = text
            self.plateNext(idx: self.currentIdx+1)
        }
        alphabetView.alphabetInputBlock = { [unowned self] text in
            self.numViews[self.currentIdx].value = text
            /// 最后一个了
            if self.currentIdx+1 == self.numViews.count {
                self.numViews.last?.inputing = false
            } else {
                self.plateNext(idx: self.currentIdx+1)
            }
        }
        alphabetView.deleteBlcok = { [unowned self] in
            // 是否为最后一个
            if self.currentIdx+1 == self.numViews.count, self.numViews[self.currentIdx].value.notEmpty {
                self.plateNext(idx: self.currentIdx)
            } else {
                self.plateNext(idx: self.currentIdx-1)
            }
        }
        alphabetView.doneBlock = { [unowned self] in
            self.confirmHandle()
        }
        
        plateNext(idx: 0)
    }
    
    override func confirmHandle() {
        super.confirmHandle()
        let plateNum = numViews.map{$0.value}.joined()
        carPlateNumBlock?(plateNum)
    }
    
    private func plateNext(idx: Int) {
        currentIdx = idx
        plateInput(sender: numViews[idx])
    }
    
    @objc private func plateInput(sender: PlateNumView) {
        // 未在编辑状态
        guard !sender.inputing else { return }
        // 上一个没有内容时，不允许编辑
        if sender.tag > 0, numViews[sender.tag-1].value.isEmpty {
            return
        }
        for (idx, numView) in numViews.enumerated() {
            numView.inputing = false
            if idx >= sender.tag {
                numView.value = ""
            }
        }
        currentIdx = sender.tag
        provice(hide: sender.tag > 0)
        sender.inputing = true
        alphabetView.numberEnable = currentIdx > 1
        alphabetView.doneEnable = currentIdx > 6
    }
    
    private func provice(hide: Bool) {
        guard proviceView.isHidden != hide else {
            return
        }
        if !hide {
            proviceView.isHidden = false
        }
        UIView.animate(withDuration: 0.2) {
            self.proviceView.alpha = hide ? 0 : 1
        } completion: { _ in
            self.proviceView.isHidden = hide
        }
    }
    
    private func plateNumButton() -> UIButton {
        let button = UIButton.init(superView: nil, title: "", titleColor: .textColorBlack, font: .dinBold(20))
        return button
    }
}

// 牌号view
fileprivate class PlateNumView: UIControl {
    
    var value: String = "" {
        didSet {
            label.text = value
        }
    }
    
    var newEngry = false
    var inputing = false {
        didSet {
            borderWidth = inputing ? 1 : 0
            borderColor = inputing ? .theme : nil
            backgroundColor = newEngry ? (inputing ? .background : .init(0xecf7f3)) : .background
            cursor.isHidden = !inputing
            if newEngry { newEngryLabel.isHidden = inputing || value.notEmpty }
        }
    }
    
    private var label: UILabel!
    private var cursor: UIView!
    lazy private var newEngryLabel: UILabel = {
        let label = UILabel.init(superView: self, text: "新\n能\n源", textColor: .init(0x20BE8B), font: .regular(8), aligment: .center)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = .init(superView: self, text: "", textColor: .textColorBlack, font: .dinBold(25), aligment: .center)
        label.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        cursor = .init(super: self, backgroundColor: .theme)
        cursor.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalToSuperview().multipliedBy(0.55)
        }
        
        inputing = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

/// 省简称
fileprivate class PlateNumProviceInputView: UIView {
    
    var proviceInputBlock: ((String)->Void)?
    var rows = 4
    var column = 9
    var spacing: CGFloat = 7
    
    convenience init(width:CGFloat = screenWidth, height: CGFloat, rows: Int, column: Int, spacing: CGFloat) {
        
        self.init(frame: .init(x: 0, y: 0, width: width, height: height))
        self.rows = rows
        self.column = column
        self.spacing = spacing
        backgroundColor = .white
        setup()
    }
    
    private func setup() {
        let provices = [
            "京","津","冀","晋","蒙","辽","吉","黑","沪","苏","浙",
            "皖","闽","赣","鲁","豫","鄂","湘","粤","桂","琼","渝",
            "川","贵","云","藏","陕","甘","青","宁","新","港","澳","学","警","领"
        ]
        
        let btnWidth = (width-spacing*CGFloat(column+1))/CGFloat(column)
        let btnHeight = (height-spacing*CGFloat(rows+1))/CGFloat(rows)
        
        for (idx, text) in provices.enumerated() {
            let button = UIButton.init(superView: self, title: text, titleColor: .textColorBlack, font: UIFont.regular(17), cornerRadius: 3)
            button.setClosure { [weak self] sender in
                self?.proviceInputBlock?(text)
            }
            button.setNormal(backgroundImage: .init(color: .background))
            let left = CGFloat(idx%column)*CGFloat(spacing+btnWidth) + spacing
            let top = CGFloat(idx/column)*(spacing+btnHeight) + spacing
            button.frame = .init(
                x: left,
                y: top,
                width: btnWidth, height: btnHeight)
        }
    }
}

// 字母表
fileprivate class PlateNumAlphabatInputView: UIView {
    
    var alphabetInputBlock: ((String)->Void)?
    var deleteBlcok: NoParamBlock?
    var doneBlock: NoParamBlock?
    
    var numberEnable = true {
        didSet {
            guard oldValue != numberEnable else {
                return
            }
            subviews[0..<10].forEach{ ($0 as! UIButton).isEnabled = numberEnable }
        }
    }
    var doneEnable = false {
        didSet {
            doneBtn.isEnabled = doneEnable
        }
    }
    
    private var rows = 4
    private var column = 9
    private var spacing: CGFloat = 7
    private var doneBtn: LGButton!
    
    convenience init(width:CGFloat = screenWidth, height: CGFloat, rows: Int, column: Int, spacing: CGFloat) {
        
        self.init(frame: .init(x: 0, y: 0, width: width, height: height))
        self.rows = rows
        self.column = column
        self.spacing = spacing
        backgroundColor = .white
        setup()
    }
    
    private func setup() {
        let provices = [
            "1","2","3","4","5","6","7","8","9","0",
            "Q","W","E","R","T","Y","U","I","O","P",
            "A","S","D","F","G","H","J","K","L","Z",
            "X","C","V","B","N","M"
        ]
        
        let btnWidth = (width-spacing*CGFloat(column+1))/CGFloat(column)
        let btnHeight = (height-spacing*CGFloat(rows+1))/CGFloat(rows)
        
        var lastBtn: UIView!
        for (idx, text) in provices.enumerated() {
            let button = UIButton.init(superView: self, title: text, titleColor: .textColorBlack, font: UIFont.regular(17), cornerRadius: 3)
            button.setNormal(backgroundImage: .init(color: .background))
            button.setClosure { [weak self] sender in
                self?.alphabetInputBlock?(text)
            }
                        
            let left = CGFloat(idx%column)*CGFloat(spacing+btnWidth) + spacing
            let top = CGFloat(idx/column)*(spacing+btnHeight) + spacing
            button.frame = .init(
                x: left,
                y: top,
                width: btnWidth, height: btnHeight)
            lastBtn = button
            
            button.isEnabled = text != "I" && text != "O"
            button.setTitleColor(.textColorGray, for: .disabled)
        }
        
        let backBtn = LGButton.button(superView: self, normalImage: .init(named: "icon_alphabat_del"), imageSize: .init(width: 25, height: 25))
        backBtn.frame = .init(x: lastBtn.right+spacing, y: lastBtn.top, width: 2*btnWidth+spacing, height: btnHeight)
        backBtn.btnCornerRadius = 3
        backBtn.bgColor = .background
        backBtn.add(self, #selector(deleteAction))
        lastBtn = backBtn
        
        doneBtn = LGButton.button(superView: self, title: "完成", titleColor: .white, font: UIFont.regular(15))
        doneBtn.btnCornerRadius = 3
        doneBtn.bgColor = .theme
        doneBtn.frame = .init(x: lastBtn.right+spacing, y: lastBtn.top, width: 2*btnWidth+spacing, height: btnHeight)
        doneBtn.add(self, #selector(doneAction))
    }
    
    @objc private func doneAction() {
        doneBlock?()
    }
    
    @objc private func deleteAction() {
        deleteBlcok?()
    }
}

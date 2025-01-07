//
//  MKMutipleColumnPickerView.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/6.
//

import UIKit

class MKMutipleColumnPickerView: MKPopBottomView {
    /// 选项值
    var columnOptions: [[String]] {
        set {
            multipleColumnOptions = newValue
        }
        get {
            multipleColumnOptions
        }
    }
    /// 选中值
    var values: [String] {
        set {
            multipleValues = newValue
        }
        get {
            multipleValues
        }
    }
    
    /// 设置需要返回列的索引
    ///
    /// 如果 options 里某一列只有1个元素，在某些情况可以认为是单位，就不需要返回该值，
    /// 比如options = [["1","2","3"],["月"],["12", "13", "24"],["日"]]，第二第四列只有一个元素，在某些需求里面可以认为是单位，
    /// 这个例子的场景是 选择月日，例如 1月24日，月和日数可以变，但是单位不变，所以不需要返回该单位
    ///
    /// 在默认情况下，options里面如果有某列只有1个元素，就不会返回该列的值，如果要返回该值
    /// 则手动指定 options里面需要返回的index，
    /// 例如上面这个列子，要返回月日的话，usefulOptionsIndex = [0,1,2,3]

    var usefulColumnIndex:[Int] {
        set {
            multipleUsefulColumnIndex = newValue
        }
        get {
            multipleUsefulColumnIndex
        }
    }
    /// 是否开启usefulOptionsIndex过滤，默认不开启，每一列都会返回
    var filterValues: Bool {
        set {
            multipleFilterValues = newValue
        }
        get {
            multipleFilterValues
        }
    }
    /// 自动选择，当滑动后，自动回调选择结果，每一次滑动都会回调一次，实时改变选中
    var autoSelect = false
    
    var rowFont: UIFont = .regular(17)
    var rowColor: UIColor = .black
    var rowSelectedColor: UIColor = .black
    var rowSelectedFont: UIFont = .medium(17)
    var callBackClosure:(([String], [Int])->Void)? = nil
    
    fileprivate var pickerView = UIPickerView()
    fileprivate var multipleColumnOptions = [[String]]()
    fileprivate var multipleValues = [String]()
    fileprivate var multipleUsefulColumnIndex = [Int]()
    fileprivate var multipleFilterValues = false
    
    override func setDefault() {
        super.setDefault()
        
        columnOptions = []
        multipleValues = []
        multipleUsefulColumnIndex = []
        multipleFilterValues = false
        
        title = "请选择"
        confirmTitle = "确认"
        cancelTitle = "取消"
        autoSelect = false
        rowFont = .regular(17)
        rowSelectedFont = .medium(17)
        rowColor = .black
        rowSelectedColor = .black
    }
    
    override func appendSubviews() {
        super.appendSubviews()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        contentView.addSubview(pickerView)
        pickerView.tintColor = rowSelectedColor
        
        pickerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(navBarView.snp.bottom)
            make.bottom.equalTo(-safeAreaBottom)
            make.height.equalTo(200)
        }
    }
    
    /// 计算返回
    func callBackSelected() {
        var vals = [String]()
        var indexs = [Int]()
        
        if multipleFilterValues {
            multipleUsefulColumnIndex.forEach({ idx in
                if idx < multipleColumnOptions.count {
                    let row = pickerView.selectedRow(inComponent: Int(idx))
                    vals.append(multipleColumnOptions[idx][row])
                    indexs.append(row)
                }
            })
        } else {
            for i in 0..<multipleColumnOptions.count {
                let row = pickerView.selectedRow(inComponent: i)
                vals.append(multipleColumnOptions[i][row])
                indexs.append(row)
            }
        }
        
        callBackClosure?(vals, indexs)
    }
    
    override func confirmHandle() {
        if !self.autoSelect {
            callBackSelected()
        }
        hide()
    }
    
    override func beforePop() {
        super.beforePop()
        
        if multipleColumnOptions.count > 0 {
            if multipleFilterValues {
                if multipleUsefulColumnIndex.isEmpty {
                    var valueIndex = [Int]()
                    for idx in 0..<multipleColumnOptions.count {
                        let rows = multipleColumnOptions[idx]
                        if rows.count > 1 {
                            valueIndex.append(idx)
                        }
                    }
                    multipleUsefulColumnIndex = valueIndex
                }
            } else {
                multipleUsefulColumnIndex = indexArr()
            }
            
            if multipleValues.count == 0 {
                var vals = [String]()
                multipleUsefulColumnIndex.forEach { idx in
                    vals.append(multipleColumnOptions[idx].first ?? "")
                }
                self.multipleValues = vals
            }
        }
    }
    
    override func inPoping() {
        super.inPoping()
        
        var indexs = indexArr()
        if multipleFilterValues, !multipleUsefulColumnIndex.isEmpty {
            indexs = multipleUsefulColumnIndex
        }
        
        if multipleValues.count > 0 {
            for i in 0..<indexs.count {
                let component = indexs[i]
                if multipleColumnOptions.count > component, multipleValues.count > i {
                    let rowValue = multipleValues[i]
                    if !rowValue.isEmpty {
                        if let row = multipleColumnOptions[component].firstIndex(of: rowValue) {
                            pickerView.selectRow(row, inComponent: component, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    private func indexArr() -> [Int] {
        var valueIndex = [Int]()
        for i in 0..<multipleColumnOptions.count {
            if multipleFilterValues {
                if multipleUsefulColumnIndex.contains(where: { $0 == i }) {
                    valueIndex.append(i)
                }
            } else {
                valueIndex.append(i)
            }
        }
        return valueIndex
    }
}

extension MKMutipleColumnPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return multipleColumnOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return multipleColumnOptions[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if multipleColumnOptions.count == 1 {
            return pickerView.frame.width
        }
        
        let firstRowVal = multipleColumnOptions[component].first ?? ""
        let rowWidth = firstRowVal.size(font: rowFont, width: pickerView.frame.size.width).width
        return rowWidth + (multipleColumnOptions[component].count > 1 ? 40 : 20)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return multipleColumnOptions[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var selectedLabel = view as? UILabel
        if selectedLabel == nil {
            selectedLabel = UILabel.init()
            selectedLabel!.font = rowFont
            selectedLabel!.textColor = rowColor
            selectedLabel!.adjustsFontSizeToFitWidth = true
            selectedLabel!.numberOfLines = 0
            selectedLabel!.textAlignment = .center
        }
        DispatchQueue.main.async {
            if let label = pickerView.view(forRow: row, forComponent: component) as? UILabel {
                label.textColor = self.rowSelectedColor
                label.font = self.rowSelectedFont
            }
        }
        selectedLabel!.text = multipleColumnOptions[component][row]
        return selectedLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if autoSelect {
            callBackSelected()
        }
    }
}

class MKSingleColumnPickerView: MKMutipleColumnPickerView {
    
    @available(*, unavailable)
    override var columnOptions: [[String]] {
        set {}
        get { return [] }
    }
    
    @available(*, unavailable)
    override var values: [String] {
        set {}
        get { return [] }
    }
    @available(*, unavailable)
    override var usefulColumnIndex: [Int] {
        set {}
        get { return [] }
    }
    @available(*, unavailable)
    override var filterValues: Bool {
        set {}
        get { return false }
    }
    @available(*, unavailable)
    override var callBackClosure: (([String], [Int]) -> Void)? {
        get { return nil }
        set {}
    }
    
    var options: [String] {
        set {
            multipleColumnOptions = [newValue]
        }
        get {
            return multipleColumnOptions.first ?? []
        }
    }
    var value: String {
        set {
            if newValue.isEmpty {
                return
            }
            multipleValues = [newValue]
        }
        get {
            multipleValues.first ?? ""
        }
    }
    var singleCallBlack:((String, Int)->Void)? = nil
    
    override func setDefault() {
        super.setDefault()
        
        multipleFilterValues = false
        multipleUsefulColumnIndex = [0]
    }
    
    override func callBackSelected() {
        let row = pickerView.selectedRow(inComponent: 0)
        if let backClosure = singleCallBlack {
            backClosure(options[row], row)
        }
    }
}

fileprivate extension String {
    func size(font: UIFont, width: CGFloat) -> CGSize {
        let att = [NSMutableAttributedString.Key.font: font]
        return self.boundingRect(with: .init(width: width, height: .infinity), options: .usesLineFragmentOrigin, attributes: att, context: nil).size
    }
}

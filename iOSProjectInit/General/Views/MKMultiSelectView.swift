//
//  MKMultiSelectView.swift
//  RXCSaaS
//
//  Created by yoctech on 2024/1/4.
//

import UIKit

class MKMultiSelectView: MKPopBottomView, UITableViewDelegate, UITableViewDataSource {

    var options: [String] = []
    var values: [String] = []
    var maxSelectedCount = -1
    
    var callBackClosure: (([String], [Int]) -> Void)?

    var rowFont: UIFont = .regular(15)
    var rowSelectedFont: UIFont = .medium(15)
    var rowColor: UIColor = .textColorBlack
    var rowSelectedColor: UIColor = .theme
    var unCheckImg = UIImage.checkCircle
    var checkedImg = UIImage.checkCircleFill

    private var tableView: UITableView!

    override func setDefault() {
        super.setDefault()

        popStyle = .bottom
        confirmTitle = "请选择"
        confirmTitle = "确认"
        cancelTitle = "取消"

        corner = [.topLeft, .topRight]
        cornerRadii = 10
    }

    override func appendSubviews() {
        super.appendSubviews()

        tableView = UITableView(superView: contentView, delegate: self, backgroundColor: .white, separatorColor: .background)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(navBarView.snp.bottom)
            make.bottom.equalTo(-safeAreaBottom)
            make.height.equalTo(300)
        }
    }

    override func confirmHandle() {
        var indexs = [Int]()
        for (idx, obj) in self.options.enumerated() {
            if self.values.contains(obj) {
                indexs.append(idx)
            }
        }
        callBackClosure?(values, indexs)
        hide()
    }

    override func dynamicSubviews() {
        super.dynamicSubviews()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: UITableViewCell.self, style: .default)
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.textColor = rowColor
        cell.textLabel?.font = rowFont
        cell.accessoryView = UIImageView(image: unCheckImg)
        cell.selectionStyle = .none
        
        if values.contains(options[indexPath.row]) {
            cell.textLabel?.textColor = rowSelectedColor
            cell.accessoryView = UIImageView(image: self.checkedImg)
            cell.textLabel?.font = rowSelectedFont
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let value = options[indexPath.row]
        if let index = values.firstIndex(of: value) {
            values.remove(at: index)
        } else {
            if values.count < maxSelectedCount || maxSelectedCount == -1 {
                values.append(value)
            } else if maxSelectedCount > 0 {
                print("最大选择数：\(maxSelectedCount)")
            }
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

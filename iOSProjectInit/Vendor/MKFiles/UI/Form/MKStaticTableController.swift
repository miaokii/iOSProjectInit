//
//  MKStaticTableController.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/2.
//

import UIKit

class MKStaticTableController: MKTableViewController<StaticTableModel> {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = tableView.dequeueCell(type: model.cellType)
        cell.set(form: model)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        if model.isEditEnable, let tapBlock = model.tapBlock {
            tapBlock()
        }
    }
}

/// 分组的静态table
class MKStaticGroupTableController: MKTableViewController<[StaticTableModel]> {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.section][indexPath.row]
        let cell = tableView.dequeueCell(type: model.cellType)
        cell.set(form: model)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init()
        header.backgroundColor = .background
        return header
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // groupRound(cell: cell, at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.section][indexPath.row]
        if model.isEditEnable {
            model.tapBlock?()
        }
    }
}

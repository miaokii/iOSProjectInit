//
//  LoggerController.swift
//  SwiftLib
//
//  Created by yoctech on 2023/4/24.
//

import UIKit
import CocoaLumberjack

class LoggerController: MKTableViewController<DDLogMessage> {
    
    static let shared = LoggerController.init()
    
    var showd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "本次启动日志"
        
        let dismiss = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(exitLog))
        let list = UIBarButtonItem.init(title: "历史", style: .plain, target: self, action: #selector(allLog))
        
        let clearn = UIBarButtonItem.init(title: "清除", style: .plain, target: self, action: #selector(clearnLog))
        
        let export = UIBarButtonItem.init(title: "导出", style: .plain, target: self, action: #selector(exportLog))
        
        navigationItem.leftBarButtonItems = [dismiss, list]
        navigationItem.rightBarButtonItems = [clearn, export]
        
        tableView.register(cellType: UITableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showd = true
        refreshLog()
    }
    
    @objc private func exitLog() {
        showd = false
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func allLog() {
        push(vc: LoggerLocalController.init())
    }
    
    @objc private func clearnLog() {
        Logger.clearLogs()
        refreshLog()
    }
    
    @objc private func exportLog() {
        var logStrings = ""
        for log in Logger.shared.messages {
            let time = log.timestamp.string(format: "yyyy-MM-dd HH:mm:ss")
            logStrings.append(time)
            logStrings.append(" ")
            logStrings.append(log.message)
            logStrings.append("\n")
        }
        
        let vc = UIActivityViewController(activityItems: [logStrings], applicationActivities: nil)
        present(vc, animated: true)
    }
    
    func refreshLog() {
        dataSource = Logger.shared.messages
        tableView.reloadData()
    }
}

extension LoggerController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: UITableViewCell.self, at: indexPath)
        cell.contentView.backgroundColor = UIColor.white
        cell.textLabel?.font = .regular(14)
        
        let logger = dataSource[indexPath.row]
        let message = logger.timestamp.string(format: "HH:mm:ss") + " " + logger.message
        cell.textLabel?.text = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contentVc = LoggerContentController.init()
        contentVc.logModel = dataSource[indexPath.row]
        push(vc: contentVc)
    }
}

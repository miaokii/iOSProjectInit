//
//  LocalLoggerController.swift
//  SwiftLib
//
//  Created by miaokii on 2023/4/24.
//

import UIKit
import CocoaLumberjack

class LoggerLocalController: MKTableViewController<String> {
    
    fileprivate var logDir: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "所有日志"
        
        guard let fileLogger = DDLog.allLoggers.first(where: { $0 is DDFileLogger }) as? DDFileLogger,
            let logs = FileManager.default.subpaths(atPath: fileLogger.logFileManager.logsDirectory)
            else {
            return
        }
        
        logDir = fileLogger.logFileManager.logsDirectory
        
        dataSource = logs.filter({ path in
            guard let atts = try? FileManager.default.attributesOfItem(atPath: "\(logDir)/\(path)"), let size = atts[.size] as? Double else {
                return false
            }
            return size > 0
        }).sorted(by: { path1, path2 in
            guard let atts1 = try? FileManager.default.attributesOfItem(atPath: "\(logDir)/\(path1)"),
                    let date1 = atts1[.creationDate] as? Date,
                    let atts2 = try? FileManager.default.attributesOfItem(atPath: "\(logDir)/\(path2)"),
                    let date2 = atts2[.creationDate] as? Date else {
                return false
            }
            return date1.compare(date2) == .orderedDescending
        })
        tableView.register(cellType: UITableViewCell.self)
    }
}

extension LoggerLocalController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: UITableViewCell.self, at: indexPath)
        cell.contentView.backgroundColor = UIColor.white
        cell.textLabel?.font = .regular(14)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contentVc = LoggerContentController.init()
        contentVc.logPath = logDir + "/\(dataSource[indexPath.row])"
        push(vc: contentVc)
    }
}

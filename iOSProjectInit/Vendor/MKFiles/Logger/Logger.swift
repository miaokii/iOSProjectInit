//
//  Logger.swift
//  SwiftLib
//
//  Created by yoctech on 2023/4/24.
//

import UIKit
import CocoaLumberjack

extension Date {
    func string(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        formatter.locale = .init(identifier: "zh_CN")
        return formatter.string(from: self as Date)
    }
    
    static func date(string: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        formatter.locale = .init(identifier: "zh_CN")
        return formatter.date(from: string)
    }
}

func LogInfo(_ msg: @autoclosure () -> Any,
             file: StaticString = #file,
             function: StaticString = #function,
             line: UInt = #line,
             tag: Any? = nil) {
    DDLogInfo(msg(), file: file, function: function, line: line, tag: tag)
}

func LogDebug(_ msg: @autoclosure () -> Any,
             file: StaticString = #file,
             function: StaticString = #function,
             line: UInt = #line,
             tag: Any? = nil) {
    DDLogDebug(msg(), file: file, function: function, line: line, tag: tag)
}

func LogError(_ msg: @autoclosure () -> Any,
             file: StaticString = #file,
             function: StaticString = #function,
             line: UInt = #line,
             tag: Any? = nil) {
    DDLogError(msg(), file: file, function: function, line: line, tag: tag)
}

func LogWarn(_ msg: @autoclosure () -> Any,
             file: StaticString = #file,
             function: StaticString = #function,
             line: UInt = #line,
             tag: Any? = nil) {
    DDLogWarn(msg(), file: file, function: function, line: line, tag: tag)
}

func LogVerbose(_ msg: @autoclosure () -> Any,
             file: StaticString = #file,
             function: StaticString = #function,
             line: UInt = #line,
             tag: Any? = nil) {
    DDLogVerbose(msg(), file: file, function: function, line: line, tag: tag)
}

/// 重写文件名
fileprivate class DDLogFileManager: DDLogFileManagerDefault {
    override func isLogFile(withName fileName: String) -> Bool {
        fileName.hasSuffix(".log")
    }
    
    override var newLogFileName: String {
        get {
            let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
            let time = Date().string(format: "YYYY.MM.dd HH.mm.ss")
            return "\(name)\(time)"
        }
        set {}
    }
}

class Logger: DDAbstractLogger {
    static let shared = Logger()
    private(set) static var enableLogger = false
    private(set) var messages = [DDLogMessage]()
    private var consoleQueue: DispatchQueue!
    
    override init() {
        super.init()
        self.consoleQueue = DispatchQueue.init(label: "console_queue")
    }
    
    static func addLoggers() {
        #if DEBUG
        dynamicLogLevel = .all
        enableLogger = true
        startLogger()
        #else
        dynamicLogLevel = .off
        #endif
    }
    
    static func clearLogs() {
        shared.messages.removeAll()
    }
    
    fileprivate static func startLogger() {
        // log位置
        guard var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        path.append("/Logs")

        let fileLoggerMag = DDLogFileManager.init(logsDirectory: path)
        // 最多保存7个log
        fileLoggerMag.maximumNumberOfLogFiles = 7
        // 单个文件最大20m
        fileLoggerMag.logFilesDiskQuota = 1024*1024*20

        let fileLogger = DDFileLogger.init(logFileManager: fileLoggerMag)
        // 重用log，不要每次创建新的log文件
        fileLogger.doNotReuseLogFiles = false
        // 24小时后笑，超过时间创建新的log
        fileLogger.rollingFrequency = 60*60*24
        // 禁用文件大小滚动
        fileLogger.maximumFileSize = 0
        // 日志格式
        fileLogger.logFormatter = shared

        DDLog.add(shared)
        DDLog.add(fileLogger)
        DDLog.add(DDOSLogger.sharedInstance)
    }
}

extension Logger: DDLogFormatter {
    func format(message logMessage: DDLogMessage) -> String? {
        messages.insert(logMessage, at: 0)
        
        let time = logMessage.timestamp.string(format: "YYYY-MM-dd HH:mm:ss")
        let formatLog = "\(time) \(logMessage.fileName).\(logMessage.function ?? "")   line\(logMessage.line)⬇️:\n\(logMessage.message)\n\n";
        return formatLog
    }
}


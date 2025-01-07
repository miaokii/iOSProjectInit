//
//  NSRegularExpression+Dc.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/25.
//

import Foundation

extension NSRegularExpression {
    static func ~=(lhs: NSRegularExpression, rhs: String) -> Bool {
        return lhs.matches(in: rhs, options: [], range: NSRange(location: 0, length: rhs.utf16.count)).count > 0
    }
}

/// 定义前置操作符
prefix operator ~/
prefix func ~/(pattern: String) -> NSRegularExpression {
    var regularExpression: NSRegularExpression?
    do {
        try regularExpression = NSRegularExpression(pattern: pattern, options: [])
    } catch let error {
        fatalError(error.localizedDescription)
    }
    return regularExpression!
}


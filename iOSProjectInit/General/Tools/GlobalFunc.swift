//
//  GlobalFunc.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/12/6.
//

import UIKit

func ossFullUrl(_ path: String) -> URL? {
    if path.hasPrefix("http") {
        return .init(string: path)
    }
    guard var url = URL.init(string: ChooseServer.currentServer.staticUrl) else {
        return nil
    }
    url.appendPathComponent(path, conformingTo: .url)
    return url
}

func string(value: Any?) -> String {
    guard let value = value else {
        return ""
    }
    if value is NSNull {
        return ""
    }
    if let string = value as? String {
        return string
    }
    else if let num = value as? NSNumber {
        return num.stringValue
    }
    else if let bool = value as? Bool {
        return bool ? "1" : "0"
    }
    else {
        return "\(value)"
    }
}

//
//  URL+Ex.swift
//  RXCSaaS
//
//  Created by yoctech on 2025/1/11.
//

import Foundation

extension URL {
    mutating func append(param: [String: Any]) {
//        if #available(iOS 16.0, *) {
//            let items = param.map{URLQueryItem(name: $0.key, value: $0.value)}
//            append(queryItems: items)
//        } else {
            let path = param.map{ "\($0.key)=\($0.value)" }.joined(separator: "&")
        let urlString = "\(absoluteString)?\(path)"
//        self = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") ?? self
        self = URL(string: urlString) ?? self

//        }
    }
}

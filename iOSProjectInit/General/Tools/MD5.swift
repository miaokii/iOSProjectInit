//
//  MD5.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/10/26.
//

import Foundation
import CryptoKit

struct MD5 {
    static func md5(from str: String) -> String {
        guard str.notEmpty else {
            return ""
        }
        
        let data = str.data(using: .utf8)!
        return md5(from: data)
    }
    
    static func md5(from data: Data) -> String {
        let digestData = Insecure.MD5.hash(data: data)
        let digestHex = String(digestData.map{ String.init(format: "%02hhx", $0) }.joined().prefix(32))
        return digestHex
    }
}

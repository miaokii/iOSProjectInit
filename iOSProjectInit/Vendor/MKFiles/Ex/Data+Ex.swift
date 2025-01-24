//
//  Data+Ex.swift
//  MuYunControl
//
//  Created by yoctech on 2023/9/5.
//

import Foundation

extension Data {
  public init(hex: String) {
    self.init(Array<UInt8>(hex: hex))
  }

  public var bytes: Array<UInt8> {
    Array(self)
  }

  public func toHexString() -> String {
    self.bytes.toHexString()
  }
}


extension Array {
    var jsonString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self), let jsonString = String.init(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

extension Dictionary {
    var jsonString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self), let jsonString = String.init(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

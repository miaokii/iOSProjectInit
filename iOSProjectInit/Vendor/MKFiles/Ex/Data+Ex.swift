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

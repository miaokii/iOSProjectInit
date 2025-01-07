//
//  AES.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/10/27.
//

import Foundation
import CommonCrypto
import CryptoKit

fileprivate extension String {
//    static let product_aes_key = "8AEK6247qxYBdBtb"
//    static let product_aes_iv = "QONgVjIhDzDJbN5R"
    static let test_aes_key = "GQDTXGf7EZuCqwNG"
    static let test_aes_iv = "8GUUxywnlW0v9hk6"
    static let product_aes_key = "GQDTXGf7EZuCqwNG"
    static let product_aes_iv = "8GUUxywnlW0v9hk6"
}

enum AESError: Error {
    case encryptError
    case decryptError
}

class AEST {
    let isProduct: Bool
    
    private var key = ""
    private var iv = ""
    
    init(isProduct: Bool) {
        self.isProduct = isProduct
        key = isProduct ? .product_aes_key : .test_aes_key
        iv =  isProduct ? .product_aes_iv : .test_aes_iv
    }
    
    func encrypt(string: String) -> String {
        guard let data = string.data(using: .utf8) else {
            return string
        }
        guard let enc_data = aesOperation(operation: CCOperation(kCCEncrypt), data: data) else {
            return string
        }
        return enc_data.base64EncodedString()
    }
    
    func decrypt(data: Data) -> Data {
        guard var mapString = String.init(data: data, encoding: .utf8) else {
            return data
        }
        guard mapString.hasPrefix("enc-") else {
            return data
        }

        mapString = mapString.replacingOccurrences(of: "enc-", with: "")

        guard let mdata = Data.init(base64Encoded: mapString) else {
            return data
        }
        
        if let decryptData = aesOperation(operation: CCOperation(kCCDecrypt), data: mdata) {
            return decryptData
        } else {
            return data
        }
    }

    private func aesOperation(operation: CCOperation, data: Data) -> Data? {
        
        guard let keyData = key.data(using: .utf8),
              let ivData = iv.data(using: .utf8) else {
            return nil
        }
        
        var keyPtr = [UInt8](repeating: 0, count: kCCKeySizeAES128)
        var ivPtr = [UInt8](repeating: 0, count: kCCBlockSizeAES128)

        keyData.copyBytes(to: &keyPtr, count: key.count)
        ivData.copyBytes(to: &ivPtr, count: iv.count)

        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var numBytesEncrypted = 0

        let cryptorStatus = data.withUnsafeBytes { dataBytes in
            CCCrypt(operation, CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding),
                    keyPtr, key.count, ivPtr,
                    dataBytes.baseAddress, data.count,
                    &buffer, bufferSize,
                    &numBytesEncrypted)
        }

        if cryptorStatus == kCCSuccess {
            return Data(bytes: buffer, count: numBytesEncrypted)
        } else {
            
        }

        return nil
    }
}

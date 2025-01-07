//
//  Sandbox.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/17.
//

import Foundation
import UIKit

// MARK: - 沙盒管理
class Sandbox {
    
    static let share = Sandbox()
    
    init() {
        self.clearCache()
    }
    
    /// 文件临时存储目录
    lazy var multipartFilePath: String = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/MultipartFiles"
        guard !FileManager.default.fileExists(atPath: path) else {
            return path
        }
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
        return path
    }()
    
    func filePath(name: String) -> String {
        Sandbox.share.multipartFilePath + "/\(name)"
    }
    
    /// 删除
    func delete(file path: URL) {
        if FileManager.default.fileExists(atPath: path.path) {
            try? FileManager.default.removeItem(atPath: path.path)
        }
    }
    
    /// 写图片
    func write(image: UIImage, name:String, complete: @escaping (URL?)->()) {
        if let imageData = image.jpegData(compressionQuality: 1) {
            let imageUrl = multipartFilePath + "/\(name)"
            let nsData = NSData.init(data: imageData)
            
            if nsData.write(toFile: imageUrl, atomically: false) {
                complete(URL.init(fileURLWithPath: imageUrl))
            } else {
                complete(nil)
            }
        } else {
            complete(nil)
        }
    }
    
    //获取缓存大小 B
    var cacheSize: Int {
        //cache文件夹
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        //文件夹下所有文件
        let files = FileManager.default.subpaths(atPath: cachePath!)!
        //遍历计算大小
        var size = 0
        for file in files {
            //文件名拼接到路径中
            let path = cachePath! + "/\(file)"
            //取出文件属性
            do {
                let floder = try FileManager.default.attributesOfItem(atPath: path)
                for (key, fileSize) in floder {
                    //累加
                    if key == FileAttributeKey.size {
                        size += fileSize as! Int
                    }
                }
            } catch {
                print("出错了！")
            }
        }
        return size
    }
    
    var cacheSizeDescription: String {
        let size = cacheSize
        if size > 1024 * 1024 {
            return String(format: "%.1fM", Double(size) / 1024.0 / 1024.0)
        } else if size > 1024 {
            return String(format: "%.1fK", Double(size) / 1024.0)
        } else {
            return "\(size)B"
        }
    }
    
    // 删除缓存
    func clearCache(complete: (()->Void)? = nil) {
        //cache文件夹
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        //文件夹下所有文件
        let files = FileManager.default.subpaths(atPath: cachePath!)!
        
        //遍历删除
        for file in files {
            //文件名
            let path = cachePath! + "/\(file)"
            //存在就删除
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("出错了！")
                }
            }
        }
        complete?()
    }
}


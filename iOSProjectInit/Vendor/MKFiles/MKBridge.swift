//
//  MKBridge.swift
//  MuYunControl
//
//  Created by yoctech on 2023/8/16.
//

import UIKit

/// 设置MKFiels和项目之间的参数
struct MKBridge {
    /// 请求相关参数
    struct Request {
        /// 请求base url
        static var baseUrl = ""
        /// 默认请求头
        static var defaultHeader: (()->[String: String])?
    }
    
    /// UI相关
    struct UI {
        /// 默认背景颜色
        static var viewBackColor: UIColor = .white
        /// 导航栏返回按钮
        static var navBackImage: UIImage?
        /// 导航栏关闭按钮
        static var navCloseImage: UIImage?
        
        /// tableview空视图
        static var tableViewEmptyImage: UIImage?
    }
}

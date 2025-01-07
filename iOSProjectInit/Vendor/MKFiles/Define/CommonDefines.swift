//
//  Defines.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/25.
//

import UIKit


extension AppDelegate {
    
    func present(controller: UIViewController, presentationStyle: UIModalPresentationStyle = .fullScreen) {
        controller.modalPresentationStyle = presentationStyle
        controller.modalPresentationCapturesStatusBarAppearance = true
        guard let topVC = kWindow.topController else {
            return
        }
        if var presentedVC = topVC.presentedViewController {
            while presentedVC.presentedViewController != nil {
                presentedVC = presentedVC.presentedViewController!
            }
            presentedVC.present(controller, animated: true)
        } else {
            topVC.present(controller, animated: true)
        }
    }
    
    func push(controller: UIViewController) {
        kWindow.topController?.push(vc: controller)
    }
}

// MARK: - UI适配
/// 屏幕宽度
let screenWidth = UIScreen.main.bounds.width
/// 屏幕高度
let screenHeight = UIScreen.main.bounds.height
/// delegate
let kAppDelegate = UIApplication.shared.delegate as! AppDelegate
/// window
let kWindow = kAppDelegate.window!
/// 安全边距
var safeAreaInsets: UIEdgeInsets = {
    if #available(iOS 11.0, *) {
        return kWindow.safeAreaInsets
    } else{
        return .zero
    }
}()

/// 状态栏高度
var statusBarHeight: CGFloat {
    if #available(iOS 13.0, *) {
        return kWindow.safeAreaInsets.top
    } else {
        return UIApplication.shared.statusBarFrame.size.height
    }
}

/// 底部安全边距
let safeAreaBottom = safeAreaInsets.bottom
/// 导航栏高度
let navBarHeight: CGFloat = 44
/// 导航栏+状态栏高度
let navAllHeight = statusBarHeight + navBarHeight
/// tabbar高度
let tabBarHeight: CGFloat = 49 + safeAreaBottom
/// 适配偏移底部的间距
func offsetBottom(value: CGFloat) -> CGFloat  {
    return safeAreaBottom > 0 ? (safeAreaBottom + value/2) : value
}

/// 根据屏幕缩放
func wid(_ value: CGFloat) -> CGFloat {
    value/375*screenWidth
}

/// 根路径
var homePath: String = {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
}()

/// 图片保存位置
var imageRootPath  = { () -> String in
    let path = homePath + "/MultipartFileImages"
    do {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    } catch let error {
        print(error)
    }
    return path
}()


///
let kUserDefault = UserDefaults.standard
///
let kNotificationCenter = NotificationCenter.default

func postNotification(name: Notification.Name, object: Any? = nil) {
    kNotificationCenter.post(name: name, object: object)
}

// MARK: - Info Plist
let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
let bundleId = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
let projectName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String

//
//  Window+Shake.swift
//  SwiftLib
//
//  Created by yoctech on 2023/4/24.
//

import UIKit

#if DEBUG
// MARK: - 摇一摇显示日志
extension UIWindow {
    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard Logger.enableLogger, !LoggerController.shared.showd, let topVc = kWindow.topController else {
            return
        }
        
        let logVC = UINavigationController.init(rootViewController: LoggerController.shared)
        logVC.modalPresentationStyle = .fullScreen
        
        logVC.navigationBar.barTintColor = .white
        logVC.navigationBar.isTranslucent = false
        logVC.navigationBar.tintColor = .black
        
        let navAppear = UINavigationBarAppearance()
        navAppear.configureWithOpaqueBackground()
        navAppear.backgroundColor = UIColor.white
        navAppear.shadowColor = UIColor.clear
        navAppear.backgroundEffect = nil
        UINavigationBar.appearance().scrollEdgeAppearance = navAppear
        UINavigationBar.appearance().standardAppearance = navAppear
        
        if var fromeVC = topVc.presentedViewController {
            while (fromeVC.presentedViewController != nil) {
                fromeVC = fromeVC.presentedViewController!
            }
            fromeVC.present(logVC, animated: true)
        } else {
            topVc.present(logVC, animated: true)
        }
    }
}
#endif

//
//  App+Root.swift
//  XinCar
//
//  Created by yoctech on 2025/1/7.
//

import UIKit

extension AppDelegate {
    
    func logoutHandle() {
        kAppDelegate.windowRoot()
    }
    
    func windowRoot() {
        var rootVC: UIViewController?
        if Account.isFirstLaunch {
            rootVC = NavigationController.init(rootViewController: LaunchController())
        }
        else if Account.isLogin {
            if FrontRequest.isComplete {
                rootVC = TabbarController()
            } else {
                rootVC = LaunchController()
            }
        } else {
            if let topVC = window?.topController, topVC.isKind(of: LoginController.self) {
                return
            }
            rootVC = NavigationController(rootViewController: LoginController())
        }
        
        guard let root = rootVC else {
            return
        }
        
        switchTo(rootVC: root)
    }
    
    private func switchTo(rootVC: UIViewController, animation: Bool = true) {
        guard animation else {
            kWindow.rootViewController = rootVC
            return
        }
        
        let animation = CATransition()
        animation.duration = 0.3
        animation.type = .init(rawValue: "cube")
        animation.subtype = .fromRight
        animation.isRemovedOnCompletion = true
        
        if kWindow.rootViewController is LoginController {
            animation.type = .fade
        }
        
        kWindow.layer.add(animation, forKey: nil)
        kWindow.rootViewController = rootVC
    }
}

//
//  AppDelegate.swift
//  XinCar
//
//  Created by yoctech on 2025/1/7.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init()
        window?.backgroundColor = .background
        window?.makeKeyAndVisible()
        
        thridConfig()
        // pushConfig(launchOptions: launchOptions)
        windowRoot()
    
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        UITextField.appearance().tintColor = .theme
        UITextView.appearance().tintColor = .theme
        return true
    }
}


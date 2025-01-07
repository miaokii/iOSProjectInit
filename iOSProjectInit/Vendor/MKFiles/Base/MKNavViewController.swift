//
//  NavViewController.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/26.
//

import UIKit

class MKNavViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if (self.viewControllers.count > 0) {
            let backItem = UIBarButtonItem.init(image: MKBridge.UI.navBackImage, style: .done, target: self, action: #selector(popVc))
            viewController.navigationItem.leftBarButtonItem = backItem
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    @objc private func popVc() {
        topViewController?.pop()
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if animated {
            let controller = viewControllers.last
            controller?.hidesBottomBarWhenPushed = false
        }
        return super.popToRootViewController(animated: animated)
    }
}

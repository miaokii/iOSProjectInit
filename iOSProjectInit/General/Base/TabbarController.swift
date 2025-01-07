//
//  TabbarController.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/10/23.
//

import UIKit
import TextAttributes
import HBDNavigationBar

// import Lottie

protocol TabbarSource: UIViewController {
    var tabTitle: String { get }
    var jsonImageName: String { get }
    var tabNormalImage: UIImage? { get }
    var tabSelectedImage: UIImage? { get }
}

class TabbarController: UITabBarController {
    
    fileprivate lazy var transform = Transform()
    fileprivate var titles = [String]()
    fileprivate var jsonImageNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addChildControllers()
    }
    
    deinit {
        print("deinit \(String.init(describing: Self.self)): \(String.init(format: "%p", self))")
    }
    
    private func setupUI() {
        delegate = self
        view.backgroundColor = .background
        
        hbd_barTintColor = .white
        hbd_barShadowHidden = true
        hbd_barStyle = .default
        
        tabBar.isTranslucent = false
        
        if #available(iOS 13, *) {
            let appearance = tabBar.standardAppearance.copy()
            appearance.shadowColor = .clear
            appearance.backgroundColor = .white
            /// 普通
            let normalTextAtt = TextAttributes.init().font(.regular(11)).foregroundColor(.textColorGray)
            /// 选中
            let selectedTextAtt = TextAttributes.init().font(.regular(11)).foregroundColor(.theme)
            //iOS13.0以上用方法setTitleTextAttributes(_ attributes: [NSAttributedString.Key : Any]?, for state: UIControl.State)设置字体颜色无效。
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalTextAtt.dictionary
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTextAtt.dictionary
            
            appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = .init(horizontal: 0, vertical: -4)
            appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = .init(horizontal: 0, vertical: -4)
            tabBar.standardAppearance = appearance
        } else {
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = .init()
        }
        tabBar.backgroundColor = UIColor.white
        tabBar.shadow(color: .lightGray)
    }
    
    private func addChildControllers() {
        
        #if DEBUG
//        addSubviewController(TestController.init())
        #endif
        title = titles.first
    }
    
    private func addSubviewController(_ controller: TabbarSource) {
        controller.tabBarItem.title = controller.tabTitle
        controller.tabBarItem.image = controller.tabNormalImage?.withRenderingMode(.alwaysOriginal)
        controller.tabBarItem.selectedImage = controller.tabSelectedImage?.withRenderingMode(.alwaysOriginal)
        controller.title = controller.tabTitle
        addChild(NavigationController(rootViewController: controller))
        controller.tabBarItem.tag = titles.count
        
        titles.append(controller.tabTitle)
        jsonImageNames.append(controller.jsonImageName)
    }
    
    func selectCustomer() {
        self.selectedViewController = viewControllers?[1]
        guard let controller = self.selectedViewController else {
            return
        }
        tabBarController(self, didSelect: controller)
    }
    
//    override var childForStatusBarHidden: UIViewController? {
//        selectedViewController
//    }
//    
//    override var childForStatusBarStyle: UIViewController? {
//        selectedViewController
//    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    override var shouldAutorotate: Bool {
        false
    }
}

extension TabbarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        transform.selectedIndex = item.tag
        transform.preIndex = selectedIndex
        
        let idx = item.tag
        
        let itemWidth = screenWidth/CGFloat(titles.count)
        let mid = (CGFloat(idx)+0.5)*itemWidth
        
        guard let barButton = tabBar.subviews.first(where: { subView in
            return mid > subView.left && mid < subView.right && "UITabBarButton" == NSStringFromClass(subView.classForCoder)
        }) else {
            return
        }
        
//        var animationView: LottieAnimationView?
        var tabBarSwappableImageView: UIImageView?
        
        for subView in barButton.subviews {
            if "UITabBarSwappableImageView" == NSStringFromClass(subView.classForCoder) {
                tabBarSwappableImageView = subView as? UIImageView
            }
//            if subView is LottieAnimationView {
//                animationView = subView as? LottieAnimationView
//            }
        }
        
        guard let tabBarSwappableImageView = tabBarSwappableImageView else {
            return
        }
        
//        animationView?.stop()
//        animationView?.removeFromSuperview()
//        animationView = nil
        
        var frame = tabBarSwappableImageView.frame
        frame.origin = .zero
        
//        let lotView = LottieAnimationView.init(name: jsonImageNames[idx])
//        lotView.frame = frame
//        lotView.contentMode = .scaleAspectFit
//        lotView.animationSpeed = 1
//        lotView.center = tabBarSwappableImageView.center
//        lotView.isUserInteractionEnabled = false
//        barButton.addSubview(lotView)
//        barButton.sendSubviewToBack(lotView)
//        tabBarSwappableImageView.isHidden = true
//        
//        animationView = lotView
//        
//        lotView.play(fromProgress: 0, toProgress: 1) { completed in
//            if completed {
//                tabBarSwappableImageView.isHidden = false
//                animationView?.removeFromSuperview()
//            }
//        }
    }
}

extension TabbarController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        return true
//    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}

/// TabbarController的动画转换器
fileprivate class Transform: NSObject {
    var preIndex: Int
    var selectedIndex: Int
    
    override init() {
        preIndex = 0
        selectedIndex = 0
        super.init()
    }
}

extension Transform: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let tabVC = tabBarController as? TabbarController else {
            return nil
        }
        
        return tabVC.transform
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        return true
//    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        tabBarController.title = viewController.title
    }
}

extension Transform: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from)else {
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toViewController.view)
        
        if (selectedIndex > preIndex) {
            toViewController.view.transform = CGAffineTransformMakeTranslation(screenWidth, 0)
        } else if (selectedIndex < preIndex) {
            toViewController.view.transform = CGAffineTransformMakeTranslation(-screenWidth, 0)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut) {
            toViewController.view.transform = .identity
            if (self.selectedIndex > self.preIndex) {
                fromViewController.view.transform = CGAffineTransformMakeTranslation(-screenWidth, 0)
            } else if (self.selectedIndex < self.preIndex) {
                fromViewController.view.transform = CGAffineTransformMakeTranslation(screenWidth, 0)
            }
        } completion: { _ in
            toViewController.view.transform = .identity
            fromViewController.view.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        /*
        let translationX = containerView.bounds.size.width + kPadding
        let cgAffineTransform = CGAffineTransform(translationX: preIndex > selectedIndex ? translationX : -translationX, y: 0)
        
        toViewController.view.transform = cgAffineTransform.inverted()
        
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: kDamping, initialSpringVelocity: kVelocity, options: .curveEaseInOut) {
            fromViewController.view.transform = cgAffineTransform
            toViewController.view.transform = .identity
        } completion: { _ in
            fromViewController.view.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
         
         */
        
        

    }
    
    
}

//
//  NavigationController.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/10/23.
//

import UIKit
import QuartzCore
import HBDNavigationBar

/*
 
 Controller通过 hbd_barImage 设置背景图片，hbd_barTintColor 就会失效

 背景的计算规则如下：

 hbd_barImage 是否有值，如果有，将其设置为背景，否则下一步
 hbd_barTintColor 是否有值，如果有，将其设置为背景，否则下一步
 [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault] 是否有返回值，如果有，将其设置为背景，否则下一步
 [UINavigationBar appearance].barTintColor 是否有值，如果有，将其设置为背景，否则下一步
 根据 barStyle 计算出默认的背景颜色，并将其设置为背景
 如果使用图片来设置背景，并且希望带有透明度，使用带有透明度的图片即可。

 如果需要毛玻璃效果，那么设置给 hbd_barTintColor 的值应该带有透明度，具体数值根据色值的不同而不同。
 不要通过 hbd_barAlpha 来调整毛玻璃效果，它是用来动态控制导航栏背景的透与暗的，就像掘金收藏页面那个效果一样。

 图片是没有毛玻璃效果的

 Aways translucent

 库重写了 UINavigationBar 的 translucent 属性，使得它的值总是 YES。

 本库根据导航栏的背景是否含有透明度，自动调整 UIViewController#edgesForExtendedLayout 这个属性。

 如果导航栏一开始是不透明的，由于后续操作而变透明，需要设置 UIViewController#extendedLayoutIncludesOpaqueBars 的值为 YES。
 
 // 一开始导航栏为不透明
 self.hbd_barTintColor = UIColor.whiteColor;
 self.extendedLayoutIncludesOpaqueBars = YES;
 
 // 由于用户操作而变透明
 self.hbd_barAlpha = 0.5;
 [self hbd_setNeedsUpdateNavigationBar];
 
 基本原则就是如果我们设置的背景是含有透明度的，那么页面就应该位于 NavigationBar 底下(under)，否则位于 NavigationBar 下面(below).
 如果我们的 NavigationBar 一开始是不透明的，但有可能因为用户操作而变透明，那么设置 extendedLayoutIncludesOpaqueBars 的值为 YES。
 
 有时，我们需要在用户点击返回按钮或者侧滑返回时提醒用户，此时，可以重写以下方法，返回 NO

 - (BOOL)hbd_backInteractive {
     // show alert
     return NO;
 }

 */

class NavigationController: HBDNavigationController {
    lazy private var pushAnimator = NavigationPushAnimator()
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0, let vc = viewController as? MKBaseViewController {
            vc.addBackNavigationBarItem()
        }
        viewController.hidesBottomBarWhenPushed = true
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
    
//    override var childForStatusBarStyle: UIViewController? {
//        topViewController
//    }
//    
//    override var childForStatusBarHidden: UIViewController? {
//        topViewController
//    }
}

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            if toVC.pushByPresentStyle {
                pushAnimator.isShow = true
                return pushAnimator
            }
            return nil
        }
        else {
            if fromVC.pushByPresentStyle {
                pushAnimator.isShow = false
                return pushAnimator
            }
            return nil
        }
    }
}


fileprivate class NavigationPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
    var isShow = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }

        let animationContainer = transitionContext.containerView
        animationContainer.addSubview(fromVC.view)
        animationContainer.addSubview(toVC.view)
        
        let transformHeight: CGFloat = screenHeight
        /*
        if isShow {
            transformHeight = screenHeight - (toVC.hbd_barHidden ? 0 : navAllHeight)
        } else {
            transformHeight = fromVC.view.frame.height
        }
         */
                
        if !isShow {
            animationContainer.bringSubviewToFront(fromVC.view)
        }
        
//        let timingFunc = CAMediaTimingFunction.init(controlPoints: 0.6, 0.6, 1, 1)
//
//        let animation = CAKeyframeAnimation.transform(with: .translationY)
//        animation.duration = duration
//        if isShow {
//            animation.values = [transformHeight, 0]
//            animation.timingFunction = timingFunc
//        } else {
//            animation.values = [0, transformHeight]
//            animation.timingFunction = timingFunc
//        }
//
//        CATransaction.begin()
//        CATransaction.setCompletionBlock {
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        }
//
//        if isShow {
//            toVC.view.layer.addAnimation(animation)
//        } else {
//            fromVC.view.layer.addAnimation(animation)
//        }
//        CATransaction.commit()
        

        if isShow {
            toVC.view.transform = .init(translationX: 0, y: transformHeight)
        }
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut) {
            if self.isShow {
                toVC.view.transform = .identity
            } else {
                fromVC.view.transform = .init(translationX: 0, y: transformHeight)
            }
        } completion: { _ in
            if !self.isShow {
                fromVC.view.transform = .identity
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

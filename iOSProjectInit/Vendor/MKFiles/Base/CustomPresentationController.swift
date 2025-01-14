//
//  CustomPresentationController.swift
//  XinCar
//
//  Created by yoctech on 2025/1/10.
//

import UIKit

/// 自定义present展示
class CustomPresentationController: UIPresentationController {
    
    var cornerRadius: CGFloat = 15
    
    deinit {
        print("deinit \(String.init(describing: Self.self))")
    }
    /// 灰度背景
    private var dimmingView: UIView!
    ///
    private var presentationWrappingView: UIView?
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        // 使用PresentationController需要将presentedController modalPresentationStyle设置为custom
        presentedViewController.modalPresentationStyle = .custom
    }
    
    /// 在呈现期间的动画的视图， 必须是UIPresentationController的视图的祖先或UIPresentationController的view本身。
    ///（默认值：显示的视图控制器的视图self.view）
    override var presentedView: UIView? {
        // 返回在presentationTransitionWillBegin：时创建的包装view
        return presentationWrappingView
    }
    
    /// 将开始呈现过渡，这里可以添加自己的视图并设置动画
    /// 这是在展示开始时在展示控制器上调用的首个方法之一
    /// 在调用此方法时，已经创建了containerView并为新的控制器显示设置了视图层次结构
    /// 但是，presentedView尚未被创建
    override func presentationTransitionWillBegin() {
        /// super.presentedView就是presentedViewController.view
        guard let targetPresentView = super.presentedView,
              let containerView = self.containerView else { return }
        /*
         添加阴影、圆角
         presentationShadowView         <- shadow
           |- presentationRoundedView   <- rounded corners (masksToBounds)
                |- presentedViewControllerWrapperView
                     |- presentedViewControllerView (presentedViewController.view)
         */
        
        /// shadow
        let presentationShadowView = UIView.init(frame: frameOfPresentedViewInContainerView)
        presentationShadowView.layer.shadowOpacity = 0.2
        presentationShadowView.layer.shadowRadius = 10
        presentationShadowView.layer.shadowOffset = .init(width: 0, height: -5)
        
        let pangesture = UIPanGestureRecognizer()
        pangesture.addTarget(self, action: #selector(shadowViewPaned(sender:)))
        presentationShadowView.addGestureRecognizer(pangesture)
        
        presentationWrappingView = presentationShadowView
        /*
         presentationRoundedView比显示的视图控制器的视图的高度高corner_radius。 这是因为cornerRadius应用于视图的所有角。 由于效果只要求将顶部的两个角都弄圆，所以我们调整视图的大小，使底部的CORNER_RADIUS点位于屏幕的底部边缘以下。
        */
        let presentationRoundedView = UIView.init()
        presentationRoundedView.frame = presentationShadowView.bounds.inset(by: .init(top: 0, left: 0, bottom: -cornerRadius, right: 0))
        presentationRoundedView.layer.cornerRadius = cornerRadius
        presentationRoundedView.layer.masksToBounds = true
        presentationRoundedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        /*
         为了撤消添加到presentationRoundedView的额外高度，presentedViewControllerWrapperView由CORNER_RADIUS点插入。 这也将presentedViewControllerWrapperView的边界大小与-frameOfPresentedViewInContainerView的大小相匹配。
        */
        let presentViewControllerWrapperView = UIView.init()
        presentViewControllerWrapperView.frame = presentationRoundedView.bounds.inset(by: .init(top: 0, left: 0, bottom: cornerRadius, right: 0))
        presentViewControllerWrapperView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Add targetPresentView -> presentedViewControllerWrapperView.
        targetPresentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        targetPresentView.frame = presentViewControllerWrapperView.bounds
        presentViewControllerWrapperView.addSubview(targetPresentView)

        // Add presentViewControllerWrapperView -> presentationRoundedView.
        presentationRoundedView.addSubview(presentViewControllerWrapperView)

        // Add presentationRoundedView -> presentationWrapperView.
        presentationShadowView.addSubview(presentationRoundedView)
        
        dimmingView = UIView.init(frame: containerView.bounds)
        dimmingView.backgroundColor = .black
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissPresentedViewController)))
        containerView.addSubview(dimmingView!)
        
        /// 背景淡入
        let transitionCoordinator = presentingViewController.transitionCoordinator
        dimmingView.alpha = 0
        transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 0.4
        }, completion: nil)
    }
    
    /// 呈现过渡结束
    override func presentationTransitionDidEnd(_ completed: Bool) {
        /*
         当交互式过渡被取消时，返回false
        */
        if !completed {
            /*
             移除presentedController并销毁containerView，同时隐式的销毁在presentationTransitionWillBegin
             中创建的视图，保险起见，强制删除这些视图
            */
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    /// 取消呈现即将开始
    override func dismissalTransitionWillBegin() {
        /*
         过去过渡协调对象，以对dimmingView执行单出动画
        */
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }
    
    /// 已经取消呈现
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        /*
         当交互式过渡被取消时，返回false
        */
        if completed {
            /*
             移除presentedController并销毁containerView，同时隐式的销毁在presentationTransitionWillBegin
             中创建的视图，保险起见，强制删除这些视图
            */
            self.presentationWrappingView = nil;
            self.dimmingView = nil;
        }
    }
    
    /// 每当presentedViewController的preferredContentSize属性更改时，都会调用此方法
    /// presentationTransitionWillBegin之前调用
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if let containerController = container as? UIViewController, containerController == presentedViewController {
            containerView?.setNeedsLayout()
        }
    }
    
    /*
        当展示控制器的viewWillTransitionToSize:withTransitionCoordinator:方法被调用前，就会先
        调用该方法获取presentedViewController.view的新的size
        之后展示控制器会调用presentedViewController的viewWillTransitionToSize:withTransitionCoordinator:方法
        并将获取到的size作为第一个参数传递给该方法
     
        注意由展示控制器来调整呈现的控制器的view大小为改size
        这个操作应该在containerViewWillLayoutSubviews中执行
     */
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let containerController = container as? UIViewController, containerController == presentedViewController {
            return containerController.preferredContentSize
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    /// 在展示过渡结束时，presentedcontroller在容器视图中的位置
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerViewBounds = containerView?.bounds ?? .zero
        let presentedViewContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerViewBounds.size)
        
        var presentedViewControllerFrame = containerViewBounds
        presentedViewControllerFrame.size.height = presentedViewContentSize.height
        presentedViewControllerFrame.origin.y = containerViewBounds.maxY - presentedViewContentSize.height
        return presentedViewControllerFrame
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        presentationWrappingView?.frame = frameOfPresentedViewInContainerView
    }
    
    private var panBeginPosition: CGPoint = .zero
    @objc private func shadowViewPaned(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let translationY = sender.translation(in: dimmingView).y
            guard translationY > 0 else { return }
            let originFrame = frameOfPresentedViewInContainerView
            presentationWrappingView?.frame = .init(x: 0, y: originFrame.origin.y+translationY, width: originFrame.size.width, height: originFrame.size.height)
        case .ended:
            let originFrame = frameOfPresentedViewInContainerView
            let nowFrame = presentationWrappingView?.frame ?? originFrame
            let hd = min(originFrame.size.height / 3, 200)
            if nowFrame.minY - originFrame.minY > hd  {
                dismissPresentedViewController()
            } else {
                UIView.animate(withDuration: 0.1) {
                    self.presentationWrappingView?.frame = originFrame
                }
            }
        default: break
        }
    }
    
    @objc private func dismissPresentedViewController() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

extension CustomPresentationController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(presentedViewController == presented,
               "You didn't initialize \(self) with the correct presentedViewController")
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension CustomPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated ?? false ? 0.35 : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVc = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let container = transitionContext.containerView
        let isPresent = toVc.presentingViewController == fromVC
        
        var fromFinalFrame = transitionContext.finalFrame(for: fromVC)
        
        var toInitFrame = transitionContext.initialFrame(for: toVc)
        let toFinalFrame = transitionContext.finalFrame(for: toVc)
        
        if let toView = toView {
            container.addSubview(toView)
        }
        
        if isPresent {
            toInitFrame.origin = CGPoint.init(x: container.bounds.minX, y: container.bounds.maxY)
            toInitFrame.size = toFinalFrame.size
            toView?.frame = toInitFrame
        } else if let fromView = fromView {
            fromFinalFrame = fromView.frame.offsetBy(dx: 0, dy: fromView.frame.height)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: .curveEaseInOut) {
            if isPresent {
                toView?.frame = toFinalFrame
            } else {
                fromView?.frame = fromFinalFrame
            }
        } completion: { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}


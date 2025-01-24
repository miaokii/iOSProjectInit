//
//  LaunchController.swift
//  XinCar
//
//  Created by yoctech on 2025/1/7.
//

import UIKit

class LaunchController: BaseViewController {
    private var presentBtn: UIButton!
    private var urlField: MKTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentBtn = UIButton.init(superView: view, title: "PRESENT", titleColor: .white, font: .medium(16), cornerRadius: 1)
        presentBtn.setNormal(backgroundImage: .gradient(colors: [.red, .orange, .yellow]))
        presentBtn.addTarget(self, action: #selector(presentVC), for: .touchUpInside)
        presentBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.bottom.equalTo(-safeAreaBottom-20)
            make.height.equalTo(45)
        }
        
        urlField = .init(superView: view, text: "", textColor: .black, placeHolder: "url")
        urlField.textAlignment = .center
        urlField.borderStyle = .roundedRect
        urlField.backgroundColor = .background
        urlField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(45)
            make.top.equalTo(navAllHeight + 20)
        }
        
        let button = UIButton.init(superView: view, title: "访问", titleColor: .black, target_selector: (self, #selector(toWebview)))
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(urlField.snp.bottom).offset(20)
        }
    }
    
    @objc private func toWebview() {
        guard let url = URL.init(string: urlField.text ?? "") else {
            return
        }
        
        let vc = WebConroller.init()
        vc.url = url
        push(vc: vc)
    }
    
    @objc private func presentVC() {
        let vc = DemoController()
        present(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

class WebConroller: MKWebviewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        hbd_barHidden = true
        
//        let backBtn = UIButton.init(superView: view)
//        backBtn.setClosure { [weak self] sender in
//            self?.pop()
//        }
//        backBtn.snp.makeConstraints { make in
//            make.left.equalTo(20)
//            make.size.equalTo(40)
//            make.top.equalTo(statusBarHeight)
//        }
//        
//        let refreshBtn = UIButton.init(superView: view)
//        refreshBtn.setClosure { [weak self] sender in
//            self?.loadUrl()
//        }
//        refreshBtn.snp.makeConstraints { make in
//            make.right.equalTo(-20)
//            make.size.equalTo(40)
//            make.top.equalTo(statusBarHeight)
//        }
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        edgesForExtendedLayout = []
        webView.snp.remakeConstraints { make in
            make.edges.equalTo(0)
        }
    }
}

class DemoController: BaseViewController, UIViewControllerTransitioningDelegate {
    
    override func initController() {
        super.initController()
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let slider = UISlider()
        slider.maximumValue = 1
        slider.minimumValue = 0.4
        slider.value = 0.5
        view.addSubview(slider)
        slider.addTarget(self, action: #selector(contentSizeChange(sender: )), for: .valueChanged)
        slider.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.bottom.equalTo(-offsetBottom(value: 20))
        }
        contentSizeChange(sender: slider)
        
        let dismissBtn = UIButton.init(superView: view, title: "DISMISS", titleColor: .white)
        dismissBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(slider.snp.top).offset(-10)
        }
        dismissBtn.setClosure { [weak self] sender in
            self?.dismiss(animated: true)
        }
    }
    
    @objc private func contentSizeChange(sender: UISlider) {
        preferredContentSize = .init(width: screenWidth, height: screenHeight*CGFloat(sender.value))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setGradientBack(colors: [.red, .orange], end: .init(x: 0, y: 1))
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

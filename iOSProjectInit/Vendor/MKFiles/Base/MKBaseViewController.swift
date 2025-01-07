//
//  MKBaseViewController.swift
//  MuYunControl
//
//  Created by miaokii on 2023/2/26.
//

import UIKit

#if canImport(HBDNavigationBar)
import HBDNavigationBar
#endif

class MKBaseViewController: UIViewController {
    
    lazy var af = AF()
    
    lazy var customerNavigationView: UIView! = {
        let navView = UIView.init(super: view, backgroundColor: .white)
        navView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navAllHeight)
        }
        hbd_barHidden = true
        return navView
    }()
    
    lazy var customerTitleLabel: UILabel! = {
        let label = UILabel.init(superView: customerNavigationView, text: "", textColor: .textColorBlack, font: .medium(17), aligment: .center)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(navBarHeight)
        }
        return label
    }()
    
    lazy var customBackItem: UIButton! = {
        let back = UIButton.init(superView: customerNavigationView, title: "", titleColor: .black, font: .regular(15))
        back.tintColor = hbd_tintColor
        back.setClosure { [weak self] sender in
            if let _ = self?.navigationController {
                self?.pop()
            } else {
                self?.dismiss()
            }
        }
        back.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(8)
            make.width.greaterThanOrEqualTo(35)
            make.height.equalTo(navBarHeight)
        }
        return back
    }()
    
    var customBackTitle: String = "" {
        didSet {
            if customBackTitle.isEmpty {
                customBackItem.setNormal(image: MKBridge.UI.navCloseImage)
            } else {
                customBackItem.setNormal(image: nil)
                customBackItem.setNormal(title: customBackTitle)
            }
        }
    }
    
    var customerTitle: String = "" {
        didSet {
            if let _ = navigationController {
                if customBackTitle.isEmpty {
                    customBackTitle = ""
                }
            }
            customerTitleLabel.text = customerTitle
        }
    }
    
    lazy var rightBarButtomItem: UIBarButtonItem = {
        let rightItem = UIBarButtonItem.init(title: "", style: .done, target: self, action: #selector(rightBarItemTaped))
        navigationItem.rightBarButtonItem = rightItem
        return rightItem
    }()
    
    var rightBarButtonItemTitle: String? {
        set {
            self.rightBarButtomItem.title = newValue
        }
        get {
            return self.rightBarButtomItem.title
        }
    }
    
    var rightBarButtonItemImage: UIImage? {
        set {
            self.rightBarButtomItem.image = newValue
        }
        get {
            return self.rightBarButtomItem.image
        }
    }
    
    func viewWillLoad() {
        view.backgroundColor = MKBridge.UI.viewBackColor
        
        #if canImport(HBDNavigationBar)
        hbd_barTintColor = .white
        hbd_barShadowHidden = true
        hbd_barStyle = .default
        #endif
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initController()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initController() {
        
    }
    
    override func viewDidLoad() {
        viewWillLoad()
        super.viewDidLoad()
    }
    
    @objc private func rightBarItemTaped() {
        self.rightBarButtonItemAction()
    }
    
    func addBackgroundRightBarButton(title: String, font: UIFont = .regular(15), titleColor: UIColor = .white, image: UIImage? = nil, backgroundColor: UIColor = .theme, cornerRadius: CGFloat = 4, imageTitleSpacing: CGFloat = 5, contentInset: UIEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: 10)) {
        
        let button = LGButton.button(superView: nil, normalTitle: title, normalTitleColor: titleColor, font: font, normalImage: image, backgroundColor: backgroundColor, vertical: false, titleImgSpace: imageTitleSpacing, contentInset: contentInset)
        button.btnCornerRadius = cornerRadius
        button.setClosure { [weak self] sender in
            self?.rightBarButtonItemAction()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: button)
    }
    
    func rightBarButtonItemAction() {
        
    }
    
    #if canImport(HBDNavigationBar)
    func changeBar(style: UIBarStyle) {
        if style == .black {
            hbd_barStyle = .black
            hbd_tintColor = .white
            hbd_titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white ]
        } else {
            hbd_barStyle = .default
            hbd_tintColor = .black
            hbd_titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        hbd_setNeedsUpdateNavigationBar()
    }
    #endif
    
    func addBackNavigationBarItem() {
        let backItem = UIBarButtonItem.init(image: .init(named: "ico_back_back"), style: .done, target: self, action: #selector(popNav))
        navigationItem.leftBarButtonItem = backItem
    }
    
    @objc private func popNav() {
        pop()
    }
    
    deinit {
        kNotificationCenter.removeObserver(self)
        print("deinit \(String.init(describing: Self.self)): \(String.init(format: "%p", self))")
    }
}

extension MKBaseViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        kWindow.endEditing(true)
    }
}

extension UIViewController {
    
    func push(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func pop() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss()
        }
    }
    
    func popToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func pop(to vcClass: UIViewController.Type) {
        guard let nav = navigationController else {
            return
        }
        for vc in nav.viewControllers {
            if vc.classForCoder == vcClass.classForCoder() {
                navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
    
    func remove(vcClasses: [UIViewController.Type]) {
        guard var vcs = navigationController?.viewControllers else {
            return
        }
        
        vcs.removeAll { controller in
            vcClasses.contains { vcClass in
                controller.classForCoder == vcClass.classForCoder()
            }
        }
        navigationController?.setViewControllers(vcs, animated: false)
    }
    
    @objc func dismiss() {
        self.dismiss(animated: true)
    }
    
    private static var presentKey: UInt8 = 0
    var pushByPresentStyle: Bool {
        get {
            objc_getAssociatedObject(self, &Self.presentKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &Self.presentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

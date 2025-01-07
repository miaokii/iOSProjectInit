//
//  ChooseServer.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/10/25.
//

import UIKit
import TextAttributes

fileprivate extension String {
    static let ProductionService = "https://apps.rongxk.cn"
    static let TestService = "https://test-apps.rongxk.cn"
    static let DevService = "https://dev-apps.rongxk.cn"
}

fileprivate extension String {
    static let product_sign_key = "x8eIC5sON7xKRbJeNttFibW5kGulL68Nz0ZXY4XurRBo4AQZB11Z0jIjFcLsIuitLQc29QeKyooorL32wZu5LZm8"
    static let test_sign_key = "NmFhYjEzYWFlOTFlN2Q2ZmJiZDAzOGYzODY4ZDdiNzg3OWZkYzYzOTg2M2RjM2RhOGNkYmE1YTRhNzMxYjIwMA=="
}

enum ServerType: Int {
    case product
    case dev
    case test
    case custom
    
    var config: (url: String, name:String, phone: String) {
        switch self {
        case .product:  return (.ProductionService, "生产环境", "14999990001" )
        case .dev:      return (.DevService, "开发环境 Dev", "14999990001" )
        case .test:     return (.TestService, "测试环境 Test", "14999990001" )
        default:        return ("", "", "")
        }
    }
    
    var staticUrl: String {
        switch self {
        case .test:     return "https://test-file.rongxk.com"
        case .dev:      return "https://dev-file.rongxk.com"
        case .product:  return "https://file.rongxk.com"
        default:        return ""
        }
    }
    
    var socketUrl: String {
        switch self {
        case .test:     return "https://test-socket.rongxk.com"
        case .dev:      return "https://dev-socket.rongxk.com"
        case .product:  return "https://socket.rongxk.com"
        default:        return ""
        }
    }
    
    var protocolUrl: String {
        switch self {
        case .test:     return "https://test-protocol.rongxk.com"
        case .dev:      return "https://dev-protocol.rongxk.com"
        case .product:  return "https://protocol.rongxk.cn"
        default:        return "https://protocol.rongxk.cn"
        }
    }
    
    var webUrl: String {
        switch self {
        case .test:     return "https://test-saas.rongxk.com/index.html"
        case .dev:      return "https://dev-saas.rongxk.com/index.html"
        case .product:  return "https://saas.rongxk.com/index.html"
        default:        return "https://saas.rongxk.com/index.html"
        }
    }
    
    var isProduct: Bool {
        return self == .product
    }
    
    func protocolFrom(urlString: String) -> URL? {
        let url = URL.init(string: protocolUrl)
        return url?.appendingPathComponent(urlString, conformingTo: .url)
    }
}

struct ServerConfig: Model {
    var baseUrl = ""
    var urlName = ""
    var isProduct = false
    var encryptEnable = false
    var testAesKey = false
    var serverTypeVal = 0
    var serverPhone = ""
    var staticUrl = ""
    var socketUrl = ""
    var webUrl = ""
    var signKey = ""
    var aes: AEST?
    
    var serverType: ServerType {
        return .init(rawValue: serverTypeVal) ?? .custom
    }
    
    init(type: ServerType) {
        self.serverTypeVal = type.rawValue
        self.baseUrl = type.config.url
        self.webUrl = type.webUrl
        self.urlName = type.config.name
        self.serverPhone = type.config.phone
        self.isProduct = type == .product
        self.signKey = isProduct ? .product_sign_key : .test_sign_key
        
        self.encryptEnable = true
        self.testAesKey = true
        
        switch self.serverType {
        case .product:
            self.testAesKey = false
        case .dev:
            self.encryptEnable = true
        default: break
        }
        
        if encryptEnable {
            aes = .init(isProduct: isProduct)
        }
        
        staticUrl = type.staticUrl
        socketUrl = type.socketUrl
    }
    
    init() {}
}

struct ChooseServer {
    
    static let serverChangedNotification: Notification.Name = .init(rawValue: "serverChanged")
    
    static var currentServer: ServerConfig {
        return share.selectedServer
    }
    static var serverChanged: ((ServerConfig)->Void)? {
        get { share.serverChanged }
        set { share.serverChanged = newValue }
    }
    
    static var enable: Bool = false
    
    private static var share = ChooseServer()
    
    private var servers = [ServerConfig]()
    private var productServer: ServerConfig!
    private var selectedServer: ServerConfig! {
        didSet {
            guard oldValue.urlName != selectedServer.urlName else {
                return
            }
            if let changed = serverChanged {
                changed(selectedServer)
            }
            UserDefaults.selectedServerName = selectedServer.urlName
            postNotification(name: Self.serverChangedNotification, object: selectedServer)
        }
    }
    private var serverChanged: ((ServerConfig)->Void)?
    
    private var customConfigs = [ServerConfig]()
    
    static func add(server: ServerConfig) {
        if server.isProduct {
            assert(share.productServer == nil, "只可设置一个生产服务器")
        }
        if server.serverType == .custom {
            share.addCustom(config: server)
        } else {
            share.servers.append(server)
        }
    }
    
    static func add(servers: [ServerConfig]) {
        for server in servers {
            add(server: server)
        }
    }
    
    static func switchServer() {
        guard Self.enable else {
            return
        }
        let allServer = share.servers + share.customConfigs
        let sheet = MKAlertView.alertView(title: "选择服务器", message: "仅为调试功能，线上无该功能", style: .sheet)
        sheet.addCancelAction()
        for server in allServer {
            let nowCheck = server.urlName == share.selectedServer.urlName
            let serverName = NSMutableAttributedString.init()
            serverName.append(.init(string: server.urlName, attributes: TextAttributes().foregroundColor(.black).font(.regular(16))))
            if nowCheck {
                serverName.append(.init(string: " ✅"))
            }
            
            let action = MKAlertAction.action(title: "", style: .default) { _ in
                share.selectedServer = server
            }
            action.attributedTitle = serverName
            sheet.add(action: action)
        }
        
        if !share.customConfigs.isEmpty {
            sheet.add(action: .action(title: "移除所有自定义环境", style: .default, handler: { _ in
                share.removeAllCustomConfig()
            }))
        }
        
        sheet.add(action: .action(title: "添加一个新环境", style: .default, handler: { _ in
            NewCustomerServerView().show()
        }))
        
        sheet.show()
    }
    
    init() {
        self.productServer = .init(type: .product)
        self.servers.append(self.productServer)
        
        guard Self.enable else {
            selectedServer = productServer
            return
        }
        
        servers.append(ServerConfig.init(type: .dev))
        servers.append(ServerConfig.init(type: .test))
        
        self.customConfigs = UserDefaults.customeConfigs
        
        if let selectedServerName = UserDefaults.selectedServerName, selectedServerName.notEmpty {
            let allServers = servers + customConfigs
            for server in allServers {
                if server.urlName == selectedServerName {
                    selectedServer = server
                    break
                }
            }
        } else {
            selectedServer = self.productServer
        }
    }
    
    private mutating func addCustom(config: ServerConfig) {
        customConfigs.append(config)
        UserDefaults.customeConfigs = customConfigs
    }
    
    private mutating func removeAllCustomConfig() {
        customConfigs.removeAll()
        if selectedServer.serverType == .custom {
            selectedServer = servers.first
        }
        UserDefaults.customeConfigs = customConfigs
    }
}

fileprivate extension UserDefaults {
    static var customeConfigs: [ServerConfig] {
        set {
            let jsons = newValue.kj.JSONArray()
            UserDefaults.standard.setValue(jsons, forKey: "cusConfigs")
        }
        
        get {
            guard let jsons = UserDefaults.standard.value(forKey: "cusConfigs") as? [AFParam] else {
                return []
            }
            let configs = jsons.kj.modelArray(ServerConfig.self)
            return configs.compactMap{ $0 }
        }
    }
    
    static var selectedServerName: String? {
        set {
            Self.standard.setValue(newValue, forKey: "kSelectedServiceKey")
        }
        
        get {
            Self.standard.value(forKey: "kSelectedServiceKey") as? String
        }
    }
}


fileprivate class NewCustomerServerView: MKPopParentView {
    var textField: MKTextField!
    var localBtn: UIButton!
    var aesBtn: UIButton!
    
    override func setDefault() {
        super.setDefault()
        hideOnTapBackground = false
        corner = .allCorners
        layoutWhenKeyBoardShow = true
        cornerRadii = 10
    }
    
    override func appendSubviews() {
        super.appendSubviews()
        
        let label = UILabel.init(superView: contentView, text: "添加新环境", textColor: .textColorBlack, font: .medium(15))
        label.snp.makeConstraints { make in
            make.left.top.equalTo(20)
        }
        
        textField = MKTextField.init(superView: contentView, textColor: .textColorBlack, placeHolder: "请输入地址", font: .regular(16), aligment: .left, keyboardType: .decimalPad)
        textField.addBlank(width: 15)
        textField.snp.makeConstraints { make in
            make.left.equalTo(label)
            make.top.equalTo(label.snp.bottom).offset(20)
            make.height.equalTo(40)
            make.right.equalTo(-20)
        }
        
        let separator = UIView.init(super: contentView, backgroundColor: .background)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(textField)
            make.height.equalTo(1)
        }
        
        localBtn = .init(superView: contentView, title: " 本地化", titleColor: .textColorGray, normalImage: .checkSquare, selectedImage: .checkSquareFill, font: .regular(14))
        localBtn.snp.makeConstraints { make in
            make.left.equalTo(label)
            make.top.equalTo(textField.snp.bottom).offset(20)
        }
        localBtn.setClosure { sender in
            sender.isSelected.toggle()
        }
        
        aesBtn = .init(superView: contentView, title: " 加密", titleColor: .textColorGray, normalImage: .checkSquare, selectedImage: .checkSquareFill, font: .regular(14))
        aesBtn.snp.makeConstraints { make in
            make.left.equalTo(localBtn.snp.right).offset(40)
            make.top.equalTo(textField.snp.bottom).offset(20)
        }
        aesBtn.setClosure { sender in
            sender.isSelected.toggle()
        }
        
        let confirmBtn = UIButton.init(superView: contentView, title: "确定", titleColor: .theme, font: .medium(15))
        confirmBtn.snp.makeConstraints { make in
            make.right.bottom.equalTo(-20)
            make.top.equalTo(localBtn.snp.bottom).offset(20)
            make.width.equalTo(50)
        }
        confirmBtn.setClosure { [weak self] sender in
            self?.addNewConfig()
        }
        
        let cancelBtn = UIButton.init(superView: contentView, title: "取消", titleColor: .textColorGray, font: .regular(15))
        cancelBtn.snp.makeConstraints { make in
            make.width.centerY.equalTo(confirmBtn)
            make.right.equalTo(confirmBtn.snp.left).offset(-10)
        }
        cancelBtn.setClosure { [weak self] sender in
            self?.hide()
        }
    }
    
    private func addNewConfig() {
        guard var ip = textField.text, ip.isIP else {
            return HUD.flash(warning: "IP错误", onView: self)
        }
        
        if !ip.hasPrefix("http") {
            ip = "http://"+ip
        }
        
        var port = "8090"
        if localBtn.isSelected {
            port = "15081"
        }
        
        ip = "\(ip):\(port)/"
        
        var config = ServerConfig.init(type: .custom)
        config.urlName = ip
        config.baseUrl = ip
        config.encryptEnable = aesBtn.isSelected
        config.testAesKey = true
        ChooseServer.add(server: config)
        
        hide()
    }
}

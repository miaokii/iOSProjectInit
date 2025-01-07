//
//  WebviewController.swift
//  MuYunControl
//
//  Created by miaokii on 2023/4/3.
//
//

import UIKit
@preconcurrency import WebKit

fileprivate class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

fileprivate class WebView: WKWebView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        reload()
    }
}

class MKWebviewController: MKBaseViewController {
    var url: URL!
    var titleString: String!
    var allowsBackForwardNavigationGestures = true
    
    var jsCallMessages = [(String, Selector)]()
    
    private var webView: WKWebView!
    private var weakMessageHander: WeakScriptMessageHandler!
    private let progressView = UIProgressView()
    
    lazy private var backItem: UIBarButtonItem! = {
        .init(image: MKBridge.UI.navBackImage, style: .done, target: self, action: #selector(backAction))
    }()
    
    lazy private var closeItem: UIBarButtonItem! = {
        .init(image: MKBridge.UI.navCloseImage, style: .done, target: self, action: #selector(popAction))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = titleString
        
        let config = WKWebViewConfiguration.init()
        let userContent = WKUserContentController.init()
        config.userContentController = userContent
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        if #available(iOS 10.0, *) {
            config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        }
        
        weakMessageHander = WeakScriptMessageHandler.init(delegate: self)
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.customUserAgent = "iOS"
        
        // 允许返回
        webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        // 加载进度
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        // 标题
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }

        progressView.tintColor = .theme
        view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(webView)
            make.height.equalTo(2)
        }
        
        setJSCallMessages()
        
        for (name, _) in jsCallMessages {
            webView.configuration.userContentController.add(weakMessageHander, name: name)
        }
        
        loadUrl()
    }
    
    func setJSCallMessages() {
        jsCallMessages = []
        // ("skip", #selector(skip(path:)))
    }
    
    func loadUrl() {
        guard url != nil else { return }
        webView.load(URLRequest(url: url))
    }
    
    @objc private func backAction() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            popAction()
        }
    }
    
    @objc private func popAction() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        let types = [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeMemoryCache]
        let websiteDataTypes = Set(types)
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
        }
    }
    
    private func updateProgess() {
        progressView.alpha = 1
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        if webView.estimatedProgress >= 1 {
            UIView.animate(withDuration: 0.1, animations: {
                self.progressView.alpha = 0
            }) { (_) in
                self.progressView.setProgress(0, animated: true)
            }
        }
    }
    
    /// 执行js
    func jsCallBack(string: String) {
        self.webView.evaluateJavaScript(string) { (result, error) in
            if let error = error {
                print(error)
            } else {
                print("\(string) 执行成功")
            }
        }
    }
}

extension MKWebviewController: WKNavigationDelegate {
 
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        let urlString = url.absoluteString
        print(urlString)
        
        /*
        if urlString.hasPrefix("alipay://") || urlString.hasPrefix("alipays://"), let decode = urlString.removingPercentEncoding, let para = decode.components(separatedBy: "?").last, var dic = try? JSONSerialization.jsonObject(with: para.data(using: .utf8)!, options: .init(rawValue: 0)) as? [String : Any] {
            dic["fromAppUrlScheme"] = "alipay2018120762466837c"
            let newUrlString = "\(decode.components(separatedBy: "?").first!)?\(dic.toString() ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            UIApplication.shared.open(URL(string: newUrlString)!, options: [:], completionHandler: nil)
            decisionHandler(.allow)
        } else if urlString.hasPrefix("https://mclient.alipay.com/h5Continue.htm") {
            if UIApplication.shared.canOpenURL(URL(string: "alipay://")!) {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else if urlString.hasPrefix("https://wx.tenpay.com/"), let components1 = URLComponents(string: URLManger.share.baseUrl.absoluteString), navigationAction.request.allHTTPHeaderFields?["Referer"]?.hasPrefix(components1.host ?? "") ?? false {
            var requset = navigationAction.request
            decisionHandler(.cancel)
            requset.setValue(URLManger.share.baseUrl.absoluteString, forHTTPHeaderField: "Referer")
            var components = URLComponents(string: urlString)!
            var items = components.queryItems
            let redirect_url = items?.filter({ $0.name == "redirect_url" }).first?.value
            items = items?.filter({ $0.name != "redirect_url" })
            items?.append(URLQueryItem(name: "redirect_url", value: "\(components1.url?.absoluteString ?? "")?redirect_url=\(redirect_url ?? "")"))
            components.queryItems = items
            requset.url = components.url
            webView.load(requset)
        } else if urlString.hasPrefix("weixin://") {
            decisionHandler(.cancel)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if urlString.hasPrefix("https://itunes.apple.com/") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else if let components = URLComponents(string: URLManger.appointmentURL), urlString.hasPrefix("\(components.host ?? "")://") {
            decisionHandler(.cancel)
            guard let newUrl = URL(string: urlString.replacingOccurrences(of: "\(components.host ?? "")://?redirect_url=", with: "")) else { return }
            webView.load(URLRequest(url: newUrl))
        } else if urlString.hasPrefix("iosamap://") {
            if (UIApplication.shared.canOpenURL(url)) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
        */
        decisionHandler(.allow)
    }
    
    /// 页面加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.title = webView.title
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
}

extension MKWebviewController: WKUIDelegate {
    /// 输入框
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.font = .systemFont(ofSize: 14)
            textField.textColor = .textColorBlack
            textField.placeholder = defaultText
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            completionHandler(alert.textFields?.first?.text)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            completionHandler(nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    /// 确认框
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    /// 弹出框
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension MKWebviewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let name = message.name
        
        guard let handle = jsCallMessages.first(where: { $0.0 == name }) else {return}
        
        let selector = handle.1
        
        if self.responds(to: selector) {
            self.perform(selector, with: nil, afterDelay: 0)
        }
    }
}

extension MKWebviewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            title = webView.title
        }
        else if keyPath == "estimatedProgress" {
            updateProgess()
        }
        else if keyPath == "canGoBack" {
            if webView.canGoBack {
                navigationItem.leftBarButtonItems = [backItem, closeItem]
            } else {
                navigationItem.leftBarButtonItems = [backItem]
            }
        }
    }
}

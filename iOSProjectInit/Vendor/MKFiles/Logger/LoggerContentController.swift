//
//  LoggerContentController.swift
//  SwiftLib
//
//  Created by miaokii on 2023/4/24.
//

import UIKit
import CocoaLumberjack

class LoggerContentController: MKBaseViewController {
    
    var logModel: DDLogMessage?
    var logPath: String?
    private var textView: UITextView!
    
    static func parsingUnicode(string: String) -> String {
        var coverted = string.replacingOccurrences(of: "\\U", with: "\\u", options: .caseInsensitive)
        if let covertedstr = coverted.applyingTransform(.init("Any-Hex/Java"), reverse: false) {
            coverted = covertedstr
        }
        return coverted
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let copy = UIBarButtonItem.init(title: "复制", style: .plain, target: self, action: #selector(copyLog))
        
        let export = UIBarButtonItem.init(title: "导出", style: .plain, target: self, action: #selector(exportLog))
        
        navigationItem.rightBarButtonItems = [copy, export]
        
        textView = UITextView.init()
        textView.isEditable = false
        textView.textColor = .black
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(-safeAreaBottom)
        }
        
        if let logModel = logModel {
            DispatchQueue.global().async {
                let time = logModel.timestamp.string(format: "HH:mm:ss")
                var message = logModel.message
                
                message.append("\n\n触发时间：\(time)\n文件名称：\(logModel.fileName)\n方法名称：\(logModel.function ?? "")\n所在行：\(logModel.line)")
                
                DispatchQueue.main.async {
                    self.title = time
                    self.textView.text = message
                }
            }
        }
        
        if let path = logPath {
            textView.text = try? String.init(contentsOfFile: path) 
        }
    }
    
    @objc private func copyLog() {
        UIPasteboard.general.string = textView.text
        HUD.flash(success: "已复制")
    }
    
    @objc private func exportLog() {
        guard let text = self.textView.text, text.count > 0 else {
            return
        }
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(vc, animated: true)
    }
}

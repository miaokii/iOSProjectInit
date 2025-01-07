//
//  FrontRequest.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/12/27.
//

import Foundation

/// 前置请求
class FrontRequest {
    
    static var isComplete = false
    
    static func requestAll(completion: @escaping ()->Void) {
        isComplete = false
        
        let group = DispatchGroup()
        var canLogin = true
        var errorMsg = ""
        
        let errorCall = { msg in
            if errorMsg.notEmpty || !canLogin {
                errorMsg = msg
            }
        }
//        
//        group.enter()
//        SaaSAppManager.requestApplicationList { msg in
//            defer {
//                group.leave()
//            }
//            if let msg = msg {
//                canLogin = false
//                errorCall(msg)
//            }
//        }
        
        HUD.loading()
        group.notify(queue: .main) {
            if errorMsg.notEmpty {
                HUD.flash(warning: errorMsg)
            } else {
                HUD.hide()
            }
            
//            if !canLogin {
//                Account.login(user: nil)
//            }
            
            isComplete = true
            completion()
        }
    }
}

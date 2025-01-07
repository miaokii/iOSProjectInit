//
//  AccountManager.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/10/27.
//

import Foundation
import KakaJSON

/// 账号登录管理
struct Account {
    
    /// 登录token
    @CacheStore(key: .kToken, defaultValue: "")
    static var userToken
    
    /// 最后一次登录的账号
    @CacheStore(key: .kLastAccount, defaultValue: "")
    static private(set) var lastUserAccount
    /// 最后一次登录的账号
    @CacheStore(key: .kLastPhone, defaultValue: "")
    static private(set) var lastUserPhone
    
    /// 是否是第一次登录
    @CacheStore(key: .kIsFirstLaunch, defaultValue: true)
    static var isFirstLaunch
    
    /// 是否为验证码登录
    @CacheStore(key: .kIsCodeLogin, defaultValue: true)
    static var isCodeLogin
    
    /// 是否有多个租户
    @CacheStore(key: .kManyTenant, defaultValue: false)
    static var isManyTenant
    
    /// 是否登陆
    static var isLogin: Bool {
        return shared.user != nil
    }
    
    static var userId: String {
        shared.user?.id ?? ""
    }
    
    /// 账号信息
    static var user: User? {
        shared.user
    }
    
    /// 登录信息缓存，model缓存的是对应的json
    @CacheStore(key: .kUserJson, defaultValue: [:])
    private static var userJson: AFParam
    
    private static var shared = Account()
    
    /// 登录信息
    private var user: User? {
        didSet {
            if let user = user {
                if Account.isCodeLogin {
                    Self.lastUserPhone = user.mobile
                } else {
                    Self.lastUserAccount = user.username
                }
            }
        }
    }
    
    /// 登录成功
    /// - Parameter user: 用户数据
    static func login(user: User?) {
        if let jsonDic = user?.kj.JSONObject() {
            shared.user = user
            userJson = jsonDic
        } else {
            shared.user = nil
            _userToken.remove()
            _userJson.remove()
        }
    }
    
    static func logout() {
        login(user: nil)
        kAppDelegate.logoutHandle()
    }
    
    init() {
        if !Self.userJson.isEmpty {
            user = model(from: Self.userJson, User.self)
        }
    }
    
    private static func refresh(user: User) {
        shared.user = user
        userJson = user.kj.JSONObject()
    }
    
    /// 刷新用户信息
    /// - Parameter complete: 回调
    static func refreshUser(complete: ((Bool) -> Void)? = nil) {
//        AF.request(path: .currentUserInfo, model: User.self) { response in
//            guard let user = try? response.get().data else {
//                complete?(false)
//                return
//            }
//            refresh(user: user)
//            postNotification(name: .refreshUserInfo)
//            complete?(true)
//        }
    }
}

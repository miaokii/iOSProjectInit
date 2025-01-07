//
//  AF.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/12/18.
//

import Foundation
import Alamofire
import KakaJSON

typealias AFPath = String
typealias Model = Convertible
/// 参数定义
typealias AFParam = [String: Any]

/// 请求类型
enum AFType {
    case get
    case postForm
    case postJSON
    case postGet
    case delete
    case upload(files:[(String, Any)])
    
    /// 请求编码
    var encoding: ParameterEncoding {
        switch self {
        case .postJSON, .delete:        return JSONEncoding.default
        case .postGet:                  return URLEncoding.queryString
        default:                        return URLEncoding.init(boolEncoding: .literal)
        }
    }
    
    /// 请求方法
    var method: HTTPMethod {
        switch self {
        case .get:      return .get
        case .delete:   return .delete
        default:        return .post
        }
    }
}

class AF {
    
    private static let shared = AF()
    private var sessionManager: Alamofire.Session!
    /// 请求集合
    private var requests = [Request]()
    
    deinit {
        requests.forEach({ (req) in
            if !req.isCancelled { req.cancel() }
        })
    }
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        sessionManager = Alamofire.Session(configuration: config)
    }
    
    /// 请求完整地址，baseurl+path
    private func fullPath(_ path: String) -> String {
        var url = URL.init(string: ChooseServer.currentServer.baseUrl)
        url?.appendPathComponent(path, conformingTo: .url)
        return url?.absoluteString ?? path
    }
    
    /// 对象请求方法，对象释放时，请求会取消
    /// - Parameters:
    ///   - type: 请求类型
    ///   - path: 请求路径
    ///   - param: 参数
    ///   - model: model类型
    ///   - progressHandle: 如果是上传文件，这里可以获取进度
    ///   - completeHandle: 请求结果回调
    func request<ModelType: Model>(type: AFType = .postForm, path: AFPath, param: AFParam = [:], header: AFParam = [:], model: ModelType.Type = EmptyModel.self, queue: DispatchQueue? = nil, progressHandle: ((Progress) -> Void)? = nil, completeHandle: @escaping (Result<AFResult<ModelType>, Error>)->Void) {
        
        let requestModifier: Session.RequestModifier = { [weak self] request in
            self?.modifierRequest(&request, type: type, param: param, header: header)
        }
        
        var dataReqeust: DataRequest
        if case let .upload(files) = type, files.notEmpty {
            dataReqeust = sessionManager.upload(multipartFormData: { multipartFormData in
                files.forEach { file in
                    // 文件路径
                    if let filePath = file.1 as? String {
                        let fileUrl = URL.init(fileURLWithPath: filePath)
                        multipartFormData.append(fileUrl, withName: "file")
                    } 
                    // 文件data
                    else if let fileData = file.1 as? Data {
                        multipartFormData.append(fileData, withName: "file", fileName: file.0)
                    }
                }
            }, to: fullPath(.uploadFile), requestModifier: requestModifier)
            
            if let progressHandle = progressHandle {
                dataReqeust.uploadProgress(closure: progressHandle)
            }
        } else {
            dataReqeust = sessionManager.request(fullPath(path), method: type.method, parameters: param, encoding: type.encoding, requestModifier: requestModifier)
        }
        
        dataReqeust.responseData(queue: queue ?? .main, completionHandler: { response in
            let result = response.map(AFResult<ModelType>.self)
            guard Self.loginValid(result) else {
                return
            }
            completeHandle(result)
        })
        requests.append(dataReqeust)
    }
    
    /// 类请求方法
    /// - Parameters:
    ///   - type: 请求类型
    ///   - path: 请求路径
    ///   - param: 参数
    ///   - model: model类型
    ///   - progressHandle: 如果是上传文件，这里可以获取进度
    ///   - completeHandle: 请求结果回调
    static func request<ModelType: Model>(type: AFType = .postForm, path: AFPath, param: AFParam = [:], header: AFParam = [:], model: ModelType.Type = EmptyModel.self, queue: DispatchQueue? = nil, progressHandle: ((Progress) -> Void)? = nil, completeHandle: @escaping (Result<AFResult<ModelType>, Error>)->Void) {
        shared.request(type: type, path: path, param: param, header: header, model: model, queue: queue, progressHandle: progressHandle, completeHandle: completeHandle)
    }
    
    /// 注入请求头，或其他
    private func modifierRequest(_ request: inout URLRequest, type: AFType, param: AFParam, header: AFParam) {
        /// 添加header
        guard Account.userToken.notEmpty else {
            return
        }
        request.headers.add(.authorization(bearerToken: Account.userToken))
        header.forEach { key, value in
            request.headers.add(name: key, value: string(value: value))
        }
        request.headers.add(name: "client", value: "iOS")
        request.headers.add(name: "version", value: bundleVersion!)
    }
    
    /// 五秒内的登录失效只提示一次，而且只在非登录页面提示
    static let loginExpiredHintSecond: TimeInterval = 5
    /// 提示登录失效的时间
    static var loginExpiredHintTime: TimeInterval = 0
    
    /// 登录是否有效
    private static func loginValid<DataModel: Model>(_ result: Result<AFResult<DataModel>, Error>) -> Bool {
        /// 请求失败的逻辑
        guard let successResut = try? result.get() else {
            return true
        }
        /// token失效
        guard successResut.REQ_LOGOUT else {
            return true
        }
        
        let msg = (try? result.get().msg) ?? "登录过期，请重新登录"
        /// 提示失效
        HUD.flash(warning: msg) {
            /// 退出到登录页面
            let currentTime = Date().timeIntervalSince1970
            if loginExpiredHintTime + loginExpiredHintSecond < currentTime {
                loginExpiredHintTime = currentTime
                Account.logout()
            }
        }
        
        return false
    }
}

import KakaJSON
/// 转换model
fileprivate extension AFDataResponse where Success == Data {
    func map<M: Model>(_ type: M.Type) -> Result<M, Error> {

        guard let data = try? result.get() else {
            logRequest()
            return .failure(error!)
        }
        
        logRequest()
        
        if let model = model(from: data, type: M.self) {
            return .success(model as! M)
        } else {
            return .failure(NSError.init(domain: "domian", code: -1, userInfo: ["msg": "映射模型失败"]))
        }
    }
}

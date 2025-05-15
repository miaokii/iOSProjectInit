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
    // 请求为post，参数编码到url中
    case postGet
    case delete
    case upload(files:[(name: String, value: Any)])
    
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
    private var requests = [UUID: Request]()
    
    deinit {
        requests.forEach({ (key, req) in
            if !req.isCancelled {
                req.cancel()
            }
        })
    }
    
    static func remove(uuid: UUID) {
        if let requst = shared.requests[uuid] {
            if !requst.isCancelled {
                requst.cancel()
            }
            shared.requests.removeValue(forKey: uuid)
        }
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
    @discardableResult
    func request<ModelType: Model>(type: AFType = .postForm, path: AFPath, param: AFParam = [:], header: AFParam = [:], model: ModelType.Type = EmptyModel.self, queue: DispatchQueue? = nil, progressHandle: ((Progress) -> Void)? = nil, completeHandle: @escaping (Result<AFResult<ModelType>, Error>)->Void) -> UUID {
        
        let requestModifier: Session.RequestModifier = { [weak self] request in
            self?.modifierRequest(&request, type: type, param: param, header: header)
        }
        
        var dataReqeust: DataRequest
        if case let .upload(files) = type, files.notEmpty {
            let uploadRequest = sessionManager.upload(multipartFormData: { multipartFormData in
                files.forEach { file in
                    // 文件路径
                    if let filePath = file.value as? String {
                        let fileUrl = URL.init(fileURLWithPath: filePath)
                        multipartFormData.append(fileUrl, withName: file.name)
                    }
                    // 文件data
                    else if let fileData = file.value as? Data {
                        multipartFormData.append(fileData, withName: file.name, fileName: file.name)
                    }
                }
                param.forEach { (key, value) in
                    if let data = try? JSONSerialization.data(withJSONObject: value) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }, to: fullPath(path), requestModifier: requestModifier)
            
            if let progressHandle = progressHandle {
                uploadRequest.uploadProgress(closure: progressHandle)
            }
            dataReqeust = uploadRequest
        } else {
            dataReqeust = sessionManager.request(fullPath(path), method: type.method, parameters: param, encoding: type.encoding, requestModifier: requestModifier)
        }
        
        let uuid = dataReqeust.id
        dataReqeust.responseData(queue: queue ?? .main, completionHandler: { response in
            Self.remove(uuid: uuid)
            let result = response.map(AFResult<ModelType>.self)
            // 手动取消的请求
            if case let .failure(error) = result,
               let afError = error as? AFError {
                if afError.isExplicitlyCancelledError {
                    return
                }
            }
            guard Self.loginValid(result) else {
                return
            }
            completeHandle(result)
        })
        requests[uuid] = dataReqeust
        return uuid
    }
    
    /// 类请求方法
    /// - Parameters:
    ///   - type: 请求类型
    ///   - path: 请求路径
    ///   - param: 参数
    ///   - model: model类型
    ///   - progressHandle: 如果是上传文件，这里可以获取进度
    ///   - completeHandle: 请求结果回调
    @discardableResult
    static func request<ModelType: Model>(type: AFType = .postForm, path: AFPath, param: AFParam = [:], header: AFParam = [:], model: ModelType.Type = EmptyModel.self, queue: DispatchQueue? = nil, progressHandle: ((Progress) -> Void)? = nil, completeHandle: @escaping (Result<AFResult<ModelType>, Error>)->Void) -> UUID {
        return shared.request(type: type, path: path, param: param, header: header, model: model, queue: queue, progressHandle: progressHandle, completeHandle: completeHandle)
    }
    
    /// 注入请求头，或其他
    private func modifierRequest(_ request: inout URLRequest, type: AFType, param: AFParam, header: AFParam) {
        request.headers.add(name: "client", value: "iOS")
        request.headers.add(name: "version", value: bundleVersion!)
        /// 添加header
        guard Account.userToken.notEmpty else {
            return
        }
        request.headers.add(name: "token", value: Account.userToken)
        //request.headers.add(.authorization(bearerToken: Account.userToken))
        header.forEach { key, value in
            request.headers.add(name: key, value: string(value: value))
        }
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

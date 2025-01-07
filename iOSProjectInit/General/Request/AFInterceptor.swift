//
//  AFInterceptor.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/12/18.
//

import Alamofire

/// https://codeleading.com/article/16295955422/
/// 
/// 拦截器
final class AFInterceptor: RequestInterceptor {
    
    /// 适配器，发起请求前，做一些预处理
    /// 重定向、添加header、阻拦请求等
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        /// 添加header
        var headers: HTTPHeaders = .init()
        if Account.userToken.notEmpty {
            headers.add(.authorization(bearerToken: Account.userToken))
        }
        
        request.headers = headers
        completion(.success(request))
    }
    
    /// 重试
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}


/*
guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
    completion(.doNotRetry)
    return
}
       
// 确保只重试一次，否则就无限重试下去了
guard request.retryCount == 0 else { return completion(.doNotRetry) }

// 如果是特定 URL 并且状态码是 401
if let urlString = request.firstRequest?.url?.absoluteString, urlString.hasSuffix(.oauthToken) {
   // 重新获取 token
//
//           gatewayAuthService?.refreshJWT(createURLRequest: createURLRequestFunc, complete: {[weak self] accessToken in
//               if !accessToken.isEmpty {
//                   // 保存新的 token，重试的时候在 adapter 中使用
//                   self?.accessToken = accessToken
//                   // 重试
//                   completion(.retry)
//               } else {
//                   completion(.doNotRetry)
//               }
//           })
    completion(.retry)
} else {
   completion(.doNotRetry)
}
*/

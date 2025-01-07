//
//  AFLog.swift
//  RXCSaaS
//
//  Created by yoctech on 2023/12/18.
//

import UIKit
import Alamofire


extension AFDataResponse where Success == Data {
    
    func logRequest() {
#if DEBUG
        print("\n👇👇👇")
        let items = outputItems()
        LogInfo(items.joined(separator: "\n"))
#endif
    }
    
    private var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
    
    private func format(identifier: String, message: String) -> String {
        return "\(identifier)：\(message)"
    }
    
    func outputItems() -> [String] {
        var output = [String]()
        
        guard let request = request else {
            return [format(identifier: "Error", message: "\(result)")]
        }
        
        let method = request.method == .get  ? "GET" : "POST"
        let code = response?.statusCode ?? 0
        
        output += [format(identifier: "Request", message: "\(method) \(code) \(request.url?.path ?? request.description)")]
        
        output += [format(identifier: "URL", message: request.description)]
        
        if let headers = request.allHTTPHeaderFields {
            output += [format(identifier: "Headers", message: prettyPrinted(json: headers))]
        }
        
        if let body = request.httpBody {
            output += [format(identifier: "Body", message: prettyPrinted(json: body))]
        }
        
        if let bodyStram = request.httpBodyStream {
            output += [format(identifier: "Body Stream", message: bodyStram.description)]
        }
        
        if let error = error {
            output += [format(identifier: "Response Error", message: "\(error.localizedDescription)")]
        } else if let data = try? result.get() {
            output += [format(identifier: "Response", message: prettyPrinted(json: data))]
        }

        return output
    }
    
    private func prettyPrinted(json: Any) -> String {
        if (json is AFParam || json is [Any]),
           let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let dataString = String.init(data: data, encoding: .utf8) {
            return dataString
        } else if let jsonData = json as? Data, var jsonString = String.init(data: jsonData, encoding: .utf8) {
            if let removingPercent = jsonString.removingPercentEncoding {
                jsonString = removingPercent
            }
//            if jsonString.contains("&") || jsonString.contains("=") {
//                var d = URLComponents()
//                d.query = jsonString
//                if let jsonDic = d.queryItems?.reduce(into: AFParam(), { partialResult, item in
//                    partialResult[item.name] = item.value ?? ""
//                }) {
//                    return prettyPrinted(json: jsonDic)
//                } else {
//                    return jsonString
//                }
//            } else {
//                return jsonString
//            }
            return jsonString
        } else if let paramString = json as? String {
            return paramString
        }
        return "\(json)"
    }
}

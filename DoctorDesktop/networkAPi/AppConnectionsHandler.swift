//
//  AppConnectionsHandler.swift
//  DoctorDesktop
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyBeaver
import MOLH

public enum ResponseStatus {
    case success
    case error
}

class AppConnectionsHandler {

    // MARK: - Connectivity

    static func checkConnection() -> Bool {
        let manager = Alamofire.NetworkReachabilityManager(host: "www.google.com")!
        return manager.isReachable
    }

    // MARK: - URL helpers

    static func setParamsInUrl(_ params: [String: Any]) -> String {
        var result = "?"
        for (key, value) in params {
            result += "\(key)=\(value)&"
        }
        result.removeLast()
        return result
    }

    // MARK: - Request builders

    private static func buildHeaders(_ param: [String: Any]?) -> HTTPHeaders? {
        guard let param = param else { return nil }
        let headers = param.map { HTTPHeader(name: $0.key, value: "\($0.value)") }
        return HTTPHeaders(headers)
    }

    private static func buildRequest(url: String, parameters: Any, headers: [String: String]?) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            SwiftyBeaver.error("Failed to serialize request body: \(error)")
        }
        return request
    }

    // MARK: - Network calls

    static func get<T: Decodable>(url: String,
                                  params: [String: Any]? = [:],
                                  headers: [String: String]? = nil,
                                  type: T.Type,
                                  flag: Int = 0,
                                  completion: ((ResponseStatus, Decodable?, String?) -> Void)?) {
        guard checkConnection() else { return }

        var fullURL = url + setParamsInUrl(params ?? [:])
        guard let safeURL = fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        APILogger.logRequest(method: "GET", url: safeURL, params: params)
        let start = Date()

        AF.request(safeURL, method: .get, encoding: JSONEncoding.default, headers: buildHeaders(headers))
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                if let error = response.error {
                    APILogger.logFailure(method: "GET", url: safeURL, error: error.localizedDescription, duration: duration)
                } else {
                    APILogger.logResponse(method: "GET", url: safeURL, statusCode: code, data: response.data, duration: duration)
                }
                let result = handlerResponse(response: response, type: T.self)
                completion?(result.0, result.1, result.0 == .success ? "\(flag)" : result.2)
            }
    }

    static func post<T: Decodable>(url: String,
                                   params: [String: Any]? = nil,
                                   headers: [String: String]? = nil,
                                   type: T.Type,
                                   flag: Int = 0,
                                   completion: ((ResponseStatus, Decodable?, String?) -> Void)?) {
        guard checkConnection() else { return }
        APILogger.logRequest(method: "POST", url: url, params: params)
        let start = Date()

        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: buildHeaders(headers))
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                if let error = response.error {
                    APILogger.logFailure(method: "POST", url: url, error: error.localizedDescription, duration: duration)
                } else {
                    APILogger.logResponse(method: "POST", url: url, statusCode: code, data: response.data, duration: duration)
                }
                let result = handlerResponse(response: response, type: T.self)
                completion?(result.0, result.1, result.0 == .success ? "\(flag)" : result.2)
            }
    }

    static func raw<T: Decodable>(url: String,
                                  params: Any,
                                  headers: [String: String]? = nil,
                                  type: T.Type,
                                  flag: Int = 0,
                                  completion: ((ResponseStatus, Decodable?, String?) -> Void)?) {
        guard checkConnection() else { return }
        APILogger.logRequest(method: "POST", url: url, params: params)
        let start = Date()

        let request = buildRequest(url: url, parameters: params, headers: headers)
        AF.request(request).responseJSON { response in
            let duration = Date().timeIntervalSince(start)
            let code = response.response?.statusCode ?? 0
            if let error = response.error {
                APILogger.logFailure(method: "POST", url: url, error: error.localizedDescription, duration: duration)
            } else {
                APILogger.logResponse(method: "POST", url: url, statusCode: code, data: response.data, duration: duration)
            }
            let result = handlerResponse(response: response, type: T.self)
            completion?(result.0, result.1, result.0 == .success ? "\(flag)" : result.2)
        }
    }

    // MARK: - Cancel requests

    static func cancelRequests(completion: (() -> Void)? = nil) {
        AF.session.delegateQueue.cancelAllOperations()
        completion?()
    }

    static func stopAPICall() {
        AF.session.delegateQueue.cancelAllOperations()
    }

    // MARK: - Response handler

    private static func handlerResponse<T: Decodable>(response: AFDataResponse<Any>,
                                                      type: T.Type) -> (ResponseStatus, Decodable?, String?) {
        switch response.result {
        case .failure:
            return (.error, nil, "errorInConnection")

        case .success:
            guard let value = response.value else {
                return (.error, nil, "errorInConnection")
            }

            let statusCode = response.response?.statusCode ?? 0

            switch statusCode {
            case 200:
                if let dict = value as? [String: Any] {
                    let dic = dict
                    guard dic["Success"] as? Bool == true else {
                        let msg = MOLHLanguage.isArabic()
                            ? dic["ArabicMessage"] as? String ?? "errorInConnection"
                            : dic["EnglishMessage"] as? String ?? "errorInConnection"
                        return (.error, nil, msg)
                    }
                    let handled = handleJSON(dicc: dic)
                    return decode(T.self, from: handled)

                } else if let array = value as? [[String: Any]] {
                    let handled = handleJSONArray(dic: array)
                    return decode(T.self, from: handled)

                } else {
                    return (.error, nil, "errorInConnection")
                }

            case 401:
                let msg = (value as? [String: Any])?["Message"] as? String ?? "errorInConnection"
                return (.error, nil, msg)

            default:
                let msg = (value as? [String: Any])?["Message"] as? String ?? "errorInConnection"
                return (.error, nil, msg)
            }
        }
    }

    private static func decode<T: Decodable>(_ type: T.Type, from object: Any) -> (ResponseStatus, Decodable?, String?) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object)
            let model = try JSONDecoder().decode(T.self, from: jsonData)
            return (.success, model, nil)
        } catch {
            SwiftyBeaver.error("⚠️ DECODE \(T.self)\n       Error  │ \(error)")
            return (.error, nil, "Error in parsing response")
        }
    }

    // MARK: - JSON normalisation (converts numbers/bools to Strings for the decoder)

    static func handleJSON(dicc: [String: Any]) -> [String: Any] {
        var dic = dicc
        for (key, value) in dic {
            switch value {
            case is NSNull:
                dic.removeValue(forKey: key)
            case let v as Int:
                dic[key] = String(v)
            case let v as Double:
                dic[key] = String(v)
            case let v as Bool:
                dic[key] = String(v)
            case let v as [String: Any]:
                dic[key] = handleJSON(dicc: v)
            case let v as [[String: Any]]:
                dic[key] = v.map { handleJSON(dicc: $0) }
            case let v as [Int]:
                dic[key] = v.map { String($0) }
            case let v as [Double]:
                dic[key] = v.map { String($0) }
            case let v as [Bool]:
                dic[key] = v.map { String($0) }
            default:
                break
            }
        }
        return dic
    }

    static func handleJSONArray(dic: [[String: Any]]) -> [[String: Any]] {
        return dic.map { handleJSON(dicc: $0) }
    }
}

// MARK: - APILogger
// Centralised, structured API logging used by all network layers.

struct APILogger {

    static func logRequest(method: String, url: String, params: Any? = nil) {
        let path = shortPath(url)
        var message = "🌐 \(method.uppercased())  \(path)"
        if let params = params, !isEmpty(params) {
            message += "\n       Params │ \(formatted(params))"
        }
        SwiftyBeaver.debug(message)
    }

    static func logResponse(method: String, url: String, statusCode: Int, data: Data?, duration: TimeInterval) {
        let path = shortPath(url)
        let time = String(format: "%.2fs", duration)
        var message = "✅ \(statusCode)  \(path)  (\(time))"
        if let data = data, !data.isEmpty {
            message += "\n       Body   │ \(prettyData(data))"
        }
        SwiftyBeaver.debug(message)
    }

    static func logFailure(method: String, url: String, error: String, duration: TimeInterval) {
        let path = shortPath(url)
        let time = String(format: "%.2fs", duration)
        SwiftyBeaver.error("❌ FAILED  \(path)  (\(time))\n       Error  │ \(error)")
    }

    static func logHTTPError(method: String, url: String, statusCode: Int, message: String, duration: TimeInterval) {
        let path = shortPath(url)
        let time = String(format: "%.2fs", duration)
        SwiftyBeaver.error("❌ \(statusCode)  \(path)  (\(time))\n       Error  │ \(message)")
    }

    static func logDecodeError(url: String, error: Error) {
        let path = shortPath(url)
        SwiftyBeaver.error("⚠️ DECODE  \(path)\n       Error  │ \(error.localizedDescription)")
    }

    // MARK: Private helpers

    private static func shortPath(_ url: String) -> String {
        guard let u = URL(string: url) else { return url }
        var path = u.path.isEmpty ? "/" : u.path
        if let q = u.query { path += "?\(q)" }
        return path
    }

    private static func isEmpty(_ params: Any) -> Bool {
        if let d = params as? [String: Any]    { return d.isEmpty }
        if let d = params as? [String: String] { return d.isEmpty }
        return false
    }

    private static func formatted(_ params: Any) -> String {
        let sensitive: Set<String> = ["PASSWORD", "password", "pass", "token", "TOKEN"]
        func mask(_ d: [String: Any]) -> [String: Any] {
            var c = d; sensitive.forEach { if c[$0] != nil { c[$0] = "***" } }; return c
        }
        var obj: Any = params
        if let d = params as? [String: Any]    { obj = mask(d) }
        if let d = params as? [String: String] {
            obj = mask(d.mapValues { $0 as Any })
        }
        if let data = try? JSONSerialization.data(withJSONObject: obj, options: [.sortedKeys]),
           let str = String(data: data, encoding: .utf8) { return str }
        return "\(params)"
    }

    private static func prettyData(_ data: Data, cap: Int = 800) -> String {
        if let json = try? JSONSerialization.jsonObject(with: data),
           let compact = try? JSONSerialization.data(withJSONObject: json),
           let str = String(data: compact, encoding: .utf8) {
            return str.count > cap ? String(str.prefix(cap)) + "… [\(data.count)B]" : str
        }
        let raw = String(data: data, encoding: .utf8) ?? "<binary \(data.count)B>"
        return raw.count > cap ? String(raw.prefix(cap)) + "…" : raw
    }
}

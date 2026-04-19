import UIKit
import Alamofire
import SwiftyJSON
import SwiftyBeaver

class WebserviceMananger: NSObject {

    static let sharedInstance = WebserviceMananger()
    private override init() {}

    // MARK: - JSON request (no auth header)

    func makeCall(method: HTTPMethod,
                  url: String,
                  parameters: [String: Any]?,
                  vc: UIViewController? = nil,
                  completionHandler: @escaping (AnyObject?, String?) -> Void) {

        APILogger.logRequest(method: method.rawValue, url: url, params: parameters)
        let start = Date()

        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0

                guard let httpResponse = response.response else {
                    APILogger.logFailure(method: method.rawValue, url: url,
                                        error: "Couldn't connect to server", duration: duration)
                    Utilities.showAlert(messageToDisplay: "Couldn't connect to server")
                    return
                }

                switch httpResponse.statusCode {
                case 500:
                    APILogger.logHTTPError(method: method.rawValue, url: url, statusCode: 500,
                                          message: "Internal Server Error", duration: duration)
                    Utilities.showAlert(messageToDisplay: "Couldn't connect to server")
                    return
                case 404:
                    APILogger.logHTTPError(method: method.rawValue, url: url, statusCode: 404,
                                          message: "Not Found", duration: duration)
                    Utilities.showAlert(messageToDisplay: "Couldn't connect to the server. Please try again.")
                    return
                default:
                    break
                }

                switch response.result {
                case .success(let value):
                    APILogger.logResponse(method: method.rawValue, url: url, statusCode: code,
                                         data: response.data, duration: duration)
                    if let data = value as? [String: AnyObject] {
                        completionHandler(data as AnyObject, nil)
                    } else if let data = value as? [[String: AnyObject]] {
                        completionHandler(data as AnyObject, nil)
                    } else if let string = value as? String {
                        completionHandler(["result": string] as AnyObject, nil)
                    } else {
                        Utilities.showAlert(messageToDisplay: "Unexpected response format")
                    }

                case .failure(let error):
                    APILogger.logFailure(method: method.rawValue, url: url,
                                        error: error.localizedDescription, duration: duration)
                    completionHandler(nil, error.localizedDescription)
                }
            }
    }

    // MARK: - JSON request with custom headers

    func makeCall(method: HTTPMethod,
                  urlString: String,
                  parameters: [String: Any]?,
                  vc: UIViewController,
                  headers: [String: String],
                  completionHandler: @escaping (AnyObject?, String?) -> Void) {

        APILogger.logRequest(method: method.rawValue, url: urlString, params: parameters)
        let start = Date()

        AF.request(urlString,
                   method: method,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: HTTPHeaders(headers))
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                switch response.result {
                case .success(let value):
                    APILogger.logResponse(method: method.rawValue, url: urlString, statusCode: code,
                                         data: response.data, duration: duration)
                    guard let data = value as? [String: AnyObject] else {
                        Utilities.showAlert(messageToDisplay: "Unexpected response format")
                        return
                    }
                    if let key = data["key"] as? Bool, key {
                        completionHandler(value as AnyObject, nil)
                    } else {
                        Utilities.showAlert(messageToDisplay: "API Error \(data.description)")
                    }

                case .failure(let error):
                    APILogger.logFailure(method: method.rawValue, url: urlString,
                                        error: error.localizedDescription, duration: duration)
                    completionHandler(nil, error.localizedDescription)
                }
            }
    }

    // MARK: - Raw-body (text) request

    func makeCallText(method: HTTPMethod,
                      urlString: String,
                      parameters: String,
                      vc: UIViewController,
                      headers: [String: String],
                      completionHandler: @escaping (AnyObject?, NSError?, Int) -> Void) {

        APILogger.logRequest(method: method.rawValue, url: urlString)
        let start = Date()

        AF.request(urlString,
                   method: method,
                   parameters: [:],
                   encoding: parameters,
                   headers: HTTPHeaders(headers))
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let statusCode = response.response?.statusCode ?? 0
                switch response.result {
                case .success(let value):
                    APILogger.logResponse(method: method.rawValue, url: urlString, statusCode: statusCode,
                                         data: response.data, duration: duration)
                    completionHandler(value as AnyObject, nil, statusCode)
                case .failure(let error):
                    APILogger.logFailure(method: method.rawValue, url: urlString,
                                        error: error.localizedDescription, duration: duration)
                    completionHandler(nil, error as NSError, statusCode)
                }
            }
    }
}

// MARK: - String as ParameterEncoding

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

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

        SwiftyBeaver.debug("\(method.rawValue) \(url) params: \(String(describing: parameters))")

        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in

                guard let httpResponse = response.response else {
                    Utilities.showAlert(messageToDisplay: "Couldn't connect to server")
                    return
                }

                switch httpResponse.statusCode {
                case 500:
                    Utilities.showAlert(messageToDisplay: "Couldn't connect to server")
                    return
                case 404:
                    Utilities.showAlert(messageToDisplay: "Couldn't connect to the server. Please try again.")
                    return
                default:
                    break
                }

                switch response.result {
                case .success(let value):
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
                    SwiftyBeaver.error("Request failed: \(error.localizedDescription)")
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

        SwiftyBeaver.debug("\(method.rawValue) \(urlString)")

        AF.request(urlString,
                   method: method,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: HTTPHeaders(headers))
            .responseJSON { response in
                switch response.result {
                case .success(let value):
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
                    SwiftyBeaver.error("Request failed: \(error.localizedDescription)")
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

        SwiftyBeaver.debug("\(method.rawValue) \(urlString)")

        AF.request(urlString,
                   method: method,
                   parameters: [:],
                   encoding: parameters,
                   headers: HTTPHeaders(headers))
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 0
                switch response.result {
                case .success(let value):
                    completionHandler(value as AnyObject, nil, statusCode)
                case .failure(let error):
                    SwiftyBeaver.error("Request failed: \(error.localizedDescription)")
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

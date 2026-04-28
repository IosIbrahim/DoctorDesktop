//
//  apis.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/18/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

class apis: NSObject {

    private struct Session {
        static let shared: Alamofire.Session = {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest  = 30
            config.timeoutIntervalForResource = 30
            return Alamofire.Session(configuration: config)
        }()
    }

    // MARK: - Prescription list

    class func getPrescriptionDate(params: [String: String],
                                   completion: @escaping (_ prescriptions: [precrition]) -> Void) {
        let url = AppURLS.ip + "/MobileApi/api/WorkFlowController/workflow"
        APILogger.logRequest(method: "GET", url: url, params: params)
        let start = Date()

        Session.shared.request(url, parameters: params).responseJSON { response in
            let duration = Date().timeIntervalSince(start)
            let code = response.response?.statusCode ?? 0
            if let error = response.error {
                APILogger.logFailure(method: "GET", url: url, error: error.localizedDescription, duration: duration)
                return
            }
            APILogger.logResponse(method: "GET", url: url, statusCode: code, data: response.data, duration: duration)
            guard let data = response.data else { return }
            if let prescriptions = try? Precritions(data: data, keyPath: "Root") {
                completion(prescriptions)
            }
        }
    }

    // MARK: - Prescription details

    class func getPrescriptiondetails(params: [String: Any],
                                      completion: @escaping (_ result: Welcome) -> Void) {
        let url = AppURLS.ip + "/MobileApi/api/StockController/get_speciality_shortlist"
        APILogger.logRequest(method: "GET", url: url, params: params)
        let start = Date()

        Session.shared.request(url, parameters: params).responseJSON { response in
            let duration = Date().timeIntervalSince(start)
            let code = response.response?.statusCode ?? 0
            if let error = response.error {
                APILogger.logFailure(method: "GET", url: url, error: error.localizedDescription, duration: duration)
                return
            }
            APILogger.logResponse(method: "GET", url: url, statusCode: code, data: response.data, duration: duration)
            guard let data = response.data else { return }
            if let model = try? JSONDecoder().decode(Welcome.self, from: data) {
                completion(model)
            } else {
                APILogger.logDecodeError(url: url, error: NSError(domain: "Welcome decode failed", code: -1, userInfo: nil))
            }
        }
    }

    // MARK: - Drug search

    class func getSearchResultInprecription(params: [String: Any],
                                            completion: @escaping (_ result: searchModel?) -> Void) {
        let url = AppURLS.ip + "/MobileApi/api/StockController/GETDRUGS"
        APILogger.logRequest(method: "GET", url: url, params: params)
        let start = Date()

        Session.shared.request(url, parameters: params).responseJSON { response in
            let duration = Date().timeIntervalSince(start)
            let code = response.response?.statusCode ?? 0
            if let error = response.error {
                APILogger.logFailure(method: "GET", url: url, error: error.localizedDescription, duration: duration)
                completion(nil)
                return
            }
            APILogger.logResponse(method: "GET", url: url, statusCode: code, data: response.data, duration: duration)
            guard let data = response.data else { completion(nil); return }
            let result = try? JSONDecoder().decode(searchModel.self, from: data)
            completion(result)
        }
    }
}

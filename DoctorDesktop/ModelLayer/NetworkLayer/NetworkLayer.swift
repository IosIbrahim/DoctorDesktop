//
//  NetworkLayer.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/9/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyBeaver

typealias DataBlock = ((Data) -> Void)

struct AppURLS {
    static let ip       = "http://41.33.82.156:29804"
    static let mobileApi = "MobileApi/api/"
    static let imageApi  = "primecare/Hospital%20Images/"
}

// MARK: - Protocol

protocol NetworkLayer {
    func login(with params: [String: String], finished: @escaping DataBlock)
    func getPatientsCount(with params: [String: String], finished: @escaping DataBlock)
    func getDoctorPermission(with params: [String: String], finished: @escaping DataBlock)
    func getInpatientUnits(with params: [String: String], finished: @escaping DataBlock)
    func getInpatientPatients(with params: [String: String], finished: @escaping DataBlock)
    func getOutpatientClinics(with params: [String: String], finished: @escaping DataBlock)
    func getOperationPatients(with params: [String: String], finished: @escaping DataBlock)
    func getOutpatientPatients(with params: [String: String], finished: @escaping DataBlock)
    func changePatientStatus(with params: [String: String], finished: @escaping DataBlock)
    func getClinicalPatients(with params: [String: String], finished: @escaping DataBlock)
    func getTemplate(with params: [String: String], finished: @escaping DataBlock)
    func getEmergencyPatients(with params: [String: String], finished: @escaping DataBlock)
    func validateServiceRow(with params: [String: String], finished: @escaping DataBlock)
    func getLabServices(with params: [String: String], finished: @escaping DataBlock)
    func getRadServices(with params: [String: String], finished: @escaping DataBlock)
    func saveOrder(with params: [String: String], orderType: TemplateType, finished: @escaping DataBlock)
    func getPatientHistory(with params: [String: String], finished: @escaping DataBlock)
    func getPatientSummary(with params: [String: String], finished: @escaping DataBlock)
    func getPacksURL(with params: [String: String], finished: @escaping DataBlock)
    func getTriageInfo(with params: [String: String], finished: @escaping DataBlock)
    func loadUcaf(with params: [String: String], finished: @escaping DataBlock)
    func loadSpecialHabits(with params: [String: String], finished: @escaping DataBlock)
    func saveSpecialHabits(body: [String: Any], finished: @escaping DataBlock)
    /// POST /MobileApi/api/MedicalRecordController/saveUcaf — saves vitals + special-needs flags.
    func saveUcaf(body: [String: Any], finished: @escaping DataBlock)
    func getSymptoms(with params: [String: String], finished: @escaping DataBlock)
    func loadFlagImage(with params: [String: String], finished: @escaping DataBlock)
    func getVisitsDetail(with params: [String: String], finished: @escaping DataBlock)
}

// MARK: - Implementation

class NetworkLayerImpl: NetworkLayer {

    // MARK: Shared Alamofire session

    private static let session: Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 30
        config.timeoutIntervalForResource = 30
        return Session(configuration: config)
    }()

    // MARK: Private helpers

    private var authHeaders: HTTPHeaders? {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return nil }
        return HTTPHeaders([HTTPHeader(name: "Authorization", value: "Bearer \(token)")])
    }

    /// Generic GET request with Bearer auth.
    private func get(_ url: String,
                     params: [String: String],
                     finished: @escaping DataBlock) {
        APILogger.logRequest(method: "GET", url: url, params: params)
        let start = Date()
        NetworkLayerImpl.session
            .request(url, parameters: params, headers: authHeaders)
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                if let error = response.error {
                    APILogger.logFailure(method: "GET", url: url, error: error.localizedDescription, duration: duration)
                } else {
                    APILogger.logResponse(method: "GET", url: url, statusCode: code, data: response.data, duration: duration)
                }
                guard let data = response.data else { return }
                finished(data)
            }
    }

    /// Generic GET request with OAuth 1.0 HMAC-SHA1 signing (used by endpoints
    /// that the server requires to be signed rather than Bearer-authed).
    /// The OAuth Authorization header is built via `Constants.getoAuthValue`.
    private func signedGet(_ urlString: String,
                           params: [String: String],
                           finished: @escaping DataBlock) {
        guard let url = URL(string: urlString) else { return }
        let oauthValue = Constants.getoAuthValue(url: url, method: "GET", parameters: params)
        var headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: oauthValue)])
        if let bearerToken = UserDefaults.standard.string(forKey: "auth_token") {
            // Some servers accept both; keep Bearer as fallback in the same request.
            headers.add(name: "X-Auth-Token", value: bearerToken)
        }
        APILogger.logRequest(method: "GET(OAuth)", url: urlString, params: params)
        let start = Date()
        NetworkLayerImpl.session
            .request(urlString, parameters: params, headers: headers)
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                if let error = response.error {
                    APILogger.logFailure(method: "GET(OAuth)", url: urlString,
                                        error: error.localizedDescription, duration: duration)
                } else {
                    APILogger.logResponse(method: "GET(OAuth)", url: urlString,
                                         statusCode: code, data: response.data, duration: duration)
                }
                guard let data = response.data else { return }
                finished(data)
            }
    }

    /// Generic POST request with Bearer auth.
    private func post(_ url: String,
                      params: [String: String],
                      finished: @escaping DataBlock) {
        APILogger.logRequest(method: "POST", url: url, params: params)
        let start = Date()
        NetworkLayerImpl.session
            .request(url, method: .post, parameters: params, headers: authHeaders)
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                if let error = response.error {
                    APILogger.logFailure(method: "POST", url: url, error: error.localizedDescription, duration: duration)
                } else {
                    APILogger.logResponse(method: "POST", url: url, statusCode: code, data: response.data, duration: duration)
                }
                guard let data = response.data else { return }
                finished(data)
            }
    }

    /// Generic POST that sends a nested JSON body (not form-encoded).
    /// Used for endpoints like saveSpecialHabits whose body is a nested object.
    private func postJSON(_ url: String,
                          body: [String: Any],
                          finished: @escaping DataBlock) {
        APILogger.logRequest(method: "POST(JSON)", url: url, params: body)
        let start = Date()
        NetworkLayerImpl.session
            .request(url, method: .post, parameters: body,
                     encoding: JSONEncoding.default, headers: authHeaders)
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                if let error = response.error {
                    APILogger.logFailure(method: "POST(JSON)", url: url,
                                        error: error.localizedDescription, duration: duration)
                } else {
                    APILogger.logResponse(method: "POST(JSON)", url: url,
                                         statusCode: code, data: response.data, duration: duration)
                }
                guard let data = response.data else { return }
                finished(data)
            }
    }

    // MARK: - NetworkLayer

    func login(with params: [String: String], finished: @escaping DataBlock) {
        let url = AppURLS.ip + "/MobileApi/api/Authenticate"
        APILogger.logRequest(method: "POST", url: url, params: params)
        let start = Date()
        NetworkLayerImpl.session
            .request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody)
            .responseJSON { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                if let error = response.error {
                    APILogger.logFailure(method: "POST", url: url, error: error.localizedDescription, duration: duration)
                } else {
                    APILogger.logResponse(method: "POST", url: url, statusCode: code, data: response.data, duration: duration)
                }
                guard let data = response.data else { return }
                finished(data)
            }
    }

    func getPatientsCount(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/get_patients_counts", params: params, finished: finished)
    }

    func getDoctorPermission(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/WorkFlowController/workflow", params: params, finished: finished)
    }

    func getInpatientUnits(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/get_inpatient_units", params: params, finished: finished)
    }

    func getInpatientPatients(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/get_inpatient_patients", params: params, finished: finished)
    }

    func getOutpatientClinics(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/get_outpatients_clinic", params: params, finished: finished)
    }

    func getOperationPatients(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/get_or_patients", params: params, finished: finished)
    }

    func getOutpatientPatients(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/get_outpatients_patients", params: params, finished: finished)
    }

    func changePatientStatus(with params: [String: String], finished: @escaping DataBlock) {
        let serv = params["SER"]
        let url: String
        switch serv {
        case "B": url = AppURLS.ip + "/MobileApi/api/OutpatientController/arrivalResrvation"
        case "A": url = AppURLS.ip + "/MobileApi/api/OutpatientController/startResrvation"
        case "S": url = AppURLS.ip + "/MobileApi/api/OutpatientController/performResrvation"
        default:  url = AppURLS.ip + "/MobileApi/api/get_outpatients_patients"
        }
        get(url, params: params, finished: finished)
    }

    func getEmergencyPatients(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/get_er_patients", params: params, finished: finished)
    }

    func getClinicalPatients(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/get_critical_result", params: params, finished: finished)
    }

    func getTemplate(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/get_template_data", params: params, finished: finished)
    }

    func validateServiceRow(with params: [String: String], finished: @escaping DataBlock) {
        post(AppURLS.ip + "/MobileApi/api/ServiceRowValidate", params: params, finished: finished)
    }

    func getLabServices(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/GetServiceLab", params: params, finished: finished)
    }

    func getRadServices(with params: [String: String], finished: @escaping DataBlock) {
        guard let sessionInfo = params["GetSessionInfo"] else { return }
        let url = AppURLS.ip + "/MobileApi/api/GetServiceRad?RadType=1&ParentServ=0&GetSessionInfo=\(sessionInfo)"
        get(url, params: params, finished: finished)
    }

    func saveOrder(with params: [String: String], orderType: TemplateType, finished: @escaping DataBlock) {
        let api = orderType == .labOrder ? "saveLabOrders" : "RadOrderSave"
        post(AppURLS.ip + "/MobileApi/api/" + api, params: params, finished: finished)
    }

    func getPatientHistory(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/LoadPatientEpisodes", params: params, finished: finished)
    }

    func getPatientSummary(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/GetPatCustomizedSummary", params: params, finished: finished)
    }

    func getPacksURL(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/mobileapi/api/getPacsUrl/", params: params, finished: finished)
    }

    func getTriageInfo(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/loadTrige", params: params, finished: finished)
    }

    func loadUcaf(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/MedicalRecord/loadUcaf", params: params, finished: finished)
    }

    func loadSpecialHabits(with params: [String: String], finished: @escaping DataBlock) {
        // This endpoint requires OAuth 1.0 signing — not Bearer auth.
        // Endpoint name intentionally matches the server typo "loadSpecialHappits".
        signedGet(AppURLS.ip + "/MobileApi/api/MedicalRecord/loadSpecialHappits",
                  params: params, finished: finished)
    }

    func saveSpecialHabits(body: [String: Any], finished: @escaping DataBlock) {
        // Save uses Bearer auth (no OAuth). Body is nested JSON, not form-encoded.
        postJSON(AppURLS.ip + "/MobileApi/api/MedicalRecordController/saveSpecialHabits",
                 body: body, finished: finished)
    }

    func saveUcaf(body: [String: Any], finished: @escaping DataBlock) {
        // Same auth / encoding pattern as saveSpecialHabits.
        postJSON(AppURLS.ip + "/MobileApi/api/MedicalRecordController/saveUcaf",
                 body: body, finished: finished)
    }

    func getSymptoms(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/cot_child", params: params, finished: finished)
    }

    func saveTriage(with params: [String: String], finished: @escaping DataBlock) {
        post(AppURLS.ip + "/MobileApi/api/save_dataTR", params: params, finished: finished)
    }

    func loadFlagImage(with params: [String: String], finished: @escaping DataBlock) {
        guard let flagImagePath = params["flagImageName"] else { return }
        let url = AppURLS.ip + "/primecare/Hospital%20Images/" + flagImagePath
        APILogger.logRequest(method: "GET", url: url)
        let start = Date()
        NetworkLayerImpl.session
            .request(url, headers: authHeaders)
            .responseData { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                if let error = response.error {
                    APILogger.logFailure(method: "GET", url: url, error: error.localizedDescription, duration: duration)
                } else {
                    SwiftyBeaver.debug("✅ \(code)  /primecare/…/\(flagImagePath)  (\(String(format: "%.2fs", duration)))  [image]")
                }
                guard let data = response.data else { return }
                finished(data)
            }
    }

    func getVisitsDetail(with params: [String: String], finished: @escaping DataBlock) {
        get(AppURLS.ip + "/MobileApi/api/PatientController/GetVisitsDetail",
            params: params, finished: finished)
    }
}

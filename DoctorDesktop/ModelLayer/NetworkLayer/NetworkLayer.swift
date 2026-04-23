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
import CommonCrypto

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
    /// GET /MobileApi/api/MedicalRcordController/DDDocNurseNotesLoad — loads the
    /// progress-notes screen (notes list + priority/visit-type/show-to/filter lookups).
    /// Endpoint name preserves the server typo "MedicalRcordController".
    func loadDoctorNurseNotes(with params: [String: String], finished: @escaping DataBlock)
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
        // Confirmed from Android network logs: MedicalRecord (no "Controller"), UCAF uppercase.
        postJSON(AppURLS.ip + "/MobileApi/api/MedicalRecord/saveUCAF",
                 body: body, finished: finished)
    }

    func loadDoctorNurseNotes(with params: [String: String], finished: @escaping DataBlock) {
        // OAuth params go in the URL query string (same as Android, NOT Authorization header).
        let base = AppURLS.ip + "/MobileApi/api/MedicalRcordController/DDDocNurseNotesLoad"
        guard let (signedURL, baseString) = NetworkLayerImpl.buildOAuthURL(base: base, params: params) else {
            print("❌ [NurseNotes] buildOAuthURL returned nil — HMAC failed")
            return
        }

        print("╔══════════════════════════════════════════════════════════════════════")
        print("║ [NurseNotes] FULL REQUEST")
        print("║ METHOD : GET")
        print("║ URL    : \(signedURL)")
        print("║ HEADERS: (none — OAuth is in the URL query string)")
        print("║")
        print("║ curl equivalent:")
        print("║ curl -v '\(signedURL)'")
        print("║")
        print("║ OAuth base string:")
        print("║ \(baseString)")
        print("╚══════════════════════════════════════════════════════════════════════")

        // Use URLRequest directly so Foundation never re-encodes the pre-signed query.
        guard let url = URL(string: signedURL) else {
            print("❌ [NurseNotes] URL(string:) failed — signedURL contains illegal chars: \(signedURL)")
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.timeoutInterval = 30

        let start = Date()
        NetworkLayerImpl.session
            .request(urlRequest)
            .responseData { response in
                let duration = Date().timeIntervalSince(start)
                let code = response.response?.statusCode ?? 0
                let rawBody = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "<no body>"

                print("╔══════════════════════════════════════════════════════════════════════")
                print("║ [NurseNotes] RESPONSE  status=\(code)  time=\(String(format: "%.2f", duration))s")
                print("║ Body: \(rawBody.prefix(500))")
                print("╚══════════════════════════════════════════════════════════════════════")

                if let error = response.error {
                    print("❌ [NurseNotes] Network error: \(error.localizedDescription)")
                }
                guard let data = response.data else { return }
                finished(data)
            }
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

    // MARK: - OAuth URL builder (query-string style, matches Android)

    /// Builds a signed URL with OAuth 1.0 HMAC-SHA1 params appended as query-string
    /// entries — exactly how the Android app signs DDDocNurseNotesLoad.
    /// Returns (signedURL, oauthBaseString) for logging/debugging, or nil on HMAC failure.
    static func buildOAuthURL(base: String, params: [String: String]) -> (url: String, baseString: String)? {
        let consumerKey    = "khaber_1"
        let consumerSecret = "khabeerP@$$w0rd"

        let timestamp = String(Int(Date().timeIntervalSince1970))
        let nonce = String(Int32.random(in: Int32.min...Int32.max))

        var all = params
        all["oauth_consumer_key"]     = consumerKey
        all["oauth_nonce"]            = nonce
        all["oauth_signature_method"] = "HMAC-SHA1"
        all["oauth_timestamp"]        = timestamp
        all["oauth_version"]          = "1.0"

        // Step 1 (RFC 5849 §3.4.1.3): oauthEncode EACH key and value individually.
        // The encoded values (e.g. "2%2C1" for "2,1") go into the paramString.
        let paramString = all.sorted { $0.key < $1.key }
            .map { "\(oauthEncode($0.key))=\(oauthEncode($0.value))" }
            .joined(separator: "&")

        // Step 2: oauthEncode the entire paramString — this double-encodes any
        // percent signs already in it (e.g. %2C → %252C), which is required.
        let baseString = "GET&\(oauthEncode(base))&\(oauthEncode(paramString))"
        // Step 3: HMAC-SHA1 key = percent(consumerSecret) & (no token secret)
        let signingKey = "\(oauthEncode(consumerSecret))&"
        guard let sig = hmacSHA1(key: signingKey, message: baseString) else {
            return nil
        }
        all["oauth_signature"] = sig

        // Step 4: build final URL — all params (including oauth_signature) in query string
        let query = all.sorted { $0.key < $1.key }
            .map { "\(oauthEncode($0.key))=\(oauthEncode($0.value))" }            .joined(separator: "&")

        return ("\(base)?\(query)", baseString)
    }

    /// RFC 3986 percent-encoding for OAuth 1.0 base-string construction.
    ///
    /// IMPORTANT: Swift's `addingPercentEncoding` silently skips re-encoding of
    /// already-percent-encoded sequences (e.g. `%2C` is left as-is instead of
    /// becoming `%252C`). This breaks the double-encoding required in step 3 of
    /// the OAuth base-string algorithm (encode the already-encoded param string).
    /// We use a manual UTF-8 byte loop so `%` (0x25) is always encoded to `%25`.
    private static func oauthEncode(_ s: String) -> String {
        var result = ""
        result.reserveCapacity(s.utf8.count * 3)
        for byte in s.utf8 {
            switch byte {
            case 0x41...0x5A,  // A–Z
                 0x61...0x7A,  // a–z
                 0x30...0x39,  // 0–9
                 0x2D,         // -
                 0x2E,         // .
                 0x5F,         // _
                 0x7E:         // ~
                result.append(Character(UnicodeScalar(byte)))
            default:
                result += String(format: "%%%02X", byte)
            }
        }
        return result
    }

    private static func hmacSHA1(key: String, message: String) -> String? {
        guard let keyBytes = key.data(using: .utf8),
              let msgBytes = message.data(using: .utf8) else { return nil }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        keyBytes.withUnsafeBytes { kb in
            msgBytes.withUnsafeBytes { mb in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
                       kb.baseAddress, keyBytes.count,
                       mb.baseAddress, msgBytes.count,
                       &digest)
            }
        }
        return Data(digest).base64EncodedString()
    }
}

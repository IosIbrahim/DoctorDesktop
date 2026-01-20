//
//  NetworkLayer.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/9/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import Alamofire

typealias DataBlock = ((Data) -> Void)

struct AppURLS {
//  static let ip = "http://192.168.1.127/"
//  static let ip = "http://10.10.10.150"
    
    //  static let ip = "http://10.10.10.150"

  static let oldIP =      "http://192.168.1.187"
  static let ip =      "http://41.33.82.156:29804"
  static let mobileApi = "MobileApi/api/"
  static let imageApi = "primecare/Hospital%20Images/"
}

protocol NetworkLayer {
  func login(with params: [String: String], finished: @escaping DataBlock)
  func getPatientsCount(with params: [String: String], finished: @escaping DataBlock)
  func getInpatientUnits(with params: [String: String], finished: @escaping DataBlock)
  func getInpatientPatients(with params: [String: String], finished: @escaping DataBlock)
    func getOutpatientClinics(with params: [String: String], finished: @escaping DataBlock)
    func getOperationPatients(with params: [String: String], finished: @escaping DataBlock)
  func getOutpatientPatients(with params: [String: String], finished: @escaping DataBlock)
  func getClinicalPatients(with params: [String: String], finished: @escaping DataBlock)
  func getTemplate(with params:[String: String], finished: @escaping DataBlock)
  func getEmergencyPatients(with params: [String: String], finished: @escaping DataBlock)
  func validateServiceRow(with params:[String: String], finished: @escaping DataBlock)
  func getLabServices(with params:[String: String], finished: @escaping DataBlock)
  func getRadServices(with params:[String: String], finished: @escaping DataBlock)
  func saveOrder(with params:[String: String], orderType: TemplateType, finished: @escaping DataBlock)
  func getPatientHistory(with params:[String: String], finished: @escaping DataBlock)
  func getPatientSummary(with params:[String: String], finished: @escaping DataBlock)
  func getPacksURL(with params:[String: String], finished: @escaping DataBlock)
  func getTriageInfo(with params: [String: String], finished: @escaping DataBlock)
  func getSymptoms(with params: [String: String], finished: @escaping DataBlock)
  func loadFlagImage(with params: [String: String], finished: @escaping DataBlock)
}

class NetworkLayerImpl: NetworkLayer {
  struct AlamofireAppManager {
    static let shared: Session = {
      let configuration = URLSessionConfiguration.default
      configuration.timeoutIntervalForRequest = 30
      configuration.timeoutIntervalForResource = 30
      let sessionManager = Alamofire.Session(configuration: configuration)
      return sessionManager
    }()
  }

  func login(with params: [String: String], finished: @escaping DataBlock) {

    let url = AppURLS.ip+"/MobileApi/api/Authenticate"
    AlamofireAppManager.shared.request(url, method: .post,
                                       parameters: params,
                                       encoding: URLEncoding.httpBody)
      .responseJSON { response in
        print(response)
        guard let data = response.data else { return }
        finished(data)
    }
  }
  
}

extension NetworkLayerImpl {
  func getPatientsCount(with params: [String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/get_patients_counts"
    print(params)
      print(url)
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
          print(response.value ?? "")
        finished(data)
    }
  }
  
  func getInpatientUnits(with params: [String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/get_inpatient_units"
    
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
  
  func getInpatientPatients(with params: [String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/get_inpatient_patients"
    
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func getOutpatientClinics(with params: [String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/get_outpatients_clinic"
    
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
  
    func getOperationPatients(with params: [String: String], finished: @escaping DataBlock) {
        let url = AppURLS.ip+"/MobileApi/api/get_or_patients"
        
        AlamofireAppManager.shared.request(url, parameters: params)
            .responseJSON { response in
                guard let data = response.data else { return }
                finished(data)
        }
    }
  func getOutpatientPatients(with params: [String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/get_outpatients_patients"
    
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func getEmergencyPatients(with params: [String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/get_er_patients"
    
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func getClinicalPatients(with params: [String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/get_critical_result"

      AF.request(url, parameters: params)
      .responseJSON { response in
        if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: (((response.value as! [String:Any])["Root"] as! [String:Any])["PATIENT"] as! [String:Any])["PATIENT_ROW"]!,
            options: .prettyPrinted
            ),
            let theJSONText = String(data: theJSONData,
                                     encoding: String.Encoding.ascii) {
            print("JSON string = \n\(theJSONText)")
        }
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func getTemplate(with params:[String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/get_template_data"
    
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func validateServiceRow(with params:[String: String], finished: @escaping DataBlock) {
    //guard let rcpServices = params["RcpServices"],
      //let patientId = params["PatientID"],
      //let serviceValidation = params["GetServValidateParms"],
      //let sessionInfo = params["GetSessionInfo"] else { return }
    let url = AppURLS.ip+"/MobileApi/api/ServiceRowValidate"

    //let url = """
    //http://197.50.197.107/MobileApi/api/ServiceRowValidate?RcpServices=\(rcpServices)&PatientID=\(patientId)&GetServValidateParms=\(serviceValidation)&GetSessionInfo=\(sessionInfo)
    //"""
    AlamofireAppManager.shared.request(url,
                                       method: .post,
                                       parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func getLabServices(with params:[String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/GetServiceLab"
    
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func getRadServices(with params:[String: String], finished: @escaping DataBlock) {
    guard let sessionInfo = params["GetSessionInfo"] else { return }
    let url = AppURLS.ip+"""
    /MobileApi/api/GetServiceRad?RadType=1&ParentServ=0&GetSessionInfo=\(sessionInfo)
    """
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func saveOrder(with params:[String: String], orderType: TemplateType, finished: @escaping DataBlock) {
    let api = orderType == .labOrder ? "saveLabOrders" : "RadOrderSave"
    let url = AppURLS.ip+"/MobileApi/api/" + api
    AlamofireAppManager.shared.request(url,
                                       method: .post,
                                       parameters: params,
                                       encoding: JSONEncoding.default)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func getPatientHistory(with params:[String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/LoadPatientEpisodes"
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func getPatientSummary(with params:[String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/GetPatCustomizedSummary"
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func getPacksURL(with params:[String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/mobileapi/api/getPacsUrl/"
    AlamofireAppManager.shared.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
        
        
        print(response)
        
    }
  }
}

extension NetworkLayerImpl {
  func getTriageInfo(with params: [String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/loadTrige"
    AF.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }

  func getSymptoms(with params: [String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/cot_child"
    AF.request(url, parameters: params)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }

  func saveTriage(with params:[String: String], finished: @escaping DataBlock) {
    let url = AppURLS.ip+"/MobileApi/api/save_dataTR"
    AF.request(url,
                      method: .post,
                      parameters: params,
                      encoding: JSONEncoding.default)
      .responseJSON { response in
        guard let data = response.data else { return }
        finished(data)
    }
  }
}

extension NetworkLayerImpl {
  func loadFlagImage(with params: [String: String], finished: @escaping DataBlock) {
    guard let flagImagePath = params["flagImageName"] else { return }
    let url = AppURLS.ip+"/primecare/Hospital%20Images/" + flagImagePath
    AF.request(url)
      .responseData { response in
        guard let data = response.data else { return }
        finished(data)
      }
  }
}

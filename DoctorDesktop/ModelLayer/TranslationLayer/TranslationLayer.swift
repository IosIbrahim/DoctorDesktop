//
//  TranslationLayer.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/9/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import Foundation
import Stuff

protocol TranslationLayer {
    func createComponentDTOsFromJsonData(_ data: Data) -> Components
    func createUserDTOFromJsonData(_ data: Data) -> User
    func getCountsFromJson(_ data: Data) -> PatientCount
    func getDoctorPermissionsFromJson(_ data: Data) -> DoctorPermissions
    
    func getInpatientUnitDTOsFromJson(_ data: Data) -> PatientUnits
    func getInpatientPatientsDTOsFromJson(_ data: Data) -> InpatientPatients
    func getOutpatientClinicDTOsFromJson(_ data: Data) -> OutpatientClinics
    func getOutpatientPatientsDTOsFromJson(_ data: Data) -> OutpatientPatients
    
    func getEmergencyPatientsDTOsFromJson(_ data: Data) -> EmergencyPatients
    func getClinicalPatientDTOFromJsonData(_ data: Data) -> [ClinicalPatient]
    func getOperationPatientDTOFromJsonData(_ data: Data) -> [OperationPatient]
    func getTemplateDTOFromJson(_ data: Data) -> Template?
    
    func getServiceDetailsDTOsFromJson(_ data: Data) -> ServicesDetails
    func getLabServiceDTOFromJson(_ data: Data) -> LabRadServices
    func getRadServiceDTOFromJson(_ data: Data) -> LabRadServices
    func getMessageFromLabOrdeSaveResponse(_ data: Data) -> Message
    
    func getPatientHistoryDTOFromJson(_ data: Data) -> PatientHistory
    func getPatientSummaryDTOFromJson(_ data: Data) -> PatientSummary
    func getPacksURLFromJson(_ data: Data) -> URL?
    func getVitalsDTOsFromJson(_ data: Data) -> UCAFData?
    func getLoadUcafFromJson(_ data: Data) -> UCAFLoadData?
    func getLoadUcafCTASFromJson(_ data: Data) -> UCAFCTASServer?
    func getSpecialHabitsFromJson(_ data: Data) -> SpecialHabitsData?
    func getDoctorNurseNotesFromJson(_ data: Data) -> DoctorNurseNotesData
    
    func getHistorySymptomsDTOsFromJson(_ data:Data) -> HistorySymptomCategories
    func getDiagnosisCategoriesDTOsFromJson(_ data: Data) -> DiagnosisCategories
    func getPainScoresDTOsFromJson(_ data: Data) -> Scores
    func getSymptomCategoriesDTOsFromJson(_ data: Data) -> RegularSymptomCategories
    func getSymptomsDTOsFromJson(_ data: Data) -> Symptoms
    func getVisitDetailDTOFromJson(_ data: Data) -> VisitDetail?
}

class TranslationLayerImpl: TranslationLayer {
    let jsonDecoder = JSONDecoder()
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func createComponentDTOsFromJsonData(_ data: Data) -> Components {
        print("date")
        print(data)

        // IMPORTANT: pass .useDefaultKeys explicitly. The Stuff pod defaults
        // to .convertFromSnakeCase, which mangles UPPER_SNAKE_CASE JSON keys
        // (e.g. PROCESS_INFO_CODE → pROCESSINFOCODE) so they no longer match
        // the explicit CodingKeys. Result: every field except `ID` decodes
        // as empty/0.
        guard let components = try? Components(
            data: data,
            keyPath: "userComponent",
            keyDecodingStrategy: .useDefaultKeys
        ) else {
            return []
        }
        print(components)
        return components
    }
    
    func createUserDTOFromJsonData(_ data: Data) -> User {
        // .useDefaultKeys — see createComponentDTOsFromJsonData for rationale.
        // Without this, EMP_AR_NAME / EMP_EN_NAME get mangled by
        // .convertFromSnakeCase and arrive as nil. (Also fixes id, branch, etc.)
        let user = try? User(data: data, keyPath: "OUTPARAMS.OUTPARAMS_ROW",
                             keyDecodingStrategy: .useDefaultKeys)
        if let branch = user?.branch {
            UserDefaults.standard.set(branch, forKey: "branch_id") //setObject
        }
        if let name = user?.userName {
            UserDefaults.standard.set(name, forKey: "userName") //setObject
        }
        do {
            // make sure this JSON is in the format we expect
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // try to read out a string array
                let token = json["token"] as? String
                UserDefaults.standard.set(token ?? "", forKey: "auth_token") //setObject
                print(json)
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        return user ?? .init()
    }
}

extension TranslationLayerImpl {
    func getCountsFromJson(_ data: Data) -> PatientCount {
        print(data.toJsonString() ?? "")

        // .useDefaultKeys — see createComponentDTOsFromJsonData for rationale
        // (UPPER_SNAKE_CASE JSON keys get mangled by .convertFromSnakeCase).
        if var patientCount = try? PatientCount(
            data: data,
            keyPath: "Root.OUT_PARMS.OUT_PARMS_ROW",
            keyDecodingStrategy: .useDefaultKeys
        ) {
            if let com = try? DoctorPermissions(
                data: data,
                keyPath: "userComponent",
                keyDecodingStrategy: .useDefaultKeys
            ) {
                patientCount.permissions = com
            }
            return patientCount
        }

        // Only surface an error when the server explicitly sends a Message key.
        var emp = PatientCount()
        if let errorModel = try? ErrorModel(data: data), let msg = errorModel.error {
            emp.error = msg
        }
        if let com = try? DoctorPermissions(
            data: data,
            keyPath: "userComponent",
            keyDecodingStrategy: .useDefaultKeys
        ) {
            emp.permissions = com
        }
        return emp
    }
    
    
    func getDoctorPermissionsFromJson(_ data: Data) -> DoctorPermissions {
        print(data.toJsonString() ?? "")
        if let patientCount = try? DoctorPermissions (data: data, keyPath: "Root", keyDecodingStrategy: .useDefaultKeys) {
            return patientCount
        }else if let patientCount = try? PermissionModel (data: data, keyPath: "Root", keyDecodingStrategy: .useDefaultKeys) {
            return [patientCount]
        }
        return []
    }
    
    func getInpatientUnitDTOsFromJson(_ data: Data) -> PatientUnits {
        guard let json = String(data: data, encoding: .utf8), json.contains("UNIT_ROW") else { return [] }
        let keyPath = "Root.UNIT.UNIT_ROW"
        guard let inpatientUnits = try? PatientUnits (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let inpatientUnit = try? PatientUnit (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [inpatientUnit]
            } else {
                return []
            }
        }
        return inpatientUnits
    }
    
    func getInpatientPatientsDTOsFromJson(_ data: Data) -> InpatientPatients {
        guard let json = String(data: data, encoding: .utf8), json.contains("PATIENT_ROW") else { return [] }
        let keyPath = "Root.UNIT.UNIT_ROW.PATIENT.PATIENT_ROW"
        guard let inpatientPatients = try? InpatientPatients (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let inpatientPatient = try? InpatientPatient (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [inpatientPatient]
            } else {
                return []
            }
        }
        return inpatientPatients
    }
}

extension TranslationLayerImpl {
    func getOutpatientClinicDTOsFromJson(_ data: Data) -> OutpatientClinics {
        guard let json = String(data: data, encoding: .utf8), json.contains("CLINIC_ROW") else { return [] }
        let keyPath = "Root.CLINIC.CLINIC_ROW"
        guard let outpatientClinics = try? OutpatientClinics (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let outpatientClinic = try? OutpatientClinic (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [outpatientClinic]
            } else {
                return []
            }
        }
        return outpatientClinics
    }
    
    func getOutpatientPatientsDTOsFromJson(_ data: Data) -> OutpatientPatients {
        guard let json = String(data: data, encoding: .utf8), json.contains("CLINIC_PATIENTS_ROW") else { return [] }
        print(json)
        let keyPath = "Root.CLINIC_PATIENTS.CLINIC_PATIENTS_ROW"
        
        guard let outpatientPatients = try? OutpatientPatients (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let outpatientPatient = try? OutpatientPatient (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [outpatientPatient]
            } else {
                if let outpatientPatients = try? [OutpatientPatient] (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                    return outpatientPatients
                }else {
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    do {
                        let topLevel = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                        guard let nestedJson = (topLevel as AnyObject).value(forKeyPath: keyPath) else { return []
                        }
                        let nestedData = try JSONSerialization.data(withJSONObject: nestedJson)
                        
                        let result = try decoder.decode(OutpatientPatient.self, from: nestedData)
                        return [result]
                    } catch {
                        do {
                            let topLevel = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                            guard let nestedJson = (topLevel as AnyObject).value(forKeyPath: keyPath) else { return []
                            }
                            let nestedData = try JSONSerialization.data(withJSONObject: nestedJson)
                            let result = try decoder.decode([OutpatientPatient].self, from: nestedData)
                            return result
                        } catch {
                            print(error)
                            return []
                            
                        }
                    }
                }
            }
        }
        return outpatientPatients
    }
}

extension TranslationLayerImpl {
    func getEmergencyPatientsDTOsFromJson(_ data: Data) -> EmergencyPatients {
        guard let json = String(data: data, encoding: .utf8), json.contains("ER_PATIENTS_ROW") else { return [] }
        let keyPath = "Root.ER_PATIENTS.ER_PATIENTS_ROW"
        guard let emergencyPatients = try? EmergencyPatients (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let emergencyPatient = try? EmergencyPatient (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [emergencyPatient]
            } else {
                return []
            }
        }
        return emergencyPatients
    }
}

extension TranslationLayerImpl {
    func getClinicalPatientDTOFromJsonData(_ data: Data) -> [ClinicalPatient] {
        let clinicalPatient = try? [ClinicalPatient] (data: data, keyPath: "Root.PATIENT.PATIENT_ROW", keyDecodingStrategy: .useDefaultKeys)
        let clinicalPatientObj = try? ClinicalPatient(data: data, keyPath: "Root.PATIENT.PATIENT_ROW", keyDecodingStrategy: .useDefaultKeys)
        var finallArray = [ClinicalPatient]()
        if clinicalPatient != nil
        {
            finallArray.append(contentsOf: clinicalPatient!)
        }
        if clinicalPatientObj != nil
        {
            finallArray.append(clinicalPatientObj!)
        }
        return finallArray
    }
    func getOperationPatientDTOFromJsonData(_ data: Data) -> [OperationPatient] {
        
        
        let clinicalPatient = try? Root (data: data , keyPath: "Root")
        //        let clinicalPatientObj = try? OperationPatient(data: data, keyPath: "Root.OR_PATIENTS.OR_PATIENTS_ROW", keyDecodingStrategy: .useDefaultKeys)
        var finallArray = [OperationPatient]()
        if clinicalPatient != nil && clinicalPatient!.oR_PATIENTS != nil
        {
            finallArray.append(contentsOf: clinicalPatient!.oR_PATIENTS!.oR_PATIENTS_ROW)
        }
        //        if clinicalPatientObj != nil
        //        {
        //            finallArray.append(clinicalPatientObj!)
        //        }
        return finallArray
    }
}

extension TranslationLayerImpl {
    func getTemplateDTOFromJson(_ data: Data) -> Template? {
        let serviceTemplates = (try? [GeneralObejct].decode(data, keyPath: "Root.STP_SERVICE_TEMPLATE.STP_SERVICE_TEMPLATE_ROW")) ?? [GeneralObejct]()
//        let serviceCategories = try! [ServiceCategory].decode(data, keyPath: "Root.PARENT_SERVICE.PARENT_SERVICE_ROW") //?? [ServiceCategory]()
        let serviceCategories = getServices(data)
        let generalParams = (try! GeneralParams(data: data, keyPath: "Root.GENERAL_PARMS.GENERAL_PARMS_ROW", keyDecodingStrategy: .useDefaultKeys))
        let frequency = (try? [GeneralObejct].decode(data, keyPath: "Root.MPFREQUENCY.MPFREQUENCY_ROW")) ?? [GeneralObejct]()
        let labIntervalUnits = (try? [GeneralObejct].decode(data, keyPath: "Root.LAB_INTERV_UNIT.LAB_INTERV_UNIT_ROW")) ?? [GeneralObejct]()
        let verbalOrderTypes = (try? [GeneralObejct].decode(data, keyPath: "Root.VERBAL_ORDER_TYPE.VERBAL_ORDER_TYPE_ROW")) ?? [GeneralObejct]()
        let readBack = (try? [GeneralObejct].decode(data, keyPath: "Root.READ_BACK.READ_BACK_ROW")) ?? [GeneralObejct]()
        
        return Template(serviceTemplates: serviceTemplates,
                        servicesCategories: serviceCategories,
                        generalParams: generalParams,
                        frequency: frequency,
                        labIntervalUnits: labIntervalUnits,
                        verbalOrderTypes: verbalOrderTypes,
                        readBack: readBack)
    }
    
    func getServices(_ data:Data) -> [ServiceCategory] {
        var services = [ServiceCategory]()
        do {
            let json =  try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            let root = json?["Root"] as! [String : AnyObject]
            let parentJson = root["PARENT_SERVICE"] as! [String : AnyObject]
            let parentJsonRow = parentJson["PARENT_SERVICE_ROW"] as! [[String:AnyObject]]
            for dic in parentJsonRow {
               // let serviceCat = ServiceCategor
                
                if let row = dic["DETAIL_SERVICE"] as? [String:AnyObject] {
                    let service = self.setServiceModelModel(row)
                    var cat =  ServiceCategory(id: "", arabicName: "", englishName: "", type: "", templateId: "", typeArabicTitle: "", typeEnglishTitle: "", services: [])
                    cat = cat.setModel(dic , services: service)
                    services.append(cat)
                }else if let rows = dic["DETAIL_SERVICE"] as? [[String:AnyObject]] {
                    var serviceArr = [Service]()
                    for rowDic in rows {
                        let service = self.setServiceModelModel(rowDic)
                        serviceArr.append(contentsOf: service)
                    }
                    var cat =  try ServiceCategory(data: .init())
                    cat = cat.setModel(dic , services: serviceArr)
                    services.append(cat)
                }
            }
            } catch let error as NSError {
                print(error)
         }
        return services
    }
    
    
    func setServiceModelModel(_ dic:[String:AnyObject])-> [Service] {
       //  let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        var sercive = Service(id: "", arabicName: "", englishName: "", radPosition: "", serviceLevel: "", notUrgent: "", prepareArabicInstructions: "", prepareEnglishInstructions: "", childIds: "")
        var serices = [Service]()
        if let sercieRow = dic["DETAIL_SERVICE_ROW"] as? [String:AnyObject] {
            sercive.id = sercieRow["SERVICE_ID"] as? String ?? ""
            sercive.arabicName = sercieRow["SERV_NAME_AR"] as? String ?? ""
            sercive.englishName = sercieRow["SERV_NAME_EN"] as? String ?? ""
            sercive.radPosition = sercieRow["RAD_POSITION"] as? String ?? ""
            sercive.serviceLevel = sercieRow["SERV_SEC_LEV"] as? String ?? ""
            sercive.notUrgent = sercieRow["NOT_URGENT"] as? String ?? ""
            sercive.prepareArabicInstructions = sercieRow["PREPARE_NAME_AR"] as? String ?? ""
            sercive.prepareEnglishInstructions = sercieRow["PREPARE_NAME_EN"] as? String ?? ""
            sercive.childIds = sercieRow["CHILD_SERVICE_ID"] as? String ?? ""
            return [sercive]
        }else if let sercieRow = dic["DETAIL_SERVICE_ROW"] as? [[String:AnyObject]] {
            for item in sercieRow {
                sercive.id = item["SERVICE_ID"] as? String ?? ""
                sercive.arabicName = item["SERV_NAME_AR"] as? String ?? ""
                sercive.englishName = item["SERV_NAME_EN"] as? String ?? ""
                sercive.radPosition = item["RAD_POSITION"] as? String ?? ""
                sercive.serviceLevel = item["SERV_SEC_LEV"] as? String ?? ""
                sercive.notUrgent = item["NOT_URGENT"] as? String ?? ""
                sercive.prepareArabicInstructions = item["PREPARE_NAME_AR"] as? String ?? ""
                sercive.prepareEnglishInstructions = item["PREPARE_NAME_EN"] as? String ?? ""
                sercive.childIds = item["CHILD_SERVICE_ID"] as? String ?? ""
                serices.append(sercive)
            }
        }
        return serices
    }
    
}

extension TranslationLayerImpl {
    func getServiceDetailsDTOsFromJson(_ data: Data) -> ServicesDetails {
        let servicesDetails = try! ServicesDetails.decode(data, keyPath: "Root.SERVICE_RECORD.SERVICE_RECORD_ROW")
        return servicesDetails
    }
}

extension TranslationLayerImpl {
    func getLabServiceDTOFromJson(_ data: Data) -> LabRadServices {
        let labServices = try! LabRadServices.decode(data, keyPath: "Root")
        return labServices
    }
}

extension TranslationLayerImpl {
    func getRadServiceDTOFromJson(_ data: Data) -> LabRadServices {
        let radServices = try! LabRadServices.decode(data, keyPath: "data")
        return radServices
    }
}

extension TranslationLayerImpl {
    func getMessageFromLabOrdeSaveResponse(_ data: Data) -> Message {
        let message = try! Message(data: data)
        return message
    }
}

extension TranslationLayerImpl {
    func getPatientHistoryDTOFromJson(_ data: Data) -> PatientHistory {
        // Use try? not try! — the BHG test server omits some fields like
        // CURRENT_SPECIALITY that the synthesized decoder treats as required,
        // which crashed the app when tapping a patient.
        var patientHistory = (try? PatientHistory(
            data: data,
            keyPath: "Root",
            keyDecodingStrategy: .useDefaultKeys
        )) ?? PatientHistory()
        if let message = try? String(data: data, keyPath: "message", keyDecodingStrategy: .useDefaultKeys) {
            patientHistory.error = message
        }
        return patientHistory
    }
}


extension TranslationLayerImpl{
    func getMedictionsDTOsFromJson(_ data: Data) -> medictions {
        guard let json = String(data: data, encoding: .utf8), json.contains("VISIT_MEDICATIONS_ROW") else { return []
        }
        let keyPath = "Root.PATIENT.PATIENT_ROW.VISIT_MEDICATIONS.VISIT_MEDICATIONS_ROW"
        guard let Medications = try? medictions (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let medication = try? Medication (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [medication]
            } else {
                
                return []
            }
        }
        return Medications
    }
    
    
    func getRadsFromJson(_ data: Data) -> [Rad] {
        guard let json = String(data: data, encoding: .utf8), json.contains("VISIT_MEDICATIONS_ROW") else { return []
        }
        let keyPath = "Root.PATIENT.PATIENT_ROW.VISIT_MEDICATIONS.VISIT_MEDICATIONS_ROW"
        guard let rads = try? [Rad] (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let rad = try? Rad (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [rad]
            } else {
                
                return []
            }
        }
        return rads
    }
}

extension TranslationLayerImpl {

    // MARK: - Safe key-path traversal
    //
    // value(forKeyPath:) uses Objective-C KVC. If any intermediate node in the
    // path is not an NSDictionary (e.g. the server returns "" for an empty
    // field instead of null / {}), KVC throws NSUnknownKeyException — which
    // cannot be caught with Swift's try/catch and kills the app.
    //
    // This pure-Swift traversal returns nil instead of crashing.
    private func safeValue(in root: Any?, keyPath: String) -> Any? {
        let keys = keyPath.components(separatedBy: ".")
        var node: Any? = root
        for key in keys {
            guard let dict = node as? [String: Any] else { return nil }
            node = dict[key]
        }
        return node
    }

    func getPatientSummaryDTOFromJson(_ data: Data) -> PatientSummary {

        // Parse top-level object once — reused for all key-path lookups below.
        let topLevel = try? JSONSerialization.jsonObject(with: data,
                                                         options: .mutableContainers)

        // Backend sometimes returns {"message":"exception in backend"} instead
        // of real data. Surface the message so the presenter can retry.
        let message = (topLevel as? [String: Any])?["message"] as? String

        // ── Helper: decode an array at a given key-path, returns [] on any failure ──
        func decode<T: Decodable>(_ type: T.Type, at keyPath: String) -> T? {
            guard let nested = safeValue(in: topLevel, keyPath: keyPath),
                  JSONSerialization.isValidJSONObject(nested),
                  let nestedData = try? JSONSerialization.data(withJSONObject: nested)
            else { return nil }
            return try? jsonDecoder.decode(T.self, from: nestedData)
        }

        func decodeArray<T: Decodable>(_ type: T.Type, at keyPath: String) -> [T] {
            if let arr = decode([T].self, at: keyPath) { return arr }
            if let one = decode(T.self,   at: keyPath) { return [one] }
            return []
        }

        let complaints    = decodeArray(Complaint.self,  at: "Root.PATIENT.PATIENT_ROW.COMPLAINS.COMPLAINS_ROW")
        let findings      = decodeArray(Finding.self,    at: "Root.PATIENT.PATIENT_ROW.FINDINGS.FINDINGS_ROW")
        let diagnosis     = decodeArray(Diagnosis.self,  at: "Root.PATIENT.PATIENT_ROW.DIAGNOSIS.DIAGNOSIS_ROW")
        let history       = decodeArray(History.self,    at: "Root.PATIENT.PATIENT_ROW.HISTORY.HISTORY_ROW")
        let allergies     = decodeArray(Allergy.self,    at: "Root.PATIENT.PATIENT_ROW.ALLERGY.ALLERGY_ROW")
        let scorings      = decodeArray(Scoring.self,    at: "Root.PATIENT.PATIENT_ROW.SCORING.SCORING_ROW")
        let nurseRemarks  = decodeArray(NurseRemark.self,at: "Root.PATIENT.PATIENT_ROW.NURSE_REMARKS.NURSE_REMARKS_ROW")
        let operations    = decodeArray(Operation.self,  at: "Root.PATIENT.PATIENT_ROW.OPERATION.OPERATION_ROW")
        let catheters     = decodeArray(Cather.self,     at: "Root.PATIENT.PATIENT_ROW.CATHETER.CATHETER_ROW")
        let endoscopies   = decodeArray(Endoscopy.self,  at: "Root.PATIENT.PATIENT_ROW.ENDOSCOPY.ENDOSCOPY_ROW")
        let rads          = decodeArray(Rad.self,        at: "Root.PATIENT.PATIENT_ROW.RAD.RAD_ROW")
        let clinicServices = decodeArray(ClinicService.self, at: "Root.PATIENT.PATIENT_ROW.CLINIC_SERVICES.CLINIC_SERVICES_ROW")
        let dietaries     = decodeArray(Dietary.self,    at: "Root.PATIENT.PATIENT_ROW.DIETRY.DIETRY_ROW")
        // Labs: LAB_ROW is a category wrapper (keys: LAB_CATEGORY, PENDING_LAB_ORDERS).
        // Actual lab orders live inside PENDING_LAB_ORDERS.PENDING_LAB_ORDERS_ROW.
        // LAB_ROW can be a single dict (1 category) or an array (multiple categories).
        var labsTest: [Lab] = []
        let labRowValue = safeValue(in: topLevel, keyPath: "Root.PATIENT.PATIENT_ROW.LAB.LAB_ROW")
        let labRows: [[String: Any]] = {
            if let arr = labRowValue as? [[String: Any]] { return arr }
            if let dict = labRowValue as? [String: Any] { return [dict] }
            return []
        }()
        for labRow in labRows {
            guard let pending = labRow["PENDING_LAB_ORDERS"],
                  JSONSerialization.isValidJSONObject(pending),
                  let pendingData = try? JSONSerialization.data(withJSONObject: pending),
                  let pendingTop = try? JSONSerialization.jsonObject(with: pendingData),
                  let ordersRaw = safeValue(in: pendingTop, keyPath: "PENDING_LAB_ORDERS_ROW"),
                  JSONSerialization.isValidJSONObject(ordersRaw),
                  let ordersData = try? JSONSerialization.data(withJSONObject: ordersRaw)
            else { continue }
            if let arr = try? jsonDecoder.decode([Lab].self, from: ordersData) {
                labsTest += arr
            } else if let one = try? jsonDecoder.decode(Lab.self, from: ordersData) {
                labsTest.append(one)
            }
        }

        let vitalSigns    = decodeArray(VitalSign.self,  at: "Root.PATIENT.PATIENT_ROW.VITAL_SIGNS.VITAL_SIGNS_ROW.DETAILS.DETAILS_ROW")
        let medications   = getMedictionsDTOsFromJson(data)
        // New sections (API typo preserved: OPERTAION_REQUESTS)
        let pathologies       = decodeArray(OperationCatherEndoscopy.self, at: "Root.PATIENT.PATIENT_ROW.PATHOLOGY.PATHOLOGY_ROW")
        let operationRequests = decodeArray(OperationCatherEndoscopy.self, at: "Root.PATIENT.PATIENT_ROW.OPERTAION_REQUESTS.OPERTAION_REQUESTS_ROW")
        let bloodBankItems    = decodeArray(OperationCatherEndoscopy.self, at: "Root.PATIENT.PATIENT_ROW.BLOOD_BANK.BLOOD_BANK_ROW")
        let medicalReports    = decodeArray(OperationCatherEndoscopy.self, at: "Root.PATIENT.PATIENT_ROW.MEDICAL_REPORTS.MEDICAL_REPORTS_ROW")

        return PatientSummary(complaints: complaints,
                              findings: findings,
                              diagnosis: diagnosis,
                              history: history,
                              allergies: allergies,
                              medications: medications,
                              scorings: scorings,
                              nurseRemarks: nurseRemarks,
                              operations: operations,
                              catheters: catheters,
                              endoscopies: endoscopies,
                              rads: rads,
                              clinicServices: clinicServices,
                              dietaries: dietaries,
                              labs: labsTest,
                              vitalSigns: vitalSigns,
                              pathologies: pathologies,
                              operationRequests: operationRequests,
                              bloodBankItems: bloodBankItems,
                              medicalReports: medicalReports,
                              message: message)
    }
}

extension TranslationLayerImpl {
    func getPacksURLFromJson(_ data: Data) -> URL? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let packsURLString = jsonObject?["result"] as? String,
            let url = URL(string: packsURLString) else {
                return nil
        }
        return url
    }
}

extension TranslationLayerImpl {
    // get vitals
    func getVitalsDTOsFromJson (_ data:Data) -> UCAFData? {
        guard let json = String(data: data, encoding: .utf8), json.contains("UCAF_DATA_ROW") else { return nil }
        let keyPath = "Root.UCAF_DATA.UCAF_DATA_ROW"
        guard let ucafdata = try? UCAFData (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            return nil
        }
        return ucafdata
    }

    // VitalSignsEntry: /MedicalRecord/loadUcaf — wider UCAF payload.
    func getLoadUcafFromJson(_ data: Data) -> UCAFLoadData? {
        guard let json = String(data: data, encoding: .utf8),
              json.contains("UCAF_DATA_ROW") else { return nil }
        let keyPath = "Root.UCAF_DATA.UCAF_DATA_ROW"
        return try? UCAFLoadData(data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys)
    }

    // Server-computed CTAS block (may be absent).
    func getLoadUcafCTASFromJson(_ data: Data) -> UCAFCTASServer? {
        guard let json = String(data: data, encoding: .utf8),
              json.contains("CTAS_DATA_ROW") else { return nil }
        let keyPath = "Root.CTAS.CTAS_DATA.CTAS_DATA_ROW"
        return try? UCAFCTASServer(data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys)
    }

    // VitalSignsEntry: /MedicalRecord/loadSpecialHappits — special habits payload.
    // Lives at Root.SPECIAL_HABITS (single object, not an array row).
    func getSpecialHabitsFromJson(_ data: Data) -> SpecialHabitsData? {
        guard let json = String(data: data, encoding: .utf8),
              json.contains("SPECIAL_HABITS") else { return nil }
        let keyPath = "Root.SPECIAL_HABITS"
        return try? SpecialHabitsData(data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys)
    }

    // ProgressNotes: /MedicalRcordController/DDDocNurseNotesLoad (server typo preserved).
    // Parses the notes list plus the four lookup arrays. Everything defaults to [] on
    // missing/malformed data so the caller never crashes.
    func getDoctorNurseNotesFromJson(_ data: Data) -> DoctorNurseNotesData {
        // ── Diagnostic: dump raw response to console ──────────────────────────
        let rawString = String(data: data, encoding: .utf8) ?? "<non-UTF8 data>"
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("[ProgressNotes] RAW RESPONSE (\(data.count) bytes):")
        // Print in chunks so Xcode doesn't truncate long lines
        let chunkSize = 800
        var offset = rawString.startIndex
        while offset < rawString.endIndex {
            let end = rawString.index(offset, offsetBy: chunkSize, limitedBy: rawString.endIndex) ?? rawString.endIndex
            print(rawString[offset..<end])
            offset = end
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let topLevel = try? JSONSerialization.jsonObject(with: data,
                                                         options: .mutableContainers)
        if topLevel == nil {
            print("[ProgressNotes] ⚠️ JSON parse failed — topLevel is nil")
        }

        func decode<T: Decodable>(_ type: T.Type, at keyPath: String) -> T? {
            guard let nested = safeValue(in: topLevel, keyPath: keyPath),
                  JSONSerialization.isValidJSONObject(nested),
                  let nestedData = try? JSONSerialization.data(withJSONObject: nested)
            else { return nil }
            return try? jsonDecoder.decode(T.self, from: nestedData)
        }
        func decodeArray<T: Decodable>(_ type: T.Type, at keyPath: String) -> [T] {
            if let arr = decode([T].self, at: keyPath) { return arr }
            if let one = decode(T.self,   at: keyPath) { return [one] }
            return []
        }

        let notes      = decodeArray(DoctorNurseNote.self, at: "Root.DOCTOR_NURSE_REMARKS.DOCTOR_NURSE_REMARKS_ROW")
        let priorities = decodeArray(NurseNoteLookup.self, at: "Root.NURSE_REMARKS_PRIORITY.NURSE_REMARKS_PRIORITY_ROW")
        // Server uses "VISIT_TYPE" (not "NURSE_REMARKS_VISIT_TYPE"); try both so a
        // future server rename doesn't silently break the filter sheet.
        let visitTypes: [NurseNoteLookup] = {
            let v = decodeArray(NurseNoteLookup.self, at: "Root.VISIT_TYPE.VISIT_TYPE_ROW")
            if !v.isEmpty { return v }
            return decodeArray(NurseNoteLookup.self, at: "Root.NURSE_REMARKS_VISIT_TYPE.NURSE_REMARKS_VISIT_TYPE_ROW")
        }()
        let showToList = decodeArray(NurseNoteLookup.self, at: "Root.NURSE_REMARKS_SHOW_D_N.NURSE_REMARKS_SHOW_D_N_ROW")
        let filters    = decodeArray(NurseNoteLookup.self, at: "Root.NURSE_REMARKS_FILTER.NURSE_REMARKS_FILTER_ROW")

        print("[ProgressNotes] PARSE RESULT → notes:\(notes.count)  priorities:\(priorities.count)  visitTypes:\(visitTypes.count)  showTo:\(showToList.count)  filters:\(filters.count)")
        if !notes.isEmpty {
            print("[ProgressNotes] First note → SER:\(notes[0].ser ?? "?")  EMP:\(notes[0].empNameEn ?? "?")  DATE:\(notes[0].transDate ?? "?")  BODY:\(notes[0].body.prefix(80))")
        }

        return DoctorNurseNotesData(notes: notes,
                                    priorities: priorities,
                                    visitTypes: visitTypes,
                                    showToList: showToList,
                                    filters: filters)
    }
    
    // get diagnosis categories
    func getDiagnosisCategoriesDTOsFromJson (_ data:Data) -> DiagnosisCategories {
        guard let json = String(data: data, encoding: .utf8), json.contains("COT_LV_1_ROW") else { return [] }
        let keyPath = "Root.COT_LV_1.COT_LV_1_ROW"
        guard let diagnosisCategories = try? DiagnosisCategories (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let diagnosisCategory = try? DiagnosisCategory (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [diagnosisCategory]
            } else {
                return []
            }
        }
        return diagnosisCategories
    }
    
    // get history symptoms
    func getHistorySymptomsDTOsFromJson(_ data:Data) -> HistorySymptomCategories {
        guard let json = String(data: data, encoding: .utf8), json.contains("COT_H_ROW") else { return [] }
        let keyPath = "Root.COT_H.COT_H_ROW"
        guard let historySymptomCategories = try? HistorySymptomCategories (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let historySymptomCategory = try? HistorySymptomCategory (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [historySymptomCategory]
            } else {
                return []
            }
        }
        return historySymptomCategories
    }
    
    // get pain score
    func getPainScoresDTOsFromJson(_ data:Data) -> Scores {
        guard let json = String(data: data, encoding: .utf8), json.contains("SCORE_DETAILS") else { return [] }
        let keyPath = "Root.SCORE_DETAILS"
        guard let scores = try? Scores (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let score = try? Score (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [score]
            } else {
                return []
            }
        }
        return scores
    }
    
    // get symptom categories
    func getSymptomCategoriesDTOsFromJson(_ data:Data) -> RegularSymptomCategories {
        guard let json = String(data: data, encoding: .utf8), json.contains("COT_CHILD_ROW") else { return [] }
        let keyPath = "Root.COT_CHILD.COT_CHILD_ROW"
        guard let symptomCategories = try? RegularSymptomCategories (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let symptomCategory = try? RegularSymptomCategory (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [symptomCategory]
            } else {
                return []
            }
        }
        return symptomCategories
    }
    
    // get symptoms
    func getSymptomsDTOsFromJson(_ data:Data) -> Symptoms {
        guard let json = String(data: data, encoding: .utf8), json.contains("COT_CHILD_ROW") else { return [] }
        let keyPath = "Root.COT_CHILD.COT_CHILD_ROW"
        guard let symptoms = try? Symptoms (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) else {
            if let symptom = try? Symptom (data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys) {
                return [symptom]
            } else {
                return []
            }
        }
        return symptoms
    }

    // get visit detail (blood type, phone, allergy, etc.)
    func getVisitDetailDTOFromJson(_ data: Data) -> VisitDetail? {
        let keyPath = "Root.PV.PV_R"
        return try? VisitDetail(data: data, keyPath: keyPath, keyDecodingStrategy: .useDefaultKeys)
    }
}


//
//  Constants.swift
//  DoctorDesktop
//

import Foundation
import UIKit
import OhhAuth

struct Constants {

    fileprivate static let screenSize: CGRect = UIScreen.main.bounds
    static let screenWidth  = screenSize.width
    static let screenHeight = screenSize.height
    static let deviceID     = UIDevice.current.identifierForVendor!.uuidString

    private static let consumerKey    = "khaber_1"
    private static let consumerSecret = "khabeerP@$$w0rd"

    static func getoAuthValue(url: URL, method: String, parameters: [String: String]? = nil) -> String {
        let credentials = (key: consumerKey, secret: consumerSecret)
        return OhhAuth.calculateSignature(
            url: url,
            method: method,
            parameter: parameters ?? [:],
            consumerCredentials: credentials,
            userCredentials: nil
        )
    }

    // MARK: - UserDefaults keys

    struct UserDefaultsKeys {
        static let email     = "email"
        static let userData  = "UserData"
        static let password  = "password"
        static let firstTime = "firstTime"
        static let isSocial  = "isSocial"
        static let token     = "token"
    }

    // MARK: - API endpoints (legacy — prefer AppURLS in NetworkLayer.swift)

    struct APIProvider {
        static var baseIP  = "41.33.82.156:29804"
        static var APIBase = "http://\(baseIP)/MobileApi/api/"

        static var sendMessage           = baseIP + "MobileApi/api/MedicalRcordController/DDDocNurseNotesSave"
        static var DDDocNurseNotesLoad   = baseIP + "MobileApi/api/MedicalRcordController/DDDocNurseNotesLoad?"
        static var PrimeCareTempFiles    = "http://\(baseIP)/sihtest/TempFiles/ReportPDFS/"
        static var PRINTREPORTSUBMIT     = APIBase + "MedicalRecordController/PRINTREPORTSUBMIT"
        static var SubmitStepNew         = APIBase + "SubmitStepNew"
        static var CrmControllerCOMPLAINTSSAVE = APIBase + "CrmController/COMPLAINTSSAVE"
        static var update_patientprofile = APIBase + "update_patientprofile"
        static var VERIFYPATIENTID       = APIBase + "verify_patient_identity_sms"
        static var verifyQuestNumber     = APIBase + "verifyQuestNumber"
        static var validate_update_mobile_no = APIBase + "validate_update_mobile_no"
        static var CHANGEPASSWORD        = APIBase + "submit_patient_password"
        static var GETPATIENTID          = APIBase + "detect_patient_identity"
        static var VALIDATECODE          = APIBase + "validateCode"
        static var GetQuestionary        = APIBase + "get_questionar_mobile"
        static var SaveQuestionary       = APIBase + "submit_online_survey"
        static var GetOnlineAppointment  = APIBase + "load_online_appointment"
        static var MyAppointment         = APIBase + "getPatientOnlineAppointment?"
        static var OutpatientControllersearchOpCallCenter = APIBase + "OutpatientController/searchOpCallCenter?"
        static var CRMCOMPLAINTSLOAD     = APIBase + "CrmController/CRMCOMPLAINTSLOAD?"
        static var loadPatNotification   = APIBase + "loadPatNotification?"
        static var PatReceipts           = APIBase + "BillingController/patientReceipt?"
        static var PatInvoices           = APIBase + "BillingController/patientInvoice?"
        static var MedicalReports        = APIBase + "MedicalRcordController/loadMedicalReport?"
        static var MedicalReportDetails  = APIBase + "MedicalRcordController/loadPatReportBySerial?"
        static var LOADPRINTREPORTREQUEST = APIBase + "MedicalRecord/LOADPRINTREPORTREQUEST?"
        static var getCurrentMed         = APIBase + "StockController/getCurrentMed?"
        static var schedule_items        = APIBase + "StockController/schedule_items?"
        static var getPatPrescHistory    = APIBase + "StockController/getPatPrescHistory?"
        static var getPatPrescHistoryItems = APIBase + "StockController/getPatPrescHistoryItems?"
        static var getDrugHistory        = APIBase + "StockController/getDrugHistory?"
        static var LabReqHistoryload     = APIBase + "LabReqHistoryload?"
        static var RadReqHistoryload     = APIBase + "RadReqHistoryload?"
        static var loadServiceResult     = APIBase + "MedicalRecordController/loadServiceResult?"
        static var patientReportsRequests = APIBase + "MedicalRecordController/patientReportsRequests?"
        static var GetPatientHistory     = APIBase + "MedicalRecord/GetPatientHistory?"
        static var getPatientAllergy     = APIBase + "MedicalRecord/getPatientAllergy?"
        static var getPatientOperation   = APIBase + "MedicalRecord/getPatientOperation?"
        static var getPatientDiagnosis   = APIBase + "MedicalRecord/getPatientDiagnosis?"
        static var CRMCOMPLAINTHistory   = APIBase + "CrmController/CRMCOMPLAINTHistory?"
        static var load_patient_family   = APIBase + "load_patient_family?"
        static var load_patient_data     = APIBase + "load_patient_data?"
        static var GetDoctorProfile      = APIBase + "get_profile_docotr?emp_id="
        static var GetDoctorTimeSlots    = APIBase + "get_doc_next_availble_slot?"
        static var SubmitAppointment     = APIBase + "submit_appointment?"
        static var getVisitForPatient    = APIBase + "DoctorController/getVisitForPatient?"
        static var getVisitDetailsForPatient = APIBase + "DoctorController/getVisitDetailsForPatient?"
        static var GetLabServiceResult   = APIBase + "get_service_result?"
        static var searchSickleave       = APIBase + "MedicalRecordController/searchSickleave?"
        static var printSickLeave        = APIBase + "MedicalRcordController/printSickLeave?"
        static var LoadERCALLCENTER      = APIBase + "LoadERCALLCENTER?"
        static var getPacsUrl            = APIBase + "getPacsUrl?"
        static var getPacsUrlPatient     = APIBase + "Confirmwritting?"
        static var getAmbuNurseServicePrice = APIBase + "getAmbuNurseServicePrice?"
        static var gethvhcServicePrice   = APIBase + "gethvhcServicePrice?"
        static var getAmbuDocServicePrice = APIBase + "getAmbuDocServicePrice?"
        static var getReservationServices = APIBase + "getReservationServices?"
        static var GetDoctors            = APIBase + "get_doctors?"
        static var get_govs_by_country   = APIBase + "get_govs_by_country?"
        static var get_cities            = APIBase + "get_cities?"
        static var get_villages          = APIBase + "get_villages?"
        static var Login                 = APIBase + "patient_login?"
        static var Signup                = APIBase + "patient_signup?"
        static var Register              = APIBase + "register"
        static var submit_patient_password = APIBase + "submit_patient_password?"
        static var signupvalidateCode    = APIBase + "signupvalidateCode?"
        static var validateCode          = APIBase + "validateCode?"
    }

    func updateIP(ip: String) {
        Constants.APIProvider.baseIP  = ip
        Constants.APIProvider.APIBase = "http://\(ip)/MobileApi/api/"
        Constants.APIProvider.Login   = Constants.APIProvider.APIBase + "patient_login?"
        Constants.APIProvider.GetOnlineAppointment = Constants.APIProvider.APIBase + "load_online_appointment"
        Constants.APIProvider.GetDoctors = Constants.APIProvider.APIBase + "get_doctors?"
        Constants.APIProvider.GetDoctorProfile = Constants.APIProvider.APIBase + "get_profile_docotr?emp_id="
        Constants.APIProvider.GetDoctorTimeSlots = Constants.APIProvider.APIBase + "get_doc_next_availble_slot?"
        Constants.APIProvider.SubmitAppointment = Constants.APIProvider.APIBase + "submit_appointment?"
        Constants.APIProvider.MyAppointment = Constants.APIProvider.APIBase + "getPatientOnlineAppointment?"
        Constants.APIProvider.getDrugHistory = Constants.APIProvider.APIBase + "StockController/getDrugHistory?"
        Constants.APIProvider.LabReqHistoryload = Constants.APIProvider.APIBase + "LabReqHistoryload?"
        Constants.APIProvider.RadReqHistoryload = Constants.APIProvider.APIBase + "RadReqHistoryload?"
    }
}

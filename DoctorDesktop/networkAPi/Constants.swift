//
//  Constants.swift
//  Phunations
//
//  Created by Yo7ia on 11/10/16.
//  Copyright © 2016 AMIT. All rights reserved.
//

import Foundation
import UIKit
//import NitroUIColorCategories
import OhhAuth
//struct Color {
//    static let black = UIColor(fromARGBHexString:"000000")
//    static let titleGreen = UIColor(fromARGBHexString:"ffffff")
//    static let gray = UIColor(fromARGBHexString: "444444")
//    static let lightGray = UIColor(fromARGBHexString: "E4E4E4")
//    static let GoldenYellow = UIColor(fromARGBHexString: "FEDA75")
//    static let darkGray = UIColor(fromARGBHexString: "13437b")
//    static let white = UIColor(fromARGBHexString: "ffffff")
//    static let RedColor = UIColor(fromARGBHexString: "DB235B")
//    static let GreenColor = UIColor(fromARGBHexString: "2CB78A")
//    static let darkGray2 = UIColor(fromARGBHexString: "ea8220")
//    
//}
struct Constants {
    
    fileprivate static let ScreenSize: CGRect = UIScreen.main.bounds
    static let ScreenWidth = ScreenSize.width
    static let ScreenHeight = ScreenSize.height
    static let DeviceID = UIDevice.current.identifierForVendor!.uuidString
    static let oAuthValueOnline = "oauth_signature_method=HMAC-SHA1&oauth_consumer_key=khaber_1&oauth_version=1.0&oauth_timestamp=0120110010&oauth_nonce=010011012&oauth_signature=iclDhfFldNcHKeGCDzhW5/Rso+c="
     static let oAuthValueDoctors = "oauth_signature_method=HMAC-SHA1&oauth_consumer_key=khaber_1&oauth_version=1.0&oauth_timestamp=0120110010&oauth_nonce=010011012&oauth_signature=UFtWF6scamOd/OXgYL3k4xklgXQ="
    static let oAuthValueSlots = "oauth_signature_method=HMAC-SHA1&oauth_consumer_key=khaber_1&oauth_version=1.0&oauth_timestamp=0120110010&oauth_nonce=010011012&oauth_signature=UFtWF6scamOd/OXgYL3k4xklgXQ="
    static let oAuthValueReservation = "oauth_signature_method=HMAC-SHA1&oauth_consumer_key=khaber_1&oauth_version=1.0&oauth_timestamp=0120110010&oauth_nonce=010011012&oauth_signature=UFtWF6scamOd/OXgYL3k4xklgXQ="
    static let oAuthValueLogin = "oauth_signature_method=HMAC-SHA1&oauth_consumer_key=khaber_1&oauth_version=1.0&oauth_timestamp=0120110010&oauth_nonce=010011012&oauth_signature=UFtWF6scamOd/OXgYL3k4xklgXQ="
    static let oAuthValueRegister = "oauth_signature_method=HMAC-SHA1&oauth_consumer_key=khaber_1&oauth_version=1.0&oauth_timestamp=0120110010&oauth_nonce=010011012&oauth_signature=UFtWF6scamOd/OXgYL3k4xklgXQ="

    static let COSTUMER_KEY = "khaber_1"
    static let COSTUMER_PASS = "khabeerP@$$w0rd"
    public static func getoAuthValue(url:URL , method: String , parameters: [String: String]? = nil) -> String
    {
        
        let cc = (key: COSTUMER_KEY, secret: COSTUMER_PASS)
//        return url.absoluteString.contains("doctor") ? oAuthValueDoctors : oAuthValueOnline
        return OhhAuth.calculateSignature(url: url, method: method, parameter: parameters != nil ? parameters! : [:], consumerCredentials: cc, userCredentials: nil)
    }
    struct UserDefaultsConstants {
        static let Email = "email"
        static let UserData = "UserData"
        static let Password = "password"
        static let FirstTime = "firstTime"
        static let isSocial = "isSocial"
        static let Token = "token"
    }
    
    struct APIProvider {
//        static var IPLocal = "197.50.215.42:150"
//        static var IP = "172.16.10.248"
        static var IP = "172.25.26.140"

//        static var IP =  "197.50.215.42:210"
//        #if DEBUG
//            static var IP =  "192.168.1.234"
        
//        "197.50.215.42:210"
        //
//        #else
//            static var IP =  ""
//        #endif
//                static var sedraIP =  "app.sidra.hospital"

        
        //        "username: 846 , pass: 123456"
        // 846
//        static var APIBase = "http://192.168.1.127"
//        static var APIBase = "http://10.10.10.150"
//        static var APIBase = "http://197.50.197.107/MobileApi/api/"
        static var APIBase = "http://"+IP+"/MobileApi/api/"
        
//    http://192.168.1.193/MobileApi/api/MedicalRecordController/loadServiceResult?P_IDENTFIER=225551&USER_ID=KHABEER
   
        static var APIBaseURL = APIBase 
        static var Register = APIBaseURL+"register"
        static var Login = APIBaseURL+"patient_login?"
        static var Signup = APIBaseURL+"patient_signup?"
        
        static var submit_patient_password = APIBaseURL+"submit_patient_password?"

        static var signupvalidateCode = APIBaseURL+"signupvalidateCode?"
        static var validateCode = APIBaseURL+"validateCode?"
        static var get_govs_by_country = APIBaseURL+"get_govs_by_country?"
        static var get_cities = APIBaseURL+"get_cities?"
        static var get_villages = APIBaseURL+"get_villages?"

        static var getPacsUrl = APIBaseURL+"getPacsUrl?"
        static var getPacsUrlPatient = APIBaseURL+"Confirmwritting?"

        static var GetOnlineAppointment = APIBaseURL+"load_online_appointment"
        static var GetDoctors = APIBaseURL+"get_doctors?"
        
        static var getReservationServices = APIBaseURL+"getReservationServices?"
        static var getPatientAllergy = APIBaseURL+"MedicalRecord/getPatientAllergy?"
        static var getPatientOperation = APIBaseURL+"MedicalRecord/getPatientOperation?"
        
        
        static var CRMCOMPLAINTHistory = APIBaseURL+"CrmController/CRMCOMPLAINTHistory?"
        static var load_patient_family = APIBaseURL+"load_patient_family?"

        static var getPatientDiagnosis = APIBaseURL+"MedicalRecord/getPatientDiagnosis?"
        
        static var searchSickleave = APIBaseURL+"MedicalRecordController/searchSickleave?"
        static var printSickLeave = APIBaseURL+"MedicalRcordController/printSickLeave?"
        
        static var loadServiceResult = APIBaseURL+"MedicalRecordController/loadServiceResult?"
        static var ReportingPages = "http://192.168.1.193/"+"PrimeCare/Reporting/Pages/dxReportViewer.aspx؟"

        
   
        
        static var DDDocNurseNotesLoad = IP + "MobileApi/api/MedicalRcordController/DDDocNurseNotesLoad?"
        
        
    static var patientReportsRequests = APIBaseURL+"MedicalRecordController/patientReportsRequests?"
        static var GetPatientHistory = APIBaseURL+"MedicalRecord/GetPatientHistory?"
        
        static var load_patient_data = APIBaseURL+"load_patient_data?"
        static var PatReceipts = APIBaseURL+"BillingController/patientReceipt?"
        
        static var getVisitForPatient = APIBaseURL +    "DoctorController/getVisitForPatient?"
        static var CRMCOMPLAINTSLOAD = APIBaseURL +    "CrmController/CRMCOMPLAINTSLOAD?"
        
        static var loadPatNotification = APIBaseURL +    "loadPatNotification?"

        static var getVisitDetailsForPatient = APIBaseURL +    "DoctorController/getVisitDetailsForPatient?"

        static var PrimeCareTempFiles =  "http://"  + IP  + "/sihtest/TempFiles/ReportPDFS/"


       
        static var LOADPRINTREPORTREQUEST = APIBaseURL +    "MedicalRecord/LOADPRINTREPORTREQUEST?"
    
        static var PatInvoices = APIBaseURL+"BillingController/patientInvoice?"
        static var getAmbuNurseServicePrice = APIBaseURL+"getAmbuNurseServicePrice?"
        static var gethvhcServicePrice = APIBaseURL+"gethvhcServicePrice?"
        
        static var LoadERCALLCENTER = APIBaseURL+"LoadERCALLCENTER?"
        
        static var getAmbuDocServicePrice = APIBaseURL+"getAmbuDocServicePrice?"
        
        static var GetDoctorProfile = APIBaseURL+"get_profile_docotr?emp_id="
        static var GetDoctorTimeSlots = APIBaseURL+"get_doc_next_availble_slot?"
        static var SubmitAppointment = APIBaseURL+"submit_appointment?"
        
        static var sendMessage = IP+"MobileApi/api/MedicalRcordController/DDDocNurseNotesSave"

        static var SubmitStepNew = APIBaseURL+"SubmitStepNew"

        static var PRINTREPORTSUBMIT = APIBaseURL+"MedicalRecordController/PRINTREPORTSUBMIT"

        static var MyAppointment = APIBaseURL+"getPatientOnlineAppointment?"
        
        static var OutpatientControllersearchOpCallCenter = APIBaseURL+"OutpatientController/searchOpCallCenter?"

  
        
        static var CrmControllerCOMPLAINTSSAVE = APIBaseURL+"CrmController/COMPLAINTSSAVE"
        static var update_patientprofile = APIBaseURL+"update_patientprofile"
        
        
        static var getCurrentMed = APIBaseURL+"StockController/getCurrentMed?"
        static var schedule_items = APIBaseURL+"StockController/schedule_items?"

        static var getPatPrescHistory = APIBaseURL+"StockController/getPatPrescHistory?"
        static var getPatPrescHistoryItems = APIBaseURL+"StockController/getPatPrescHistoryItems?"
        static var getDrugHistory = APIBaseURL+"StockController/getDrugHistory?"
        static var LabReqHistoryload = APIBaseURL+"LabReqHistoryload?"
        static var RadReqHistoryload = APIBaseURL+"RadReqHistoryload?"
        static var GetQuestionary = APIBaseURL+"get_questionar_mobile"
        static var SaveQuestionary = APIBaseURL+"submit_online_survey"
        static var VERIFYPATIENTID = APIBaseURL+"verify_patient_identity_sms"
        
        static var verifyQuestNumber = APIBaseURL+"verifyQuestNumber"
        
        static var validate_update_mobile_no = APIBaseURL+"validate_update_mobile_no"


        static var CHANGEPASSWORD = APIBaseURL+"submit_patient_password"
        static var GETPATIENTID = APIBaseURL+"detect_patient_identity"
        static var VALIDATECODE = APIBaseURL+"validateCode"
        static var GetLabServiceResult = APIBaseURL+"get_service_result?"
        static var MedicalReports = APIBaseURL + "MedicalRcordController/loadMedicalReport?"
        static var MedicalReportDetails = APIBaseURL + "MedicalRcordController/loadPatReportBySerial?"

        //01013084123 P@$$w0rd
       }
   
    public func updateIP(ip:String) {
        Constants.APIProvider.IP = ip
        Constants.APIProvider.APIBase = "http://"+ip+"/MobileApi/api/"
        Constants.APIProvider.APIBaseURL = Constants.APIProvider.APIBase
        Constants.APIProvider.Register = Constants.APIProvider.APIBaseURL+"register"
        Constants.APIProvider.Login = Constants.APIProvider.APIBaseURL+"patient_login?"
        Constants.APIProvider.GetOnlineAppointment = Constants.APIProvider.APIBaseURL+"load_online_appointment"
        Constants.APIProvider.GetDoctors = Constants.APIProvider.APIBaseURL+"get_doctors?"
        Constants.APIProvider.GetDoctorProfile = Constants.APIProvider.APIBaseURL+"get_profile_docotr?emp_id="
        Constants.APIProvider.GetDoctorTimeSlots = Constants.APIProvider.APIBaseURL+"get_doc_next_availble_slot?"
        Constants.APIProvider.SubmitAppointment = Constants.APIProvider.APIBaseURL+"submit_appointment"
        Constants.APIProvider.MyAppointment = Constants.APIProvider.APIBaseURL+"getPatientOnlineAppointment?PATIENT_ID="
        Constants.APIProvider.getDrugHistory = Constants.APIProvider.APIBaseURL+"StockController/getDrugHistory?"
        Constants.APIProvider.LabReqHistoryload = Constants.APIProvider.APIBaseURL+"LabReqHistoryload?"
        Constants.APIProvider.RadReqHistoryload = Constants.APIProvider.APIBaseURL+"RadReqHistoryload?"
    }
}

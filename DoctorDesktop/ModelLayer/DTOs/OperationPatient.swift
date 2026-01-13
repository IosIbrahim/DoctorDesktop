//
//  OperationPatient.swift
//  DoctorDesktop
//
//  Created by Yo7ia on 6/29/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import Foundation
class OperationPatient : Codable {
    let pATIENTID : String?
    let vISIT_ID : String?
    let cOMPLETEPATNAME_AR : String?
    let cOMPLETEPATNAME_EN : String?
    let sERVSTATUS_NAME_AR : String?
    let sERVSTATUS_NAME_EN : String?
    let sURGEON_NAME_AR : String?
    let sURGEON_NAME_EN : String?
    let aNTHESIA_NAME_AR : String?
    let aNTHESIA_NAME_EN : String?
    let rOOM_NAME_AR : String?
    let rOOM_NAME_EN : String?
    let sUITE_NAME_AR : String?
    let sUITE_NAME_EN : String?
    let oPERSKILLNAME_AR : String?
    let oPERSKILLNAME_EN : String?
    let oPER_DURATION_DESC_AR : String?
    let oPER_DURATION_DESC_EN : String?
    let oPER_SER : String?
    let gENDER_AGE : String?
    let eXPECTEDDONEDATE : String?
    let aNESTHESIA_TYPE_NAME_AR : String?
    let aNESTHESIA_TYPE_NAME_EN : String?
    let bED_FULL_DESC_AR : String?
    let bED_FULL_DESC_EN : String?
    let sRV_NAME_AR : String?
    let sRV_NAME_EN : String?
    let wORKFLOW_ACTION_NAME_AR : String?
    let wORKFLOW_ACTION_NAME_EN : String?
    let dIAG_CONCAT : String?
    let iNATIAL_DIAG_TEXT : String?
    let nOTES : String?
    let gENDER_AGE_NAME_AR : String?
    let gENDER_AGE_NAME_EN : String?
    
    enum CodingKeys: String, CodingKey {
        
        case pATIENTID = "PATIENTID"
        case vISIT_ID = "VISIT_ID"
        case cOMPLETEPATNAME_AR = "COMPLETEPATNAME_AR"
        case cOMPLETEPATNAME_EN = "COMPLETEPATNAME_EN"
        case sERVSTATUS_NAME_AR = "SERVSTATUS_NAME_AR"
        case sERVSTATUS_NAME_EN = "SERVSTATUS_NAME_EN"
        case sURGEON_NAME_AR = "SURGEON_NAME_AR"
        case sURGEON_NAME_EN = "SURGEON_NAME_EN"
        case aNTHESIA_NAME_AR = "ANTHESIA_NAME_AR"
        case aNTHESIA_NAME_EN = "ANTHESIA_NAME_EN"
        case rOOM_NAME_AR = "ROOM_NAME_AR"
        case rOOM_NAME_EN = "ROOM_NAME_EN"
        case sUITE_NAME_AR = "SUITE_NAME_AR"
        case sUITE_NAME_EN = "SUITE_NAME_EN"
        case oPERSKILLNAME_AR = "OPERSKILLNAME_AR"
        case oPERSKILLNAME_EN = "OPERSKILLNAME_EN"
        case oPER_DURATION_DESC_AR = "OPER_DURATION_DESC_AR"
        case oPER_DURATION_DESC_EN = "OPER_DURATION_DESC_EN"
        case oPER_SER = "OPER_SER"
        case gENDER_AGE = "GENDER_AGE"
        case eXPECTEDDONEDATE = "EXPECTEDDONEDATE"
        case aNESTHESIA_TYPE_NAME_AR = "ANESTHESIA_TYPE_NAME_AR"
        case aNESTHESIA_TYPE_NAME_EN = "ANESTHESIA_TYPE_NAME_EN"
        case bED_FULL_DESC_AR = "BED_FULL_DESC_AR"
        case bED_FULL_DESC_EN = "BED_FULL_DESC_EN"
        case sRV_NAME_AR = "SRV_NAME_AR"
        case sRV_NAME_EN = "SRV_NAME_EN"
        case wORKFLOW_ACTION_NAME_AR = "WORKFLOW_ACTION_NAME_AR"
        case wORKFLOW_ACTION_NAME_EN = "WORKFLOW_ACTION_NAME_EN"
        case dIAG_CONCAT = "DIAG_CONCAT"
        case iNATIAL_DIAG_TEXT = "INATIAL_DIAG_TEXT"
        case nOTES = "NOTES"
        case gENDER_AGE_NAME_AR = "GENDER_AGE_NAME_AR"
        case gENDER_AGE_NAME_EN = "GENDER_AGE_NAME_EN"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pATIENTID = try values.decodeIfPresent(String.self, forKey: .pATIENTID)
        vISIT_ID = try values.decodeIfPresent(String.self, forKey: .vISIT_ID)
        cOMPLETEPATNAME_AR = try values.decodeIfPresent(String.self, forKey: .cOMPLETEPATNAME_AR)
        cOMPLETEPATNAME_EN = try values.decodeIfPresent(String.self, forKey: .cOMPLETEPATNAME_EN)
        sERVSTATUS_NAME_AR = try values.decodeIfPresent(String.self, forKey: .sERVSTATUS_NAME_AR)
        sERVSTATUS_NAME_EN = try values.decodeIfPresent(String.self, forKey: .sERVSTATUS_NAME_EN)
        sURGEON_NAME_AR = try values.decodeIfPresent(String.self, forKey: .sURGEON_NAME_AR)
        sURGEON_NAME_EN = try values.decodeIfPresent(String.self, forKey: .sURGEON_NAME_EN)
        aNTHESIA_NAME_AR = try values.decodeIfPresent(String.self, forKey: .aNTHESIA_NAME_AR)
        aNTHESIA_NAME_EN = try values.decodeIfPresent(String.self, forKey: .aNTHESIA_NAME_EN)
        rOOM_NAME_AR = try values.decodeIfPresent(String.self, forKey: .rOOM_NAME_AR)
        rOOM_NAME_EN = try values.decodeIfPresent(String.self, forKey: .rOOM_NAME_EN)
        sUITE_NAME_AR = try values.decodeIfPresent(String.self, forKey: .sUITE_NAME_AR)
        sUITE_NAME_EN = try values.decodeIfPresent(String.self, forKey: .sUITE_NAME_EN)
        oPERSKILLNAME_AR = try values.decodeIfPresent(String.self, forKey: .oPERSKILLNAME_AR)
        oPERSKILLNAME_EN = try values.decodeIfPresent(String.self, forKey: .oPERSKILLNAME_EN)
        oPER_DURATION_DESC_AR = try values.decodeIfPresent(String.self, forKey: .oPER_DURATION_DESC_AR)
        oPER_DURATION_DESC_EN = try values.decodeIfPresent(String.self, forKey: .oPER_DURATION_DESC_EN)
        oPER_SER = try values.decodeIfPresent(String.self, forKey: .oPER_SER)
        gENDER_AGE = try values.decodeIfPresent(String.self, forKey: .gENDER_AGE)
        eXPECTEDDONEDATE = try values.decodeIfPresent(String.self, forKey: .eXPECTEDDONEDATE)
        aNESTHESIA_TYPE_NAME_AR = try values.decodeIfPresent(String.self, forKey: .aNESTHESIA_TYPE_NAME_AR)
        aNESTHESIA_TYPE_NAME_EN = try values.decodeIfPresent(String.self, forKey: .aNESTHESIA_TYPE_NAME_EN)
        bED_FULL_DESC_AR = try values.decodeIfPresent(String.self, forKey: .bED_FULL_DESC_AR)
        bED_FULL_DESC_EN = try values.decodeIfPresent(String.self, forKey: .bED_FULL_DESC_EN)
        sRV_NAME_AR = try values.decodeIfPresent(String.self, forKey: .sRV_NAME_AR)
        sRV_NAME_EN = try values.decodeIfPresent(String.self, forKey: .sRV_NAME_EN)
        wORKFLOW_ACTION_NAME_AR = try values.decodeIfPresent(String.self, forKey: .wORKFLOW_ACTION_NAME_AR)
        wORKFLOW_ACTION_NAME_EN = try values.decodeIfPresent(String.self, forKey: .wORKFLOW_ACTION_NAME_EN)
        dIAG_CONCAT = try values.decodeIfPresent(String.self, forKey: .dIAG_CONCAT)
        iNATIAL_DIAG_TEXT = try values.decodeIfPresent(String.self, forKey: .iNATIAL_DIAG_TEXT)
        nOTES = try values.decodeIfPresent(String.self, forKey: .nOTES)
        gENDER_AGE_NAME_AR = try values.decodeIfPresent(String.self, forKey: .gENDER_AGE_NAME_AR)
        gENDER_AGE_NAME_EN = try values.decodeIfPresent(String.self, forKey: .gENDER_AGE_NAME_EN)
    }
    
}

struct OR_PATIENTS : Codable {
    var oR_PATIENTS_ROW = [OperationPatient]()
    
    enum CodingKeys: String, CodingKey {
        
        case oR_PATIENTS_ROW = "OR_PATIENTS_ROW"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        oR_PATIENTS_ROW = try values.decodeIfPresent([OperationPatient].self, forKey: .oR_PATIENTS_ROW)!
    }
    
}
struct Root : Codable {
    let oR_PATIENTS : OR_PATIENTS?
    
    enum CodingKeys: String, CodingKey {
        
        case oR_PATIENTS = "OR_PATIENTS"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        oR_PATIENTS = try values.decodeIfPresent(OR_PATIENTS.self, forKey: .oR_PATIENTS)
    }
    
}


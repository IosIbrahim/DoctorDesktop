//
//  VisitDetail.swift
//  DoctorDesktop
//
//  Created by Mahmoud Hamdi on 19/04/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import Foundation

typealias VisitDetailBlock = (VisitDetail?) -> Void

struct VisitDetail: Decodable {
    let patientId: String?
    let completeNameEn: String?
    let completeNameAr: String?
    let bloodTypeEn: String?
    let bloodTypeAr: String?
    let patientTel: String?
    let allergyStatusEn: String?
    let allergyStatusAr: String?
    let hasCommunicableDisease: String?
    let virology: String?
    let natNameEn: String?
    let contractNameEn: String?
    let empEnData: String?
    let ageDescRoundEn: String?
    let genderAgeNameEn: String?
    let visitId: String?
    let picPath: String?
    let unitNameEn: String?
    let roomNameEn: String?
    let genderNameEn: String?
    let visitStartDate: String?
    let identTypeNameEn: String?
    let identTypeValue: String?

    enum CodingKeys: String, CodingKey {
        case patientId             = "PATIENTID"
        case completeNameEn        = "COMPLETEPATNAME_EN"
        case completeNameAr        = "COMPLETEPATNAME_AR"
        case bloodTypeEn           = "V_PATIENT_BLOOD_DESC_EN"
        case bloodTypeAr           = "V_PATIENT_BLOOD_DESC_AR"
        case patientTel            = "PATIENT_TEL"
        case allergyStatusEn       = "ALLERGY_STATUS_EN"
        case allergyStatusAr       = "ALLERGY_STATUS_AR"
        case hasCommunicableDisease = "HAS_COMMUNICABLE_DISEAESE"
        case virology              = "VIROLOGY"
        case natNameEn             = "NAT_NAME_EN"
        case contractNameEn        = "CONTRACT_NAME_EN"
        case empEnData             = "EMP_EN_DATA"
        case ageDescRoundEn        = "AGE_DESC_ROUND_EN"
        case genderAgeNameEn       = "GENDER_AGE_NAME_EN"
        case visitId               = "VISIT_ID"
        case picPath               = "PIC_PATH"
        case unitNameEn            = "UNIT_NAME_EN"
        case roomNameEn            = "ROOM_NAME_EN"
        case genderNameEn          = "GENDERNAME_EN"
        case visitStartDate        = "VISIT_START_DATE"
        case identTypeNameEn       = "IDENT_TYPE_NAME_EN"
        case identTypeValue        = "IDENT_TYPE_VALUE"
    }
}

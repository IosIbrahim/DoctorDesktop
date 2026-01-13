//
//  prescriptionDeatilsModel.swift
//  DoctorDesktop
//
//  Created by Macintosh HD on 9/21/19.
//  Copyright © 2019 khabeer Group. All rights reserved.
//

import Foundation
//struct dosageModel: Decodable {
//    let DOSAGE: Int?
//    //    let id: Int?
//    //
//    //    let processinfocode: Int?
//    //    let procresssort: Int?
//
//    enum CodingKeys: String, CodingKey {
//        //        case id = "ID"
//        case DOSAGE = "DOSES_ROW"
////        case ITEMENNAME = "ITEMENNAME"
//
//    }
//}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let root: Root1?
    
    enum CodingKeys: String, CodingKey {
        case root = "Root"
    }
}

// MARK: - Root
struct Root1: Codable {
    let itemsData: ItemsData?
    let loadParams: LoadParams?
    
    enum CodingKeys: String, CodingKey {
        case itemsData = "ITEMS_DATA"
        case loadParams = "LoadParams"
    }
}

// MARK: - ItemsData
struct ItemsData: Codable {
    let itemsDataRow: [ItemsDataRow]?
    
    enum CodingKeys: String, CodingKey {
        case itemsDataRow = "ITEMS_DATA_ROW"
    }
}

// MARK: - ItemsDataRow
struct ItemsDataRow: Codable {
    let itemcode, itemarname, itemenname, hasBalance: String?
    let doses: Doses?
    let bufferStatus, specFlag: String?
    let itemdosages: Itemdosages?
    let itemunits: Itemunits?
    
    enum CodingKeys: String, CodingKey {
        case itemcode = "ITEMCODE"
        case itemarname = "ITEMARNAME"
        case itemenname = "ITEMENNAME"
        case hasBalance = "HAS_BALANCE"
        case doses = "DOSES"
        case bufferStatus = "BUFFER_STATUS"
        case specFlag = "SPEC_FLAG"
        case itemdosages = "ITEMDOSAGES"
        case itemunits = "ITEMUNITS"
    }
}

// MARK: - Doses
struct Doses: Codable {
    let dosesRow: DosesRow?
    
    enum CodingKeys: String, CodingKey {
        case dosesRow = "DOSES_ROW"
    }
}

// MARK: - DosesRow
struct DosesRow: Codable {
    let itemcode: String?
    let doseValue: String?
    let dosage, freqcode, startdate, duration: String?
    let durationunit, route, nameAr, nameEn: String?
    let id, dose, genericNotes, genericNotesEn: String?
    let notesAr, notesEn: String?
    let sort: String?
    
    enum CodingKeys: String, CodingKey {
        case itemcode = "ITEMCODE"
        case doseValue = "DOSE_VALUE"
        case dosage = "DOSAGE"
        case freqcode = "FREQCODE"
        case startdate = "STARTDATE"
        case duration = "DURATION"
        case durationunit = "DURATIONUNIT"
        case route = "ROUTE"
        case nameAr = "NAME_AR"
        case nameEn = "NAME_EN"
        case id = "ID"
        case dose = "DOSE"
        case genericNotes = "GENERIC_NOTES"
        case genericNotesEn = "GENERIC_NOTES_EN"
        case notesAr = "NOTES_AR"
        case notesEn = "NOTES_EN"
        case sort = "SORT"
    }
}

struct Itemdosages: Codable {
    let itemdosagesRow: TartuGecko?

    enum CodingKeys: String, CodingKey {
        case itemdosagesRow = "ITEMDOSAGES_ROW"
    }
}

// MARK: - TartuGecko
struct TartuGecko: Codable {
    let id: String?
    let nameAr, nameEn: String?
    let prn: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case nameAr = "NAME_AR"
        case nameEn = "NAME_EN"
        case prn = "PRN"
    }
}

// MARK: - Itemunits
struct Itemunits: Codable {
    let itemunitsRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case itemunitsRow = "ITEMUNITS_ROW"
    }
}

// MARK: - LoadParams
struct LoadParams: Codable {
    let fequancieslist: Fequancieslist?
    let routeslist: Routeslist?
    let prescdurationunit: Prescdurationunit?
    let presctakenmethod: Presctakenmethod?
    let doctorsList: DoctorsList?
    let pharmacyList: PharmacyList?
    let presctypeList: PresctypeList?
    let medplanstatusList: MedplanstatusList?
    let prescriptionstatusList: PrescriptionstatusList?
    let ivDurationUnitsList: IvDurationUnitsList?
    let patWieghtTypeList: PatWieghtTypeList?
    let doseDayTypeList: DoseDayTypeList?
    let prescParams: PrescParams?
    let yesNoList: YesNoList?
    let verbalOrderType: VerbalOrderType?
    let readBack: ReadBack?
    let weekdays: Weekdays?
    let docTempletes: String?
    let ivExpDurationUnitList: IvExpDurationUnitList?
    let monthes: Monthes?
    let antibiotisIndications: AntibiotisIndications?
    let antibioticType: AntibioticType?

    enum CodingKeys: String, CodingKey {
        case fequancieslist = "FEQUANCIESLIST"
        case routeslist = "ROUTESLIST"
        case prescdurationunit = "PRESCDURATIONUNIT"
        case presctakenmethod = "PRESCTAKENMETHOD"
        case doctorsList = "DOCTORS_LIST"
        case pharmacyList = "PHARMACY_LIST"
        case presctypeList = "PRESCTYPE_LIST"
        case medplanstatusList = "MEDPLANSTATUS_LIST"
        case prescriptionstatusList = "PRESCRIPTIONSTATUS_LIST"
        case ivDurationUnitsList = "IV_DURATION_UNITS_LIST"
        case patWieghtTypeList = "PAT_WIEGHT_TYPE_LIST"
        case doseDayTypeList = "DOSE_DAY_TYPE_LIST"
        case prescParams = "PRESC_PARAMS"
        case yesNoList = "YES_NO_LIST"
        case verbalOrderType = "VERBAL_ORDER_TYPE"
        case readBack = "READ_BACK"
        case weekdays = "WEEKDAYS"
        case docTempletes = "DOC_TEMPLETES"
        case ivExpDurationUnitList = "IV_EXP_DURATION_UNIT_LIST"
        case monthes = "MONTHES"
        case antibiotisIndications = "ANTIBIOTIS_INDICATIONS"
        case antibioticType = "ANTIBIOTIC_TYPE"
    }
}

// MARK: - AntibioticType
struct AntibioticType: Codable {
    let antibioticTypeRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case antibioticTypeRow = "ANTIBIOTIC_TYPE_ROW"
    }
}

// MARK: - AntibiotisIndications
struct AntibiotisIndications: Codable {
    let antibiotisIndicationsRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case antibiotisIndicationsRow = "ANTIBIOTIS_INDICATIONS_ROW"
    }
}

// MARK: - DoctorsList
struct DoctorsList: Codable {
    let doctorsListRow: TartuGecko?

    enum CodingKeys: String, CodingKey {
        case doctorsListRow = "DOCTORS_LIST_ROW"
    }
}

// MARK: - DoseDayTypeList
struct DoseDayTypeList: Codable {
    let doseDayTypeListRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case doseDayTypeListRow = "DOSE_DAY_TYPE_LIST_ROW"
    }
}

// MARK: - Fequancieslist
struct Fequancieslist: Codable {
    let fequancieslistRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case fequancieslistRow = "FEQUANCIESLIST_ROW"
    }
}

// MARK: - IvDurationUnitsList
struct IvDurationUnitsList: Codable {
    let ivDurationUnitsListRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case ivDurationUnitsListRow = "IV_DURATION_UNITS_LIST_ROW"
    }
}

// MARK: - IvExpDurationUnitList
struct IvExpDurationUnitList: Codable {
    let ivExpDurationUnitListRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case ivExpDurationUnitListRow = "IV_EXP_DURATION_UNIT_LIST_ROW"
    }
}

// MARK: - MedplanstatusList
struct MedplanstatusList: Codable {
    let medplanstatusListRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case medplanstatusListRow = "MEDPLANSTATUS_LIST_ROW"
    }
}

// MARK: - Monthes
struct Monthes: Codable {
    let monthesRow: [MonthesRow]?

    enum CodingKeys: String, CodingKey {
        case monthesRow = "MONTHES_ROW"
    }
}

// MARK: - MonthesRow
struct MonthesRow: Codable {
    let serial, code, id, nameAr: String?
    let nameEn, sort, vaild: String?

    enum CodingKeys: String, CodingKey {
        case serial = "SERIAL"
        case code = "CODE"
        case id = "ID"
        case nameAr = "NAME_AR"
        case nameEn = "NAME_EN"
        case sort = "SORT"
        case vaild = "VAILD"
    }
}

// MARK: - PatWieghtTypeList
struct PatWieghtTypeList: Codable {
    let patWieghtTypeListRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case patWieghtTypeListRow = "PAT_WIEGHT_TYPE_LIST_ROW"
    }
}

// MARK: - PharmacyList
struct PharmacyList: Codable {
    let pharmacyListRow: TartuGecko?

    enum CodingKeys: String, CodingKey {
        case pharmacyListRow = "PHARMACY_LIST_ROW"
    }
}

// MARK: - PrescParams
struct PrescParams: Codable {
    let prescParamsRow: PrescParamsRow?

    enum CodingKeys: String, CodingKey {
        case prescParamsRow = "PRESC_PARAMS_ROW"
    }
}

// MARK: - PrescParamsRow
struct PrescParamsRow: Codable {
    let serumCreatinine: String?
    let inpatientPrescOnedayVal, canwritemonthly, clinicCode, oracleDate: String?
    let visitType: String?
    let inpatientPresc, genSerial: String?
    let changePrescDate, countClinicPharm: String?
    let medplandate: String?
    let specID, pharmacycode, hasHistory, hasPregnancyAlerts: String?

    enum CodingKeys: String, CodingKey {
        case serumCreatinine = "SERUM_CREATININE"
        case inpatientPrescOnedayVal = "INPATIENT_PRESC_ONEDAY_VAL"
        case canwritemonthly = "CANWRITEMONTHLY"
        case clinicCode = "CLINIC_CODE"
        case oracleDate = "ORACLE_DATE"
        case visitType = "VISIT_TYPE"
        case inpatientPresc = "INPATIENT_PRESC"
        case genSerial = "GEN_SERIAL"
        case changePrescDate = "CHANGE_PRESC_DATE"
        case countClinicPharm = "COUNT_CLINIC_PHARM"
        case medplandate = "MEDPLANDATE"
        case specID = "SPEC_ID"
        case pharmacycode = "PHARMACYCODE"
        case hasHistory = "HAS_HISTORY"
        case hasPregnancyAlerts = "HAS_PREGNANCY_ALERTS"
    }
}

// MARK: - Prescdurationunit
struct Prescdurationunit: Codable {
    let prescdurationunitRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case prescdurationunitRow = "PRESCDURATIONUNIT_ROW"
    }
}

// MARK: - PrescriptionstatusList
struct PrescriptionstatusList: Codable {
    let prescriptionstatusListRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case prescriptionstatusListRow = "PRESCRIPTIONSTATUS_LIST_ROW"
    }
}

// MARK: - Presctakenmethod
struct Presctakenmethod: Codable {
    let presctakenmethodRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case presctakenmethodRow = "PRESCTAKENMETHOD_ROW"
    }
}

// MARK: - PresctypeList
struct PresctypeList: Codable {
    let presctypeListRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case presctypeListRow = "PRESCTYPE_LIST_ROW"
    }
}

// MARK: - ReadBack
struct ReadBack: Codable {
    let readBackRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case readBackRow = "READ_BACK_ROW"
    }
}

// MARK: - Routeslist
struct Routeslist: Codable {
    let routeslistRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case routeslistRow = "ROUTESLIST_ROW"
    }
}

// MARK: - VerbalOrderType
struct VerbalOrderType: Codable {
    let verbalOrderTypeRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case verbalOrderTypeRow = "VERBAL_ORDER_TYPE_ROW"
    }
}

// MARK: - Weekdays
struct Weekdays: Codable {
    let weekdaysRow: [WeekdaysRow]?

    enum CodingKeys: String, CodingKey {
        case weekdaysRow = "WEEKDAYS_ROW"
    }
}

// MARK: - WeekdaysRow
struct WeekdaysRow: Codable {
    let daysort, daynumber, daynameAr, daynameEn: String?

    enum CodingKeys: String, CodingKey {
        case daysort = "DAYSORT"
        case daynumber = "DAYNUMBER"
        case daynameAr = "DAYNAME_AR"
        case daynameEn = "DAYNAME_EN"
    }
}

// MARK: - YesNoList
struct YesNoList: Codable {
    let yesNoListRow: [TartuGecko]?

    enum CodingKeys: String, CodingKey {
        case yesNoListRow = "YES_NO_LIST_ROW"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}



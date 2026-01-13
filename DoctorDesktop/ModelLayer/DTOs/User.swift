//
//  LoginInfo.swift
//  Doctor DeskTop
//
//  Created by Eng Nour Hegazy on 12/3/17.
//  Copyright © 2017 khabeer Group. All rights reserved.

import Foundation

struct User: Decodable {
  private let arabicName: String?
  private let englishName: String?

  let id: String?
  let userName: String?
  let branch: String?
  var name: String? { return englishName }

  enum CodingKeys: String, CodingKey {
    case id = "EMPID"
    case userName = "CUSTOM_USERNAME"
    case arabicName = "EMP_AR_NAME"
    case englishName = "EMP_EN_NAME"
    case branch = "DEFAULTBRANCH"
  }
}
//{
//    CASHIER = 1;
//    "COMPLEX_PASSWORD" = 0;
//    "CUSTOM_USERNAME" = KHABEER;
//    DEFAULTBRANCH = 1;
//    DEFAULTGROUP = 1;
//    DEFAULTLANGUAGE = 1;
//    DEFAULTPAGE = 0;
//    "DISPENCE_ON_CLOSED_OPERATION" = 1;
//    "DOCTOR_JOB_TYPE" = 1;
//    EMPID = 22;
//    "EMP_AR_NAME" = "\U0645\U062d\U0645\U062f \U0639\U0632\U0628 \U0645\U062d\U0645\U062f  ";
//    "EMP_EMAIL_ADDRESS" = "a_abdallah@khabeergroup.com";
//    "EMP_EN_NAME" = "Mohamad Azab Mohamad  ";
//    "EXPORT_REPORTS_AUTHORITY" = 1;
//    "HAS_BRANCHES_OR_GROUPS" = 1;
//    "HOSP_AR_NAME" = "\U0645\U0633\U062a\U0634\U0641\U0649 \U062e\U0628\U064a\U0631 \U0627\U0644\U062f\U0648\U0644\U0649 \U062a\U0637\U0648\U064a\U0631";
//    "HOSP_EN_NAME" = "Khabeer Medical Hospital dev";
//    "MAIN_SCREEN_VIEW" = 1;
//    "MASTER_BRANCH" = 1;
//    "MODIFY_PAT_BLOOD_GROUP" = 1;
//    MULTIBRANCH = 1;
//    NAME = KHABEER;
//    "OFFICER_HOSPITAL_CODE" = 101;
//    "OFFICER_INTEGRATION" = 1;
//    ORACLEDATE = "09/11/2021 15:11:35";
//    "RESET_PW_AFTER_LOGIN" = 0;
//    "RESTRICTED_LINK" = 1;
//    "SCANNING_FILING_METHOD" = 1;
//    "SCANNING_STORAGE_PATH" = "D:\\ImagesStore";
//    "SCAN_TECH_ID" = 1;
//    UNLIMETEDUSER = 1;
//}

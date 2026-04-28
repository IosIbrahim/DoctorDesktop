//
//  NotesViewController.swift
//  DoctorDesktop
//
//  Created by Khabber on 22/11/2021.
//  Copyright © 2021 khabeer Group. All rights reserved.
//

import UIKit
import Reachability
import ObjectMapper
import SwiftyBeaver

class NotesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var viewSend: UIView!
    @IBOutlet weak var viewUrgent: UIView!
    @IBOutlet weak var viewMediciese: UIView!

    var messages: [ListOfDoctorNurseMessages] = []
    var NURSE_REMARKS_PRIORITY_List: [NURSE_REMARKS_PRIORITY_ROW] = []
    var NURSE_REMARKS_SHOW_D_N_List: [NURSE_REMARKS_SHOW_D_N] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        callAPI()
        viewUrgent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(urgentTapped)))
        viewMediciese.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mediciesTopped)))
        viewSend.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendTapped)))
    }

    // MARK: - Gesture actions

    @objc func urgentTapped() {
        AppPopUpHandler.instance.initListPopup(
            container: self,
            arrayNames: NURSE_REMARKS_PRIORITY_List.map { $0.NAME_AR },
            title: "اختار نوع الشكوي",
            type: "complaintTypeList"
        )
    }

    @objc func mediciesTopped() {
        AppPopUpHandler.instance.initListPopup(
            container: self,
            arrayNames: NURSE_REMARKS_SHOW_D_N_List.map { $0.NAME_AR },
            title: "اختار نوع الشكوي",
            type: "complaintTypeList"
        )
    }

    @objc func sendTapped() {
        send()
    }

    // MARK: - Session params helper

    private func sessionParams() -> (branch_id: String, user_id: String, visit_id: String, patient_id: String)? {
        guard
            let branch_id  = UserDefaults.standard.string(forKey: "branch_id"),
            let user_id    = UserDefaults.standard.string(forKey: "userName"),
            let visit_id   = UserDefaults.standard.string(forKey: "visit_id"),
            let patient_id = UserDefaults.standard.string(forKey: "patient_id")
        else { return nil }
        return (branch_id, user_id, visit_id, patient_id)
    }

    // MARK: - API calls

    func callAPI() {
        guard let s = sessionParams() else { return }

        let params: [String: String] = [
            "PATIENT_ID": s.patient_id,
            "USER_ID": s.user_id,
            "BRANCH_ID": s.branch_id,
            "COMPUTER_NAME": "ios",
            "USER_OPEN_FLAG": "D",
            "TYPE_FLAG": "3",
            "Lang": "2",
            "VISIT_ID_ARRAY": s.visit_id
        ]

        WebserviceMananger.sharedInstance.makeCall(
            method: .get,
            url: Constants.APIProvider.DDDocNurseNotesLoad,
            parameters: params,
            vc: self
        ) { [weak self] data, error in

            guard let self = self,
                  error == nil,
                  let root = (data as? [String: AnyObject])?["Root"] as? [String: AnyObject]
            else { return }

            // ── Messages ─────────────────────────────
            self.messages.removeAll()

            self.parseRows(
                from: root,
                key: "DOCTOR_NURSE_REMARKS",
                rowKey: "DOCTOR_NURSE_REMARKS_ROW"
            ) { row in
                if let msg = ListOfDoctorNurseMessages(JSON: row) {
                    self.messages.append(msg)
                }
            }

            self.tableView.reloadData()

            // ── Priority ─────────────────────────────
            self.NURSE_REMARKS_PRIORITY_List.removeAll()

            self.parseRows(
                from: root,
                key: "NURSE_REMARKS_PRIORITY",
                rowKey: "NURSE_REMARKS_PRIORITY_ROW"
            ) { row in
                if let item = NURSE_REMARKS_PRIORITY_ROW(JSON: row) {
                    self.NURSE_REMARKS_PRIORITY_List.append(item)
                }
            }

            // ── Show To ──────────────────────────────
            self.NURSE_REMARKS_SHOW_D_N_List.removeAll()

            self.parseRows(
                from: root,
                key: "NURSE_REMARKS_SHOW_D_N",
                rowKey: "NURSE_REMARKS_SHOW_D_N_ROW"
            ) { row in
                if let item = NURSE_REMARKS_SHOW_D_N(JSON: row) {
                    self.NURSE_REMARKS_SHOW_D_N_List.append(item)
                }
            }
        }
    }

    /// Parses a node that can be either a single dict or an array of dicts.
    private func parseRows(from root: [String: AnyObject],
                           key: String,
                           rowKey: String,
                           handler: ([String: AnyObject]) -> Void) {
        guard let node = root[key] as? [String: AnyObject] else { return }
        if let rows = node[rowKey] as? [[String: AnyObject]] {
            rows.forEach { handler($0) }
        } else if let row = node[rowKey] as? [String: AnyObject] {
            handler(row)
        }
    }

    func send() {
        guard let s = sessionParams() else { return }

        let params: [String: Any] = [
            "SI": ["BranchID": s.branch_id, "ComputerName": "android", "LanguageID": 2, "UserID": s.user_id],
            "DD_UC_PARMS": ["PATIENT_ID": s.patient_id, "VISIT_ID": s.visit_id, "PROCESS_ID": "994", "TRACER_PLACE_ID": "98", "USER_OPEN_FLAG": "D"],
            "DOCTOR_NURSE_REMARKS": ["BUFFER_STATUS": "1", "PRIORITY_TYPE": 2, "SHOW_D_N": 1, "VISIT_ID": "4", "DESC_EN": textView.text ?? ""]
        ]

        AppConnectionsHandler.post(url: Constants.APIProvider.sendMessage, params: params, type: String.self) { status, _, error in
            switch status {
            case .success:
                SwiftyBeaver.debug("Note sent successfully")
            case .error:
                SwiftyBeaver.error("Failed to send note: \(error ?? "")")
            }
        }
    }
}

// MARK: - Models

struct ListOfDoctorNurseMessages: Mappable {
    var DESC_EN: String = ""
    var EMP_NAME_EN: String = ""
    var EMP_NAME_AR: String = ""
    var status: String = ""
    var date: String = ""
    var flag: String = ""
    var showDN: String = ""
    var REPLY: nurseMessage?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        DESC_EN     <- map["DESC_EN"]
        REPLY       <- map["REPLY"]
        EMP_NAME_EN <- map["EMP_NAME_EN"]
        EMP_NAME_AR <- map["EMP_NAME_AR"]
        status      <- map["PRIORITY_TYPE"]
        date        <- map["TRANSDATE"]
        flag        <- map["USER_OPEN_FLAG"]
        showDN      <- map["USER_OPEN_FLAG"]
    }
}

struct nurseMessage: Mappable {
    var REPLY_ROWOb: REPLY_ROW?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        REPLY_ROWOb <- map["REPLY_ROW"]
    }
}

struct REPLY_ROW: Mappable {
    var REPLY_DESC: String = ""
    var USER_ENTER_NAME_EN: String = ""

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        REPLY_DESC          <- map["REPLY_DESC"]
        USER_ENTER_NAME_EN  <- map["USER_ENTER_NAME_EN"]
    }
}

struct NURSE_REMARKS_PRIORITY_ROW: Mappable {
    var NAME_EN: String = ""
    var NAME_AR: String = ""
    var ID: String = ""

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        NAME_EN <- map["NAME_EN"]
        NAME_AR <- map["NAME_AR"]
        ID      <- map["ID"]
    }
}

struct NURSE_REMARKS_SHOW_D_N: Mappable {
    var NAME_EN: String = ""
    var NAME_AR: String = ""
    var ID: String = ""

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        NAME_EN <- map["NAME_EN"]
        NAME_AR <- map["NAME_AR"]
        ID      <- map["ID"]
    }
}

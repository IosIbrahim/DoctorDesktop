//
//  OperationsListPresenter.swift
//  DoctorDesktop
//
//  View-only list of OR (operation room) patients for the logged-in doctor.
//  Wraps the existing ModelLayer.getOperationPatients call — no state
//  mutations, no workflow actions.
//

import Foundation

protocol OperationsListPresenter {
    var user: User { get }
    var patients: [OperationPatient] { get }
    var selectedDate: Date { get set }
    var error: String? { get }
    /// Fetches operation patients for `selectedDate` and the logged-in
    /// doctor (REQ_DOC_ID = user.id). Calls `finished` on the main queue.
    func load(finished: @escaping EmptyBlock)
}

final class OperationsListPresenterImpl: OperationsListPresenter {

    private let modelLayer: ModelLayer
    let user: User
    var selectedDate: Date = Date()
    private(set) var patients: [OperationPatient] = []
    private(set) var error: String?

    /// Same fixed-locale formatter the rest of the app uses for server
    /// calls — guarantees a regular space (U+0020), Western digits, and
    /// the Gregorian calendar regardless of the user's iOS region.
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return f
    }()

    init(modelLayer: ModelLayer, user: User) {
        self.modelLayer = modelLayer
        self.user = user
    }

    /// Toggle for the `REQ_DOC_ID` filter. Default `true` → only the
    /// logged-in doctor's operations. Flip to `false` if you want to
    /// see the whole branch's OR schedule (e.g. for QA / a manager
    /// reviewing a colleague's day).
    private static let filterByLoggedInDoctor: Bool = true

    func load(finished: @escaping EmptyBlock) {
        var params: [String: String] = [
            "BRANCH_ID":              user.branch   ?? "",
            "USER_ID":                user.userName ?? "",
            "COMPUTER_NAME":          "iOS",
            "USER_OPEN_FLAG":         "D",
            "DATE_FROM_STR_FORMATED": formatter.string(from: selectedDate),
        ]
        if Self.filterByLoggedInDoctor {
            params["REQ_DOC_ID"] = user.id ?? ""
        }
        error = nil
        modelLayer.getOperationPatients(with: params) { [weak self] patients in
            guard let self = self else { return }
            self.patients = patients
            finished()
        }
    }
}

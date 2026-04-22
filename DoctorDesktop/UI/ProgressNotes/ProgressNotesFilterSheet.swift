//
//  ProgressNotesFilterSheet.swift
//  DoctorDesktop
//
//  Android-matched filter bottom sheet for the Progress Notes screen.
//
//  Layout (bottom sheet, slides up):
//    ─── drag handle
//    "Filter"              title
//    ──────────────────── divider
//    "Visit Type"  label  + bordered dropdown  → VISIT_TYPE_ROW
//    "Filter"      label  + bordered dropdown  → NURSE_REMARKS_FILTER_ROW
//    [FILTER]  blue  button
//    [RESET]   red   button
//    ─── option panel (slides up inside same view when a dropdown is tapped)
//        UITableView listing all options for the active dropdown
//        Done bar at top
//
//  The option list is a UITableView (not UIPickerView). UITableView.reloadData()
//  is synchronous and reliable — it was the only safe replacement for the
//  UIPickerView that kept losing its rows after reloadAllComponents().
//

import UIKit

// MARK: - Delegate

protocol ProgressNotesFilterSheetDelegate: AnyObject {
    func filterSheet(_ sheet: ProgressNotesFilterSheet,
                     didApply visitTypeId: String,
                     filterId: String)
    func filterSheetDidReset(_ sheet: ProgressNotesFilterSheet)
}

// MARK: - Sheet

final class ProgressNotesFilterSheet: UIViewController {

    // MARK: Config

    weak var delegate: ProgressNotesFilterSheetDelegate?

    /// Options for the Visit Type dropdown (VISIT_TYPE_ROW).
    var visitTypeOptions: [NurseNoteLookup] = []
    /// Options for the Nurse Remarks Filter dropdown (NURSE_REMARKS_FILTER_ROW).
    var filterOptions: [NurseNoteLookup] = []

    /// Pre-selected ids (restored when sheet re-opens).
    var initialVisitTypeId: String = ""
    var initialFilterId:    String = ""

    // MARK: Internal state

    private var selectedVisitTypeId: String = ""
    private var selectedFilterId:    String = ""

    private enum ActiveDropdown { case visitType, filter }
    private var activeDropdown: ActiveDropdown = .visitType

    // MARK: Sheet views

    private let dimView       = UIView()
    private let sheetView     = UIView()
    private let handle        = UIView()
    private let titleLabel    = UILabel()

    private let visitTypeLabel   = UILabel()     // "Visit Type"
    private let visitTypeDropBtn = DropdownButton()
    private let filterLabel      = UILabel()     // "Filter"
    private let filterDropBtn    = DropdownButton()

    private let applyBtn = UIButton(type: .system)
    private let resetBtn = UIButton(type: .system)

    // MARK: Option panel (slides up in front of sheet)

    private let optionPanel    = UIView()
    private let optionDoneBar  = UIView()
    private let optionDoneBtn  = UIButton(type: .system)
    private let optionTable    = UITableView(frame: .zero, style: .plain)

    private static let optionCellId = "OptionCell"

    // MARK: Constraints

    private var sheetBottomConstraint: NSLayoutConstraint!
    private var optionPanelBottomConstraint: NSLayoutConstraint!

    // Approx content height of the sheet (used for initial off-screen placement).
    private let sheetHeight: CGFloat  = 360
    private let optionPanelH: CGFloat = 260   // 44 toolbar + ~216 table

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        selectedVisitTypeId = initialVisitTypeId
        selectedFilterId    = initialFilterId
        buildUI()
        refreshDropLabels()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        slideSheetIn()
    }

    // MARK: - Build UI

    private func buildUI() {
        // ── Dim overlay ────────────────────────────────────────────────────────
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        dimView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapDim)))

        // ── Sheet card ─────────────────────────────────────────────────────────
        sheetView.backgroundColor = .white
        sheetView.layer.cornerRadius = 20
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.layer.shadowColor   = UIColor.black.cgColor
        sheetView.layer.shadowOpacity = 0.10
        sheetView.layer.shadowRadius  = 12
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(didTapDim))
        swipe.direction = .down
        sheetView.addGestureRecognizer(swipe)

        // Handle
        handle.backgroundColor = UIColor(white: 0.80, alpha: 1)
        handle.layer.cornerRadius = 2.5
        handle.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(handle)

        // Title
        titleLabel.text = "Filter"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(white: 0.10, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(titleLabel)

        // Divider
        let divider = makeDivider()
        sheetView.addSubview(divider)

        // Visit Type field
        visitTypeLabel.text = "Visit Type"
        styleFieldLabel(visitTypeLabel)
        visitTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(visitTypeLabel)

        visitTypeDropBtn.translatesAutoresizingMaskIntoConstraints = false
        visitTypeDropBtn.addTarget(self,
                                   action: #selector(didTapVisitTypeDrop),
                                   for: .touchUpInside)
        sheetView.addSubview(visitTypeDropBtn)

        // Nurse Remarks Filter field
        filterLabel.text = "Filter"
        styleFieldLabel(filterLabel)
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(filterLabel)

        filterDropBtn.translatesAutoresizingMaskIntoConstraints = false
        filterDropBtn.addTarget(self,
                                action: #selector(didTapFilterDrop),
                                for: .touchUpInside)
        sheetView.addSubview(filterDropBtn)

        // FILTER button
        styleActionButton(applyBtn, title: "FILTER",
                          bg: UIColor(red: 0.18, green: 0.56, blue: 0.94, alpha: 1))
        applyBtn.translatesAutoresizingMaskIntoConstraints = false
        applyBtn.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
        sheetView.addSubview(applyBtn)

        // RESET button
        styleActionButton(resetBtn, title: "RESET",
                          bg: UIColor(red: 0.88, green: 0.26, blue: 0.30, alpha: 1))
        resetBtn.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        sheetView.addSubview(resetBtn)

        // ── Option panel ───────────────────────────────────────────────────────
        // Added to `view` (on top of sheetView) so it appears in front.
        optionPanel.backgroundColor = .white
        optionPanel.layer.shadowColor   = UIColor.black.cgColor
        optionPanel.layer.shadowOpacity = 0.10
        optionPanel.layer.shadowRadius  = 8
        optionPanel.layer.shadowOffset  = CGSize(width: 0, height: -2)
        optionPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionPanel)

        // Done bar
        optionDoneBar.backgroundColor = UIColor(white: 0.94, alpha: 1)
        optionDoneBar.translatesAutoresizingMaskIntoConstraints = false
        optionPanel.addSubview(optionDoneBar)

        optionDoneBtn.setTitle("Done", for: .normal)
        optionDoneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        optionDoneBtn.setTitleColor(
            UIColor(red: 0.18, green: 0.56, blue: 0.94, alpha: 1), for: .normal)
        optionDoneBtn.translatesAutoresizingMaskIntoConstraints = false
        optionDoneBtn.addTarget(self, action: #selector(didTapOptionDone), for: .touchUpInside)
        optionDoneBar.addSubview(optionDoneBtn)

        // Options table
        optionTable.register(UITableViewCell.self,
                             forCellReuseIdentifier: Self.optionCellId)
        optionTable.dataSource   = self
        optionTable.delegate     = self
        optionTable.rowHeight    = 48
        optionTable.separatorInset = .zero
        optionTable.translatesAutoresizingMaskIntoConstraints = false
        optionPanel.addSubview(optionTable)

        // ── Constraints ────────────────────────────────────────────────────────
        sheetBottomConstraint       = sheetView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: sheetHeight)
        optionPanelBottomConstraint = optionPanel.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: optionPanelH)

        NSLayoutConstraint.activate([
            // Dim
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Sheet
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetBottomConstraint,

            // Handle
            handle.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 10),
            handle.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            handle.widthAnchor.constraint(equalToConstant: 40),
            handle.heightAnchor.constraint(equalToConstant: 5),

            // Title
            titleLabel.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),

            // Divider
            divider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            // Visit Type field
            visitTypeLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 20),
            visitTypeLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            visitTypeLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),

            visitTypeDropBtn.topAnchor.constraint(equalTo: visitTypeLabel.bottomAnchor, constant: 8),
            visitTypeDropBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            visitTypeDropBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            visitTypeDropBtn.heightAnchor.constraint(equalToConstant: 50),

            // Filter field
            filterLabel.topAnchor.constraint(equalTo: visitTypeDropBtn.bottomAnchor, constant: 20),
            filterLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            filterLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),

            filterDropBtn.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 8),
            filterDropBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            filterDropBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            filterDropBtn.heightAnchor.constraint(equalToConstant: 50),

            // Action buttons
            applyBtn.topAnchor.constraint(equalTo: filterDropBtn.bottomAnchor, constant: 28),
            applyBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            applyBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            applyBtn.heightAnchor.constraint(equalToConstant: 50),

            resetBtn.topAnchor.constraint(equalTo: applyBtn.bottomAnchor, constant: 12),
            resetBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            resetBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            resetBtn.heightAnchor.constraint(equalToConstant: 50),
            resetBtn.bottomAnchor.constraint(lessThanOrEqualTo: sheetView.bottomAnchor,
                                             constant: -28),

            // Option panel
            optionPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionPanelBottomConstraint,

            // Done bar
            optionDoneBar.topAnchor.constraint(equalTo: optionPanel.topAnchor),
            optionDoneBar.leadingAnchor.constraint(equalTo: optionPanel.leadingAnchor),
            optionDoneBar.trailingAnchor.constraint(equalTo: optionPanel.trailingAnchor),
            optionDoneBar.heightAnchor.constraint(equalToConstant: 44),

            optionDoneBtn.centerYAnchor.constraint(equalTo: optionDoneBar.centerYAnchor),
            optionDoneBtn.trailingAnchor.constraint(equalTo: optionDoneBar.trailingAnchor,
                                                     constant: -16),

            // Table
            optionTable.topAnchor.constraint(equalTo: optionDoneBar.bottomAnchor),
            optionTable.leadingAnchor.constraint(equalTo: optionPanel.leadingAnchor),
            optionTable.trailingAnchor.constraint(equalTo: optionPanel.trailingAnchor),
            optionTable.heightAnchor.constraint(equalToConstant: optionPanelH - 44),
            optionTable.bottomAnchor.constraint(equalTo: optionPanel.bottomAnchor),
        ])
    }

    // MARK: - Sheet animation

    private func slideSheetIn() {
        UIView.animate(withDuration: 0.30, delay: 0,
                       usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3,
                       options: [], animations: {
            self.dimView.alpha = 1
            self.sheetBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    private func slideSheetOut(then block: @escaping () -> Void) {
        UIView.animate(withDuration: 0.22, animations: {
            self.dimView.alpha = 0
            self.sheetBottomConstraint.constant         = self.sheetHeight
            self.optionPanelBottomConstraint.constant   = self.optionPanelH
            self.view.layoutIfNeeded()
        }, completion: { _ in block() })
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        slideSheetOut { super.dismiss(animated: false, completion: completion) }
    }

    // MARK: - Option panel show / hide

    private func showOptionPanel(for kind: ActiveDropdown) {
        activeDropdown = kind
        // Reload the table synchronously before animating in.
        optionTable.reloadData()
        // Scroll to currently selected row (if any).
        let list = currentList()
        let selId  = kind == .visitType ? selectedVisitTypeId : selectedFilterId
        if let idx = list.firstIndex(where: { $0.id == selId }) {
            let ip = IndexPath(row: idx, section: 0)
            optionTable.scrollToRow(at: ip, at: .middle, animated: false)
        }
        UIView.animate(withDuration: 0.25) {
            self.optionPanelBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    private func hideOptionPanel() {
        UIView.animate(withDuration: 0.22) {
            self.optionPanelBottomConstraint.constant = self.optionPanelH
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Current option list

    private func currentList() -> [NurseNoteLookup] {
        switch activeDropdown {
        case .visitType:
            // VISIT_TYPE_ROW: Inpatient / Outpatient / Emergency — use server data as-is.
            // "Show all" is achieved via the RESET button, not an "All" row here.
            let base = visitTypeOptions
            if base.isEmpty {
                return [NurseNoteLookup(id: "1", label: "Inpatient"),
                        NurseNoteLookup(id: "2", label: "Outpatient"),
                        NurseNoteLookup(id: "3", label: "Emergency")]
            }
            return base

        case .filter:
            // NURSE_REMARKS_FILTER_ROW already starts with "My View" (ID "0")
            // and ends with "All" (ID "3") — use the server list as-is.
            let base = filterOptions
            if base.isEmpty {
                return [NurseNoteLookup(id: "0", label: "My View")]
            }
            return base
        }
    }

    // MARK: - Actions

    @objc private func didTapDim() {
        hideOptionPanel()
        dismiss(animated: false)
    }

    @objc private func didTapVisitTypeDrop() { showOptionPanel(for: .visitType) }
    @objc private func didTapFilterDrop()    { showOptionPanel(for: .filter) }

    @objc private func didTapOptionDone() {
        // Commit the tapped row (the last row the user highlighted by tapping).
        // If the user didn't tap any row, keep the previous selection unchanged.
        hideOptionPanel()
    }

    @objc private func didTapApply() {
        dismiss(animated: false)
        delegate?.filterSheet(self,
                              didApply: selectedVisitTypeId,
                              filterId: selectedFilterId)
    }

    @objc private func didTapReset() {
        selectedVisitTypeId = ""
        selectedFilterId    = ""
        refreshDropLabels()
        dismiss(animated: false)
        delegate?.filterSheetDidReset(self)
    }

    // MARK: - Helpers

    private func refreshDropLabels() {
        visitTypeDropBtn.setTitle(
            labelFor(id: selectedVisitTypeId, in: visitTypeOptions, fallback: "All"),
            for: .normal)
        filterDropBtn.setTitle(
            labelFor(id: selectedFilterId, in: filterOptions, fallback: "My View"),
            for: .normal)
    }

    private func labelFor(id: String, in list: [NurseNoteLookup], fallback: String) -> String {
        guard !id.isEmpty else { return fallback }
        return list.first(where: { $0.id == id })?.label ?? fallback
    }

    private func styleFieldLabel(_ lbl: UILabel) {
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = UIColor(white: 0.30, alpha: 1)
    }

    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.88, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func styleActionButton(_ btn: UIButton, title: String, bg: UIColor) {
        btn.backgroundColor = bg
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.cornerRadius = 8
    }
}

// MARK: - UITableViewDataSource / Delegate

extension ProgressNotesFilterSheet: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return currentList().count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.optionCellId,
                                                 for: indexPath)
        let list = currentList()
        guard indexPath.row < list.count else { return cell }
        let item = list[indexPath.row]

        cell.textLabel?.text = item.label
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)

        let selId = activeDropdown == .visitType ? selectedVisitTypeId : selectedFilterId
        cell.accessoryType = (item.id == selId) ? .checkmark : .none
        cell.tintColor = UIColor(red: 0.18, green: 0.56, blue: 0.94, alpha: 1)
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let list = currentList()
        guard indexPath.row < list.count else { return }
        let item = list[indexPath.row]

        // Update the active selection and refresh checkmarks.
        if activeDropdown == .visitType {
            selectedVisitTypeId = item.id
        } else {
            selectedFilterId = item.id
        }
        tableView.reloadData()

        // Update the dropdown button label in the sheet.
        refreshDropLabels()

        // Slide the option panel away after a brief delay so the user sees
        // the checkmark land before it disappears.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            self?.hideOptionPanel()
        }
    }
}

// MARK: - DropdownButton

/// Bordered button matching the Android spinner look.
private final class DropdownButton: UIButton {
    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        contentHorizontalAlignment = .left
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 44)
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        setTitleColor(UIColor(white: 0.20, alpha: 1), for: .normal)
        backgroundColor = UIColor(white: 0.97, alpha: 1)
        layer.borderColor = UIColor(white: 0.80, alpha: 1).cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 8

        if #available(iOS 13, *) {
            let img = UIImage(systemName: "chevron.down")
            let iv  = UIImageView(image: img)
            iv.tintColor = UIColor(white: 0.45, alpha: 1)
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            NSLayoutConstraint.activate([
                iv.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
                iv.centerYAnchor.constraint(equalTo: centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: 16),
                iv.heightAnchor.constraint(equalToConstant: 16),
            ])
        }
    }
}

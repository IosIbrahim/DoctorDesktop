//
//  ProgressNotesFilterSheet.swift
//  DoctorDesktop
//
//  Android-matched filter bottom sheet for the Progress Notes screen.
//
//  Layout (mirrors the Android screenshot):
//    ─── drag handle
//    "Filter"             title
//    ──────────────────── divider
//    "Filter"      label  + bordered dropdown → VISIT_TYPE_ROW
//    "Visit Type"  label  + bordered dropdown → NURSE_REMARKS_FILTER_ROW
//    [FILTER]  blue  button
//    [RESET]   red   button
//    ─── embedded UIPickerView (slides up inside sheet when a dropdown is tapped)
//        Done bar
//
//  Picker is embedded INSIDE the sheet — no UIAlertController presentation,
//  which avoids the iOS "popover on overFullScreen" rendering bug that caused
//  only one item to appear.
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

    /// Options for the top dropdown (VISIT_TYPE_ROW).
    var visitTypeOptions: [NurseNoteLookup] = []
    /// Options for the bottom dropdown (NURSE_REMARKS_FILTER_ROW).
    var filterOptions: [NurseNoteLookup] = []

    /// Pre-selected ids (restored when sheet re-opens).
    var initialVisitTypeId: String = ""
    var initialFilterId:    String = ""

    // MARK: Internal state

    private var selectedVisitTypeId: String = ""
    private var selectedFilterId:    String = ""

    // Which dropdown is the picker currently serving.
    private enum ActivePicker { case visitType, filter }
    private var activePicker: ActivePicker = .visitType

    // MARK: Views

    private let dimView       = UIView()
    private let sheetView     = UIView()
    private let handle        = UIView()
    private let titleLabel    = UILabel()
    private let filterLabel   = UILabel()
    private let filterDropBtn = DropdownButton()
    private let visitLabel    = UILabel()
    private let visitDropBtn  = DropdownButton()
    private let applyBtn      = UIButton(type: .system)
    private let resetBtn      = UIButton(type: .system)

    // Picker panel (hidden until a dropdown is tapped)
    private let pickerPanel   = UIView()
    private let pickerDoneBtn = UIButton(type: .system)
    private let pickerView    = UIPickerView()

    // MARK: Layout

    private var sheetBottomConstraint: NSLayoutConstraint!
    private var pickerBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        selectedVisitTypeId = initialVisitTypeId
        selectedFilterId    = initialFilterId
        buildUI()
        refreshLabels()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        slideSheetIn()
    }

    // MARK: - UI Build

    private func buildUI() {
        // Dim overlay
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDim)))

        // Sheet card
        sheetView.backgroundColor = .white
        sheetView.layer.cornerRadius = 20
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.layer.shadowColor   = UIColor.black.cgColor
        sheetView.layer.shadowOpacity = 0.10
        sheetView.layer.shadowRadius  = 12
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)
        sheetView.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(didTapDim)).also { $0.direction = .down })

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

        // "Filter" label + dropdown (VISIT_TYPE_ROW)
        filterLabel.text = "Filter"
        styleFieldLabel(filterLabel)
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(filterLabel)

        filterDropBtn.translatesAutoresizingMaskIntoConstraints = false
        filterDropBtn.addTarget(self, action: #selector(didTapFilterDrop), for: .touchUpInside)
        sheetView.addSubview(filterDropBtn)

        // "Visit Type" label + dropdown (NURSE_REMARKS_FILTER_ROW)
        visitLabel.text = "Visit Type"
        styleFieldLabel(visitLabel)
        visitLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(visitLabel)

        visitDropBtn.translatesAutoresizingMaskIntoConstraints = false
        visitDropBtn.addTarget(self, action: #selector(didTapVisitDrop), for: .touchUpInside)
        sheetView.addSubview(visitDropBtn)

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

        // ── Picker panel (slides up inside sheet) ─────────────────────────
        pickerPanel.backgroundColor = UIColor(white: 0.97, alpha: 1)
        pickerPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerPanel)                     // added to *view*, not sheetView

        // Done bar above picker
        let pickerDoneBar = UIView()
        pickerDoneBar.backgroundColor = UIColor(white: 0.94, alpha: 1)
        pickerDoneBar.translatesAutoresizingMaskIntoConstraints = false
        pickerPanel.addSubview(pickerDoneBar)

        pickerDoneBtn.setTitle("Done", for: .normal)
        pickerDoneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        pickerDoneBtn.setTitleColor(UIColor(red: 0.18, green: 0.56, blue: 0.94, alpha: 1), for: .normal)
        pickerDoneBtn.translatesAutoresizingMaskIntoConstraints = false
        pickerDoneBtn.addTarget(self, action: #selector(didTapPickerDone), for: .touchUpInside)
        pickerDoneBar.addSubview(pickerDoneBtn)

        pickerView.dataSource = self
        pickerView.delegate   = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerPanel.addSubview(pickerView)

        // MARK: Constraints

        sheetBottomConstraint  = sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 520)
        pickerBottomConstraint = pickerPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 260)

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

            // Filter label + dropdown
            filterLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 20),
            filterLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            filterLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),

            filterDropBtn.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 8),
            filterDropBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            filterDropBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            filterDropBtn.heightAnchor.constraint(equalToConstant: 50),

            // Visit Type label + dropdown
            visitLabel.topAnchor.constraint(equalTo: filterDropBtn.bottomAnchor, constant: 20),
            visitLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            visitLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),

            visitDropBtn.topAnchor.constraint(equalTo: visitLabel.bottomAnchor, constant: 8),
            visitDropBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            visitDropBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            visitDropBtn.heightAnchor.constraint(equalToConstant: 50),

            // Action buttons
            applyBtn.topAnchor.constraint(equalTo: visitDropBtn.bottomAnchor, constant: 28),
            applyBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            applyBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            applyBtn.heightAnchor.constraint(equalToConstant: 50),

            resetBtn.topAnchor.constraint(equalTo: applyBtn.bottomAnchor, constant: 12),
            resetBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            resetBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            resetBtn.heightAnchor.constraint(equalToConstant: 50),
            resetBtn.bottomAnchor.constraint(lessThanOrEqualTo: sheetView.bottomAnchor, constant: -28),

            // Picker panel
            pickerPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerBottomConstraint,

            pickerDoneBar.topAnchor.constraint(equalTo: pickerPanel.topAnchor),
            pickerDoneBar.leadingAnchor.constraint(equalTo: pickerPanel.leadingAnchor),
            pickerDoneBar.trailingAnchor.constraint(equalTo: pickerPanel.trailingAnchor),
            pickerDoneBar.heightAnchor.constraint(equalToConstant: 44),

            pickerDoneBtn.centerYAnchor.constraint(equalTo: pickerDoneBar.centerYAnchor),
            pickerDoneBtn.trailingAnchor.constraint(equalTo: pickerDoneBar.trailingAnchor, constant: -16),

            pickerView.topAnchor.constraint(equalTo: pickerDoneBar.bottomAnchor),
            pickerView.leadingAnchor.constraint(equalTo: pickerPanel.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: pickerPanel.trailingAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 216),
            pickerView.bottomAnchor.constraint(equalTo: pickerPanel.bottomAnchor)
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
            self.sheetBottomConstraint.constant  = 520
            self.pickerBottomConstraint.constant = 260   // also hide picker if open
            self.view.layoutIfNeeded()
        }, completion: { _ in block() })
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        slideSheetOut { super.dismiss(animated: false, completion: completion) }
    }

    // MARK: - Picker show / hide

    private func showPicker(for kind: ActivePicker) {
        activePicker = kind

        // Pre-select the currently chosen row.
        let list   = currentList()
        let selId  = (kind == .visitType) ? selectedVisitTypeId : selectedFilterId
        let selIdx = list.firstIndex(where: { $0.id == selId }) ?? 0
        pickerView.reloadAllComponents()
        if selIdx < list.count { pickerView.selectRow(selIdx, inComponent: 0, animated: false) }

        UIView.animate(withDuration: 0.25) {
            self.pickerBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    private func hidePicker() {
        UIView.animate(withDuration: 0.22) {
            self.pickerBottomConstraint.constant = 260
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    @objc private func didTapDim() {
        hidePicker()
        dismiss(animated: false)
    }

    @objc private func didTapFilterDrop() { showPicker(for: .visitType) }
    @objc private func didTapVisitDrop()  { showPicker(for: .filter) }

    @objc private func didTapPickerDone() {
        let row  = pickerView.selectedRow(inComponent: 0)
        let list = currentList()
        guard row < list.count else { hidePicker(); return }
        let item = list[row]
        if activePicker == .visitType {
            selectedVisitTypeId = item.id
        } else {
            selectedFilterId = item.id
        }
        refreshLabels()
        hidePicker()
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
        refreshLabels()
        dismiss(animated: false)
        delegate?.filterSheetDidReset(self)
    }

    // MARK: - Helpers

    private func currentList() -> [NurseNoteLookup] {
        let base: [NurseNoteLookup]
        switch activePicker {
        case .visitType: base = visitTypeOptions
        case .filter:    base = filterOptions
        }
        // Always prepend "All" / "My View" as the first (no-filter) option.
        let allRow = NurseNoteLookup(id: "",
                                     label: activePicker == .visitType ? "All" : "My View")
        if base.isEmpty { return [allRow] }
        // Avoid duplicating if server already includes it.
        let firstIsAll = base.first.map { $0.id.isEmpty || $0.label == "All" || $0.label == "My View" } ?? false
        return firstIsAll ? base : [allRow] + base
    }

    private func refreshLabels() {
        filterDropBtn.setTitle(labelFor(id: selectedVisitTypeId,
                                        in: visitTypeOptions, fallback: "All"), for: .normal)
        visitDropBtn.setTitle(labelFor(id: selectedFilterId,
                                       in: filterOptions, fallback: "My View"), for: .normal)
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

// MARK: - UIPickerViewDataSource / Delegate

extension ProgressNotesFilterSheet: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return currentList().count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        let list = currentList()
        guard row < list.count else { return nil }
        return list[row].label
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
                iv.heightAnchor.constraint(equalToConstant: 16)
            ])
        }
    }
}

// MARK: - UISwipeGestureRecognizer helper

private extension UISwipeGestureRecognizer {
    @discardableResult
    func also(_ configure: (UISwipeGestureRecognizer) -> Void) -> UISwipeGestureRecognizer {
        configure(self); return self
    }
}

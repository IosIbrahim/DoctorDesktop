//
//  ProgressNotesFilterSheet.swift
//  DoctorDesktop
//
//  Android-matched filter bottom sheet for the Progress Notes screen.
//
//  Layout (mirrors the Android screenshot):
//    ─── drag handle
//    "Filter"             title
//    "Filter"             label  + dropdown → VISIT_TYPE_ROW
//    "Visit Type"         label  + dropdown → NURSE_REMARKS_FILTER_ROW
//    [FILTER]  blue  button  →  applyFilter on presenter
//    [RESET]   red   button  →  resetFilter  on presenter
//
//  Presentation: dim-background custom presentation that slides up from
//  the bottom half of the screen, matching the Android bottom-sheet feel.
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

    // MARK: State

    private var selectedVisitTypeId: String = ""
    private var selectedFilterId:    String = ""

    // MARK: Views

    private let dimView       = UIView()
    private let sheetView     = UIView()
    private let handle        = UIView()
    private let titleLabel    = UILabel()
    private let filterLabel   = UILabel()
    private let filterButton  = DropdownButton()
    private let visitLabel    = UILabel()
    private let visitButton   = DropdownButton()
    private let applyBtn      = UIButton(type: .system)
    private let resetBtn      = UIButton(type: .system)

    // MARK: Layout

    private var sheetBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        selectedVisitTypeId = initialVisitTypeId
        selectedFilterId    = initialFilterId
        buildUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.30, delay: 0,
                       usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3,
                       options: [], animations: {
            self.dimView.alpha = 1
            self.sheetBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    // MARK: - UI

    private func buildUI() {
        // Dim overlay
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDim))
        dimView.addGestureRecognizer(tap)

        // Sheet card
        sheetView.backgroundColor = .white
        sheetView.layer.cornerRadius = 20
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.layer.shadowColor   = UIColor.black.cgColor
        sheetView.layer.shadowOpacity = 0.10
        sheetView.layer.shadowRadius  = 12
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)

        // Drag handle
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

        // Divider under title
        let divider = hairline()
        sheetView.addSubview(divider)

        // Filter label + dropdown (VISIT_TYPE_ROW)
        filterLabel.text = "Filter"
        style(label: filterLabel)
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(filterLabel)

        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.setTitle(labelFor(id: selectedVisitTypeId, in: visitTypeOptions, fallback: "All"), for: .normal)
        filterButton.addTarget(self, action: #selector(didTapFilterDrop), for: .touchUpInside)
        sheetView.addSubview(filterButton)

        // Visit Type label + dropdown (NURSE_REMARKS_FILTER_ROW)
        visitLabel.text = "Visit Type"
        style(label: visitLabel)
        visitLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(visitLabel)

        visitButton.translatesAutoresizingMaskIntoConstraints = false
        visitButton.setTitle(labelFor(id: selectedFilterId, in: filterOptions, fallback: "My View"), for: .normal)
        visitButton.addTarget(self, action: #selector(didTapVisitDrop), for: .touchUpInside)
        sheetView.addSubview(visitButton)

        // FILTER button
        styleActionButton(applyBtn, title: "FILTER", bg: UIColor(red: 0.18, green: 0.56, blue: 0.94, alpha: 1))
        applyBtn.translatesAutoresizingMaskIntoConstraints = false
        applyBtn.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
        sheetView.addSubview(applyBtn)

        // RESET button
        styleActionButton(resetBtn, title: "RESET", bg: UIColor(red: 0.88, green: 0.26, blue: 0.30, alpha: 1))
        resetBtn.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        sheetView.addSubview(resetBtn)

        // MARK: Constraints

        sheetBottomConstraint = sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                   constant: 450)
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

            // Filter label
            filterLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 20),
            filterLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            filterLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),

            // Filter dropdown
            filterButton.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 8),
            filterButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            filterButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            filterButton.heightAnchor.constraint(equalToConstant: 50),

            // Visit label
            visitLabel.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 20),
            visitLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            visitLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),

            // Visit dropdown
            visitButton.topAnchor.constraint(equalTo: visitLabel.bottomAnchor, constant: 8),
            visitButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            visitButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            visitButton.heightAnchor.constraint(equalToConstant: 50),

            // FILTER button
            applyBtn.topAnchor.constraint(equalTo: visitButton.bottomAnchor, constant: 28),
            applyBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            applyBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            applyBtn.heightAnchor.constraint(equalToConstant: 50),

            // RESET button
            resetBtn.topAnchor.constraint(equalTo: applyBtn.bottomAnchor, constant: 12),
            resetBtn.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 20),
            resetBtn.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -20),
            resetBtn.heightAnchor.constraint(equalToConstant: 50),
            resetBtn.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor,
                                             constant: -(view.safeAreaInsets.bottom + 20))
        ])

        // Swipe-down gesture
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(didTapDim))
        swipe.direction = .down
        sheetView.addGestureRecognizer(swipe)
    }

    // MARK: - Actions

    @objc private func didTapDim() { dismiss(animated: false) }

    @objc private func didTapFilterDrop() {
        let options = visitTypeOptions.isEmpty
            ? [NurseNoteLookup(id: "", label: "All")]
            : [NurseNoteLookup(id: "", label: "All")] + visitTypeOptions
        presentPicker(title: "Filter", options: options) { [weak self] item in
            guard let self = self else { return }
            self.selectedVisitTypeId = item.id
            self.filterButton.setTitle(item.label, for: .normal)
        }
    }

    @objc private func didTapVisitDrop() {
        let options = filterOptions.isEmpty
            ? [NurseNoteLookup(id: "", label: "My View")]
            : [NurseNoteLookup(id: "", label: "My View")] + filterOptions
        presentPicker(title: "Visit Type", options: options) { [weak self] item in
            guard let self = self else { return }
            self.selectedFilterId = item.id
            self.visitButton.setTitle(item.label, for: .normal)
        }
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
        filterButton.setTitle("All",     for: .normal)
        visitButton.setTitle("My View",  for: .normal)
        dismiss(animated: false)
        delegate?.filterSheetDidReset(self)
    }

    // MARK: - Custom dismiss animation

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.22, animations: {
            self.dimView.alpha = 0
            self.sheetBottomConstraint.constant = 450
            self.view.layoutIfNeeded()
        }, completion: { _ in
            super.dismiss(animated: false, completion: completion)
        })
    }

    // MARK: - Helpers

    private func style(label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(white: 0.30, alpha: 1)
    }

    private func hairline() -> UIView {
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

    private func labelFor(id: String, in list: [NurseNoteLookup], fallback: String) -> String {
        guard !id.isEmpty else { return fallback }
        return list.first(where: { $0.id == id })?.label ?? fallback
    }

    private func presentPicker(title: String,
                               options: [NurseNoteLookup],
                               onPick: @escaping (NurseNoteLookup) -> Void) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for opt in options {
            ac.addAction(UIAlertAction(title: opt.label, style: .default) { _ in
                onPick(opt)
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.sourceView = view
        ac.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX,
                                                              y: view.bounds.midY,
                                                              width: 1, height: 1)
        present(ac, animated: true)
    }
}

// MARK: - DropdownButton

/// A full-width, bordered dropdown-style button matching the Android spinner look.
private final class DropdownButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
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

        // Chevron icon on the right
        let chevron = UIImageView()
        chevron.contentMode = .scaleAspectFit
        chevron.tintColor = UIColor(white: 0.45, alpha: 1)
        if #available(iOS 13, *) {
            chevron.image = UIImage(systemName: "chevron.down")
        }
        chevron.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chevron)
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 16),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}

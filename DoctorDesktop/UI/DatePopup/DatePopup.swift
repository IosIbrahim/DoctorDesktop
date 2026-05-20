//
//  DatePopup.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/21/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

class DatePopup: UIViewController {

    // MARK: - Public — callers read .date from this picker
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.date = Date()                        // always open on today
        picker.preferredDatePickerStyle = .inline   // full calendar grid
        // Teal selection circle matching the design
        picker.tintColor = UIColor(red: 0.05, green: 0.60, blue: 0.65, alpha: 1)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    /// Called the moment the user taps a date on the calendar.
    /// Removes the need for an explicit "Done" button — the host pops the
    /// dialog and applies the date in this callback.
    var onDateSelected: ((Date) -> Void)?

    // MARK: - Private UI

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor  = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.10
        v.layer.shadowRadius  = 16
        v.layer.shadowOffset  = CGSize(width: 0, height: 4)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Lifecycle

    override func loadView() {
        let root = UIView()
        root.backgroundColor = .clear
        view = root
        buildLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.addTarget(self,
                             action: #selector(dateChanged),
                             for: .valueChanged)
    }

    @objc private func dateChanged() {
        onDateSelected?(datePicker.date)
    }

    // MARK: - Layout

    private func buildLayout() {
        view.addSubview(cardView)
        cardView.addSubview(datePicker)

        NSLayoutConstraint.activate([
            // Card fills the popup frame
            cardView.topAnchor.constraint(equalTo: view.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Picker sits inside card with equal padding on all sides
            datePicker.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            datePicker.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            datePicker.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            datePicker.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }
}

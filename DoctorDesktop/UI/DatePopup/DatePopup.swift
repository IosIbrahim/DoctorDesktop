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
        picker.tintColor = UIColor(red: 0.26, green: 0.57, blue: 0.80, alpha: 1)
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    // MARK: - Private UI
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let handleBar: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.82, alpha: 1)
        v.layer.cornerRadius = 3
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let calendarIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "calendar"))
        iv.tintColor = UIColor(red: 0.26, green: 0.57, blue: 0.80, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Select Date"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.91, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let pickerContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Lifecycle

    override func loadView() {
        // Build programmatically — the XIB is intentionally bypassed
        let root = UIView()
        root.backgroundColor = .clear
        view = root
        buildLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Layout

    private func buildLayout() {
        // Card
        view.addSubview(cardView)

        // Handle
        cardView.addSubview(handleBar)

        // Header
        cardView.addSubview(calendarIcon)
        cardView.addSubview(titleLabel)

        // Separator
        cardView.addSubview(separator)

        // Picker in a soft container
        pickerContainer.addSubview(datePicker)
        cardView.addSubview(pickerContainer)

        NSLayoutConstraint.activate([

            // Card fills view
            cardView.topAnchor.constraint(equalTo: view.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Handle bar — centered at the top
            handleBar.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            handleBar.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 44),
            handleBar.heightAnchor.constraint(equalToConstant: 5),

            // Calendar icon
            calendarIcon.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 20),
            calendarIcon.centerXAnchor.constraint(equalTo: cardView.centerXAnchor, constant: -52),
            calendarIcon.widthAnchor.constraint(equalToConstant: 22),
            calendarIcon.heightAnchor.constraint(equalToConstant: 22),

            // Title label — vertically aligned with icon
            titleLabel.centerYAnchor.constraint(equalTo: calendarIcon.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: calendarIcon.trailingAnchor, constant: 8),

            // Thin separator
            separator.topAnchor.constraint(equalTo: calendarIcon.bottomAnchor, constant: 18),
            separator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            separator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            separator.heightAnchor.constraint(equalToConstant: 1),

            // Picker container
            pickerContainer.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16),
            pickerContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            pickerContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            pickerContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),

            // Picker fills container with insets
            datePicker.topAnchor.constraint(equalTo: pickerContainer.topAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: pickerContainer.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: pickerContainer.trailingAnchor, constant: -8),
            datePicker.bottomAnchor.constraint(equalTo: pickerContainer.bottomAnchor, constant: -8),
        ])
    }
}

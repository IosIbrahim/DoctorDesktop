//
//  VitalSignsEntryViewController.swift
//  DoctorDesktop
//
//  Programmatic Add-Vital-Signs screen that mirrors the Android design:
//   - Patient header card
//   - Special Habits card
//   - Pain Scale slider (0-10)
//   - Patient Case + CTAS Score rows
//   - Special Needs checkboxes (Mute / Blind / Handicapped / Abuse / Neglect /
//     Suicide / Self harm)
//   - Full vitals grid (Bp, Temp, Pulse, RR, O2Sat, Height, Weight,
//     Blood sugar, Sugar urine, Urine albumin, Acetone urine, APAU,
//     Urine out, Peripheral pulse, Intra-abdominal pressure, O2 delivery,
//     Chest circumference, Total bilirubin, Head circumference,
//     Abdomen circumference, Spirometer)
//   - Save button
//
//  No XIB, no storyboard — everything is built in code so the design is
//  fully ours to shape.
//

import UIKit

final class VitalSignsEntryViewController: UIViewController {

  // MARK: - Dependencies
  private var presenter: VitalSignsEntryPresenter!
  private weak var navigationCoordinator: NavigationCoordinator?

  // MARK: - Theme
  private let teal       = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)
  private let tealDark   = UIColor(red: 0.18, green: 0.58, blue: 0.52, alpha: 1)
  private let tealTint   = UIColor(red: 0.93, green: 0.98, blue: 0.97, alpha: 1)
  private let cardBg     = UIColor.white
  private let pageBg     = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1)
  private let hairline   = UIColor(white: 0.88, alpha: 1)
  private let labelColor = UIColor(white: 0.25, alpha: 1)
  private let subColor   = UIColor(white: 0.45, alpha: 1)

  // MARK: - State
  private var values = VitalSignsEntryValues()

  // Retained references so `readValues()` can pull text out at Save time.
  private var vitalFields: [String: UITextField] = [:]
  private var checkboxButtons: [String: UIButton] = [:]
  private var painValueLabel: UILabel!
  private var painSlider: UISlider!
  private var patientCaseValueLabel: UILabel!
  private var ctasValueLabel: UILabel!

  // Root scroll container
  private let scrollView = UIScrollView()
  private let contentStack = UIStackView()

  // MARK: - Configuration
  func configure(with presenter: VitalSignsEntryPresenter,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.navigationCoordinator = navigationCoordinator
  }

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = pageBg
    title = presenter.screenTitle
    setupNavigationBar()
    setupScrollContainer()
    buildContent()
  }

  // MARK: - Nav bar
  private func setupNavigationBar() {
    navigationItem.largeTitleDisplayMode = .never
    let back = UIBarButtonItem(title: "Back", style: .plain,
                               target: self, action: #selector(didTapBack))
    back.tintColor = teal
    navigationItem.leftBarButtonItem = back
  }

  @objc private func didTapBack() {
    navigationCoordinator?.movingBack()
    navigationController?.popViewController(animated: true)
  }

  // MARK: - Scroll container
  private func setupScrollContainer() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.alwaysBounceVertical = true
    scrollView.keyboardDismissMode = .interactive
    view.addSubview(scrollView)

    contentStack.translatesAutoresizingMaskIntoConstraints = false
    contentStack.axis = .vertical
    contentStack.spacing = 14
    contentStack.alignment = .fill
    contentStack.distribution = .fill
    scrollView.addSubview(contentStack)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 14),
      contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
      contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 14),
      contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -14),
      contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -28)
    ])

    // Tap to dismiss keyboard
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tap.cancelsTouchesInView = false
    scrollView.addGestureRecognizer(tap)
  }

  @objc private func dismissKeyboard() { view.endEditing(true) }

  // MARK: - Content
  private func buildContent() {
    contentStack.addArrangedSubview(makePatientHeaderCard())
    contentStack.addArrangedSubview(makeSpecialHabitsCard())
    contentStack.addArrangedSubview(makePainScaleCard())
    contentStack.addArrangedSubview(makePickerRowCard(
      title: "Patient Case",
      valueBinding: { [weak self] in self?.patientCaseValueLabel = $0 },
      onTap: #selector(didTapPatientCase)
    ))
    contentStack.addArrangedSubview(makePickerRowCard(
      title: "CTAS Evidence-based Score",
      valueBinding: { [weak self] in self?.ctasValueLabel = $0 },
      onTap: #selector(didTapCTAS)
    ))
    contentStack.addArrangedSubview(makeSpecialNeedsCard())
    contentStack.addArrangedSubview(makeVitalsCard())
    contentStack.addArrangedSubview(makeSaveButton())
  }

  // MARK: - Card builder helpers
  private func makeCard() -> UIView {
    let v = UIView()
    v.backgroundColor = cardBg
    v.layer.cornerRadius = 10
    v.layer.borderWidth = 1 / UIScreen.main.scale
    v.layer.borderColor = hairline.cgColor
    v.layer.shadowColor = UIColor.black.cgColor
    v.layer.shadowOpacity = 0.04
    v.layer.shadowRadius = 3
    v.layer.shadowOffset = CGSize(width: 0, height: 1)
    return v
  }

  private func makeCardTitle(_ text: String) -> UILabel {
    let l = UILabel()
    l.text = text
    l.textColor = teal
    l.font = UIFont.systemFont(ofSize: 15, weight: .bold)
    return l
  }

  private func wrapInCard(_ inner: UIView,
                          title: String? = nil,
                          padding: UIEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)) -> UIView {
    let card = makeCard()
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 10
    if let title = title {
      stack.addArrangedSubview(makeCardTitle(title))
      let sep = UIView()
      sep.backgroundColor = hairline
      sep.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
      stack.addArrangedSubview(sep)
    }
    stack.addArrangedSubview(inner)
    card.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: card.topAnchor, constant: padding.top),
      stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: padding.left),
      stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -padding.right),
      stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -padding.bottom)
    ])
    return card
  }

  // MARK: - Patient header
  private func makePatientHeaderCard() -> UIView {
    let card = makeCard()
    card.backgroundColor = teal

    let nameLabel = UILabel()
    nameLabel.text = presenter.patientDisplayName
    nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
    nameLabel.textColor = .white

    let subLabel = UILabel()
    subLabel.text = presenter.patientDisplaySubtitle
    subLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    subLabel.textColor = UIColor.white.withAlphaComponent(0.9)

    let icon = UIImageView()
    icon.tintColor = .white
    icon.contentMode = .scaleAspectFit
    if #available(iOS 13, *) {
      icon.image = UIImage(systemName: "person.crop.circle.fill")
    }
    icon.setContentHuggingPriority(.required, for: .horizontal)

    let textStack = UIStackView(arrangedSubviews: [nameLabel, subLabel])
    textStack.axis = .vertical
    textStack.spacing = 2

    let row = UIStackView(arrangedSubviews: [icon, textStack])
    row.axis = .horizontal
    row.spacing = 12
    row.alignment = .center
    row.translatesAutoresizingMaskIntoConstraints = false

    card.addSubview(row)
    NSLayoutConstraint.activate([
      row.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
      row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
      row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
      row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
      icon.widthAnchor.constraint(equalToConstant: 36),
      icon.heightAnchor.constraint(equalToConstant: 36)
    ])
    return card
  }

  // MARK: - Special Habits
  private func makeSpecialHabitsCard() -> UIView {
    let field = makePlainTextField(placeholder: "e.g. smoking, alcohol, none…")
    field.heightAnchor.constraint(equalToConstant: 40).isActive = true
    return wrapInCard(field, title: "Special Habits")
  }

  // MARK: - Pain Scale
  private func makePainScaleCard() -> UIView {
    let header = UILabel()
    header.text = "Pain Scale"
    header.textColor = teal
    header.font = UIFont.systemFont(ofSize: 15, weight: .bold)

    painValueLabel = UILabel()
    painValueLabel.text = "0"
    painValueLabel.textColor = .white
    painValueLabel.textAlignment = .center
    painValueLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
    painValueLabel.backgroundColor = teal
    painValueLabel.layer.cornerRadius = 12
    painValueLabel.layer.masksToBounds = true
    painValueLabel.translatesAutoresizingMaskIntoConstraints = false
    painValueLabel.widthAnchor.constraint(equalToConstant: 36).isActive = true
    painValueLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true

    let headerRow = UIStackView(arrangedSubviews: [header, UIView(), painValueLabel])
    headerRow.axis = .horizontal
    headerRow.alignment = .center
    headerRow.spacing = 8

    painSlider = UISlider()
    painSlider.minimumValue = 0
    painSlider.maximumValue = 10
    painSlider.value = 0
    painSlider.minimumTrackTintColor = teal
    painSlider.maximumTrackTintColor = hairline
    painSlider.thumbTintColor = teal
    painSlider.addTarget(self, action: #selector(painChanged(_:)), for: .valueChanged)

    let minL = UILabel()
    minL.text = "0"
    minL.font = UIFont.systemFont(ofSize: 11)
    minL.textColor = subColor
    let maxL = UILabel()
    maxL.text = "10"
    maxL.font = UIFont.systemFont(ofSize: 11)
    maxL.textColor = subColor

    let scaleRow = UIStackView(arrangedSubviews: [minL, painSlider, maxL])
    scaleRow.axis = .horizontal
    scaleRow.spacing = 8
    scaleRow.alignment = .center

    let stack = UIStackView(arrangedSubviews: [headerRow, scaleRow])
    stack.axis = .vertical
    stack.spacing = 8

    return wrapInCard(stack)
  }

  @objc private func painChanged(_ s: UISlider) {
    let v = Int(s.value.rounded())
    s.value = Float(v)
    values.painScale = v
    painValueLabel.text = "\(v)"
  }

  // MARK: - Picker-style rows (Patient Case / CTAS)
  private func makePickerRowCard(title: String,
                                 valueBinding: (UILabel) -> Void,
                                 onTap: Selector) -> UIView {
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    titleLabel.textColor = labelColor

    let valueLabel = UILabel()
    valueLabel.text = "Select…"
    valueLabel.textColor = subColor
    valueLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    valueLabel.textAlignment = .right
    valueBinding(valueLabel)

    let chevron = UIImageView()
    chevron.tintColor = subColor
    chevron.contentMode = .scaleAspectFit
    if #available(iOS 13, *) { chevron.image = UIImage(systemName: "chevron.right") }
    chevron.widthAnchor.constraint(equalToConstant: 12).isActive = true

    let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel, chevron])
    row.axis = .horizontal
    row.alignment = .center
    row.spacing = 10

    let card = wrapInCard(row,
                          padding: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
    let tap = UITapGestureRecognizer(target: self, action: onTap)
    card.addGestureRecognizer(tap)
    card.isUserInteractionEnabled = true
    return card
  }

  @objc private func didTapPatientCase() {
    presentSingleChoice(title: "Patient Case",
                        options: ["Stable", "Unstable", "Critical", "Urgent", "Non-urgent"]) { [weak self] choice in
      guard let self = self else { return }
      self.values.patientCase = choice
      self.patientCaseValueLabel.text = choice
      self.patientCaseValueLabel.textColor = self.labelColor
    }
  }

  @objc private func didTapCTAS() {
    presentSingleChoice(title: "CTAS Score",
                        options: ["CTAS 1 - Resuscitation",
                                  "CTAS 2 - Emergent",
                                  "CTAS 3 - Urgent",
                                  "CTAS 4 - Less Urgent",
                                  "CTAS 5 - Non Urgent"]) { [weak self] choice in
      guard let self = self else { return }
      self.values.ctasScore = choice
      self.ctasValueLabel.text = choice
      self.ctasValueLabel.textColor = self.labelColor
    }
  }

  private func presentSingleChoice(title: String,
                                   options: [String],
                                   handler: @escaping (String) -> Void) {
    let sheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
    for o in options {
      sheet.addAction(UIAlertAction(title: o, style: .default) { _ in handler(o) })
    }
    sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    // iPad popover anchor
    if let pop = sheet.popoverPresentationController {
      pop.sourceView = self.view
      pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
      pop.permittedArrowDirections = []
    }
    present(sheet, animated: true)
  }

  // MARK: - Special Needs checkboxes
  private func makeSpecialNeedsCard() -> UIView {
    let items: [(String, String)] = [
      ("mute", "Mute"), ("blind", "Blind"), ("handicapped", "Handicapped"),
      ("abuse", "Abuse"), ("neglect", "Neglect"),
      ("suicide", "Suicide"), ("selfharm", "Self harm")
    ]

    // Two-column grid via rows of stacks
    let grid = UIStackView()
    grid.axis = .vertical
    grid.spacing = 10
    grid.alignment = .fill

    var rowStack: UIStackView? = nil
    for (index, item) in items.enumerated() {
      if index % 2 == 0 {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually
        grid.addArrangedSubview(row)
        rowStack = row
      }
      rowStack?.addArrangedSubview(makeCheckbox(key: item.0, title: item.1))
    }
    // If odd count, pad last row so checkboxes stay sized evenly.
    if items.count % 2 != 0 {
      rowStack?.addArrangedSubview(UIView())
    }

    return wrapInCard(grid, title: "Special Needs")
  }

  private func makeCheckbox(key: String, title: String) -> UIView {
    let btn = UIButton(type: .system)
    btn.setTitle("  " + title, for: .normal)
    btn.setTitleColor(labelColor, for: .normal)
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    btn.contentHorizontalAlignment = .left
    btn.tintColor = teal
    if #available(iOS 13, *) {
      btn.setImage(UIImage(systemName: "square"), for: .normal)
      btn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
    }
    btn.addTarget(self, action: #selector(toggleCheckbox(_:)), for: .touchUpInside)
    btn.accessibilityIdentifier = key
    btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
    checkboxButtons[key] = btn
    return btn
  }

  @objc private func toggleCheckbox(_ sender: UIButton) {
    sender.isSelected.toggle()
    guard let key = sender.accessibilityIdentifier else { return }
    switch key {
    case "mute":        values.isMute = sender.isSelected
    case "blind":       values.isBlind = sender.isSelected
    case "handicapped": values.isHandicapped = sender.isSelected
    case "abuse":       values.hasAbuse = sender.isSelected
    case "neglect":     values.hasNeglect = sender.isSelected
    case "suicide":     values.hasSuicide = sender.isSelected
    case "selfharm":    values.hasSelfHarm = sender.isSelected
    default: break
      }
  }

  // MARK: - Vitals grid
  private func makeVitalsCard() -> UIView {
    // Each entry = (fieldKey, label, placeholder, keyboard)
    // BP handled specially as two fields on the same line.
    let container = UIStackView()
    container.axis = .vertical
    container.spacing = 12
    container.alignment = .fill

    // BP row (Systolic / Diastolic)
    container.addArrangedSubview(makeBpRow())

    let singles: [(String, String, String, UIKeyboardType)] = [
      ("temperature",            "Temp",                    "°C",       .decimalPad),
      ("pulse",                  "Pulse",                   "bpm",      .numberPad),
      ("respiratoryRate",        "Respiratory Rate",        "/min",     .numberPad),
      ("o2Sat",                  "O2 Sat",                  "%",        .decimalPad),
      ("height",                 "Height",                  "cm",       .decimalPad),
      ("weight",                 "Weight",                  "kg",       .decimalPad),
      ("bloodSugar",             "Blood Sugar",             "mg/dL",    .decimalPad),
      ("sugarUrine",             "Sugar Urine",             "",         .default),
      ("urineAlbumin",           "Urine Albumin",           "",         .default),
      ("acetoneUrine",           "Acetone Urine",           "",         .default),
      ("apau",                   "APAU",                    "",         .default),
      ("urineOut",               "Urine Out",               "mL",       .numberPad),
      ("peripheralPulse",        "Peripheral Pulse",        "",         .default),
      ("intraAbdominalPressure", "Intra-abdominal Pressure","mmHg",     .decimalPad),
      ("o2Delivery",             "O2 Delivery",             "",         .default),
      ("chestCircumference",     "Chest Circumference",     "cm",       .decimalPad),
      ("totalBilirubin",         "Total Bilirubin",         "mg/dL",    .decimalPad),
      ("headCircumference",      "Head Circumference",      "cm",       .decimalPad),
      ("abdomenCircumference",   "Abdomen Circumference",   "cm",       .decimalPad),
      ("spirometer",             "Spirometer",              "",         .default)
    ]

    // Two-per-row grid
    var rowStack: UIStackView? = nil
    for (index, v) in singles.enumerated() {
      if index % 2 == 0 {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually
        container.addArrangedSubview(row)
        rowStack = row
      }
      rowStack?.addArrangedSubview(makeVitalField(key: v.0, label: v.1,
                                                  placeholder: v.2, keyboard: v.3))
    }
    if singles.count % 2 != 0 { rowStack?.addArrangedSubview(UIView()) }

    return wrapInCard(container, title: "Vitals")
  }

  private func makeBpRow() -> UIView {
    let label = UILabel()
    label.text = "Blood Pressure"
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.textColor = subColor

    let sys = makePlainTextField(placeholder: "Systolic")
    sys.keyboardType = .numberPad
    sys.accessibilityIdentifier = "bpSystolic"
    vitalFields["bpSystolic"] = sys

    let slash = UILabel()
    slash.text = "/"
    slash.textColor = labelColor
    slash.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    slash.setContentHuggingPriority(.required, for: .horizontal)

    let dia = makePlainTextField(placeholder: "Diastolic")
    dia.keyboardType = .numberPad
    dia.accessibilityIdentifier = "bpDiastolic"
    vitalFields["bpDiastolic"] = dia

    let row = UIStackView(arrangedSubviews: [sys, slash, dia])
    row.axis = .horizontal
    row.spacing = 8
    row.alignment = .center
    row.distribution = .fill
    sys.widthAnchor.constraint(equalTo: dia.widthAnchor).isActive = true

    let stack = UIStackView(arrangedSubviews: [label, row])
    stack.axis = .vertical
    stack.spacing = 6
    return stack
  }

  private func makeVitalField(key: String, label: String,
                              placeholder: String, keyboard: UIKeyboardType) -> UIView {
    let l = UILabel()
    l.text = label
    l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    l.textColor = subColor

    let tf = makePlainTextField(placeholder: placeholder)
    tf.keyboardType = keyboard
    tf.accessibilityIdentifier = key
    vitalFields[key] = tf

    let stack = UIStackView(arrangedSubviews: [l, tf])
    stack.axis = .vertical
    stack.spacing = 6
    return stack
  }

  private func makePlainTextField(placeholder: String) -> UITextField {
    let tf = UITextField()
    tf.placeholder = placeholder
    tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    tf.textColor = labelColor
    tf.borderStyle = .none
    tf.backgroundColor = tealTint
    tf.layer.cornerRadius = 8
    tf.heightAnchor.constraint(equalToConstant: 38).isActive = true
    // Left/right padding views
    let pad = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
    tf.leftView = pad
    tf.leftViewMode = .always
    tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
    tf.rightViewMode = .always
    tf.returnKeyType = .done
    tf.delegate = self
    return tf
  }

  // MARK: - Save
  private func makeSaveButton() -> UIView {
    let btn = UIButton(type: .system)
    btn.setTitle("Save", for: .normal)
    btn.setTitleColor(.white, for: .normal)
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    btn.backgroundColor = teal
    btn.layer.cornerRadius = 10
    btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
    btn.layer.shadowColor = UIColor.black.cgColor
    btn.layer.shadowOpacity = 0.1
    btn.layer.shadowRadius = 4
    btn.layer.shadowOffset = CGSize(width: 0, height: 2)
    btn.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
    return btn
  }

  @objc private func didTapSave() {
    view.endEditing(true)
    readValues()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    spinner.startAnimating()
    spinner.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(spinner)
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])

    presenter.save(values: values) { [weak self] success in
      spinner.stopAnimating()
      spinner.removeFromSuperview()
      guard let self = self else { return }
      let title = success ? "Saved" : "Error"
      let msg   = success ? "Vital signs recorded successfully." : "Could not save vital signs."
      let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
        if success {
          self.navigationCoordinator?.movingBack()
          self.navigationController?.popViewController(animated: true)
        }
      })
      self.present(alert, animated: true)
    }
  }

  private func readValues() {
    func text(_ key: String) -> String? {
      let t = vitalFields[key]?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
      return (t?.isEmpty ?? true) ? nil : t
    }
    values.bpSystolic            = text("bpSystolic")
    values.bpDiastolic           = text("bpDiastolic")
    values.temperature           = text("temperature")
    values.pulse                 = text("pulse")
    values.respiratoryRate       = text("respiratoryRate")
    values.o2Sat                 = text("o2Sat")
    values.height                = text("height")
    values.weight                = text("weight")
    values.bloodSugar            = text("bloodSugar")
    values.sugarUrine            = text("sugarUrine")
    values.urineAlbumin          = text("urineAlbumin")
    values.acetoneUrine          = text("acetoneUrine")
    values.apau                  = text("apau")
    values.urineOut              = text("urineOut")
    values.peripheralPulse       = text("peripheralPulse")
    values.intraAbdominalPressure = text("intraAbdominalPressure")
    values.o2Delivery            = text("o2Delivery")
    values.chestCircumference    = text("chestCircumference")
    values.totalBilirubin        = text("totalBilirubin")
    values.headCircumference     = text("headCircumference")
    values.abdomenCircumference  = text("abdomenCircumference")
    values.spirometer            = text("spirometer")
  }
}

// MARK: - UITextFieldDelegate
extension VitalSignsEntryViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

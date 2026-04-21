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

  // Special-Habits specific
  private var habitsHasButton: UIButton!
  private var habitsNoneButton: UIButton!
  private var habitsOptionsStack: UIStackView!
  private var habitCheckboxes: [String: UIButton] = [:]

  // Vital Signs History table — inner stack is repopulated once API responds
  private var vitalHistoryInnerStack: UIStackView!

  // Visit History card — inner stack is repopulated once the API responds
  private var visitHistoryInnerStack: UIStackView!

  // Root scroll container
  private let scrollView = UIScrollView()
  private let contentStack = UIStackView()

  // MARK: - Configuration
  func configure(with presenter: VitalSignsEntryPresenter,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.navigationCoordinator = navigationCoordinator
  }

  /// When the server returned a CTAS row, we show it verbatim and skip the
  /// local auto-calc so we never disagree with the backend.
  private var serverCTAS: UCAFCTASServer?

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = pageBg
    title = presenter.screenTitle
    setupNavigationBar()
    setupScrollContainer()
    buildContent()
    loadInitialData()
  }

  // MARK: - Backend load
  private func loadInitialData() {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()
    view.addSubview(spinner)
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
    ])

    // Fire both API calls in parallel; apply each result as it arrives.
    presenter.loadInitialData { [weak self] ucaf, ctas in
      guard let self = self else { return }
      if let ucaf = ucaf { self.applyLoadedUcaf(ucaf) }
      self.serverCTAS = ctas
      if ctas != nil { self.applyServerCTAS() } else { self.recomputeCTAS() }
    }

    presenter.loadSpecialHabits { [weak self] habits in
      spinner.stopAnimating()
      spinner.removeFromSuperview()
      guard let self = self else { return }
      if let habits = habits { self.applyLoadedHabits(habits) }
    }

    presenter.loadPatientHistory { [weak self] history in
      guard let self = self else { return }
      self.applyPatientHistory(history)
    }

    presenter.loadVitalSignsHistory { [weak self] vitals in
      guard let self = self else { return }
      self.applyVitalSignsHistory(vitals)
    }
  }

  private func applyLoadedHabits(_ d: SpecialHabitsData) {
    let on: (String?) -> Bool = { ($0 ?? "").trimmingCharacters(in: .whitespaces) == "1" }

    if d.hasHabits {
      // Select "Has Special Habits" radio and reveal checkboxes
      habitsHasButton?.isSelected  = true
      habitsNoneButton?.isSelected = false
      values.hasSpecialHabits = true
      habitsOptionsStack?.isHidden = false
      habitsOptionsStack?.alpha    = 1
    } else {
      habitsNoneButton?.isSelected = true
      habitsHasButton?.isSelected  = false
      values.hasSpecialHabits = false
    }

    // Individual habit checkboxes
    setHabitCheckbox("alcohol",      on: on(d.alcoholFlag),     bind: &values.habitAlcohol)
    setHabitCheckbox("smoker",       on: on(d.smokerFlag),      bind: &values.habitSmoker)
    setHabitCheckbox("morphine",     on: on(d.morphineFlag),    bind: &values.habitMorphine)
    setHabitCheckbox("cannabinoid",  on: on(d.cannabinoidFlag), bind: &values.habitCannabinoid)
    setHabitCheckbox("substanceUse", on: on(d.drugsFlag),       bind: &values.habitSubstanceUse)
    setHabitCheckbox("shisha",       on: on(d.shishaFlag),      bind: &values.habitShisha)
    setHabitCheckbox("vape",         on: on(d.vapeFlag),        bind: &values.habitVape)
    setHabitCheckbox("other",        on: on(d.otherFlag),       bind: &values.habitOther)
  }

  private func setHabitCheckbox(_ key: String, on: Bool, bind: inout Bool) {
    habitCheckboxes[key]?.isSelected = on
    bind = on
  }

  private func applyLoadedUcaf(_ d: UCAFLoadData) {
    // Vitals
    vitalFields["bpSystolic"]?.text           = d.bp
    vitalFields["bpDiastolic"]?.text          = d.pb2
    vitalFields["pulse"]?.text                = d.pulse
    vitalFields["temperature"]?.text          = d.temp
    vitalFields["respiratoryRate"]?.text      = d.respiratoryRate
    vitalFields["o2Sat"]?.text                = d.o2Sat
    vitalFields["bloodSugar"]?.text           = d.bloodGlucose
    vitalFields["height"]?.text               = d.height
    vitalFields["weight"]?.text               = d.weight
    vitalFields["headCircumference"]?.text    = d.headDiameter

    // Pain scale (0..10)
    if let s = d.painScaleAdultScore, let iv = Int(s), iv >= 0, iv <= 10 {
      values.painScale = iv
      painSlider?.value = Float(iv)
      painValueLabel?.text = "\(iv)"
    }

    // Special-needs flags ("1" = on)
    let on: (String?) -> Bool = { ($0 ?? "").trimmingCharacters(in: .whitespaces) == "1" }
    setCheckbox("mute",        on: on(d.muteFlag),        bind: &values.isMute)
    setCheckbox("blind",       on: on(d.deafFlag),        bind: &values.isBlind)
    setCheckbox("handicapped", on: on(d.handicappedFlag), bind: &values.isHandicapped)
    setCheckbox("abuse",       on: on(d.abuseFlag),       bind: &values.hasAbuse)
    setCheckbox("neglect",     on: on(d.neglectFlag),     bind: &values.hasNeglect)
    setCheckbox("suicide",     on: on(d.suicideFlag),     bind: &values.hasSuicide)
    setCheckbox("selfharm",    on: on(d.selfHarmFlag),    bind: &values.hasSelfHarm)
  }

  private func setCheckbox(_ key: String, on: Bool, bind: inout Bool) {
    checkboxButtons[key]?.isSelected = on
    bind = on
  }

  /// Parses "#RRGGBB" / "RRGGBB" hex into UIColor. Returns nil for malformed
  /// input so the caller can fall back to the default CTAS-level color.
  private static func colorFromHex(_ hex: String) -> UIColor? {
    var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if s.hasPrefix("#") { s.removeFirst() }
    guard s.count == 6 else { return nil }
    var v: UInt32 = 0
    guard Scanner(string: s).scanHexInt32(&v) else { return nil }
    let r = CGFloat((v & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((v & 0x00FF00) >> 8)  / 255.0
    let b = CGFloat( v & 0x0000FF)        / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: 1)
  }

  private func applyServerCTAS() {
    guard let ctas = serverCTAS else { return }
    let level = Int(ctas.totalItemScore ?? "") ?? 5
    let conclusion = (ctas.conclusionDesc ?? "").trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
    let title = conclusion.isEmpty ? ctasTitle(forLevel: level) : "CTAS \(level) — \(conclusion)"
    ctasValueLabel?.text = title
    ctasValueLabel?.textColor = labelColor
    ctasBadge?.text = "\(level)"
    if let hex = ctas.conclusionColor, let c = Self.colorFromHex(hex) {
      ctasBadge?.backgroundColor = c
    } else {
      ctasBadge?.backgroundColor = ctasColor(forLevel: level)
    }
    values.ctasScore = title
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
    contentStack.addArrangedSubview(makeVitalSignsHistoryCard())
    contentStack.addArrangedSubview(makeVisitHistoryCard())
    contentStack.addArrangedSubview(makeSpecialHabitsCard())
    contentStack.addArrangedSubview(makePainScaleCard())
    contentStack.addArrangedSubview(makePickerRowCard(
      title: "Patient Case",
      valueBinding: { [weak self] in self?.patientCaseValueLabel = $0 },
      onTap: #selector(didTapPatientCase)
    ))
    contentStack.addArrangedSubview(makeCTASCard())
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

  // MARK: - Vital Signs History (table)

  /// Shared date formatter — "16/04/2026\n18:27:29" to match the screenshot.
  private static let vsFmt1: DateFormatter = {
    let df = DateFormatter(); df.dateFormat = "dd/MM/yyyy"; return df
  }()
  private static let vsFmt2: DateFormatter = {
    let df = DateFormatter(); df.dateFormat = "HH:mm:ss"; return df
  }()

  /// Builds the skeleton card. `vitalHistoryInnerStack` holds the header + data
  /// rows and is repopulated by `applyVitalSignsHistory` once the API responds.
  private func makeVitalSignsHistoryCard() -> UIView {
    let card = makeCard()
    card.clipsToBounds = true       // required so teal header row clips to corner radius

    // ── Card title ────────────────────────────────────────────────────────
    let titleLabel = makeCardTitle("Vital Signs History")
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let titleSep = UIView()
    titleSep.backgroundColor = hairline
    titleSep.translatesAutoresizingMaskIntoConstraints = false

    // ── Table container ───────────────────────────────────────────────────
    vitalHistoryInnerStack = UIStackView()
    vitalHistoryInnerStack.axis = .vertical
    vitalHistoryInnerStack.spacing = 0
    vitalHistoryInnerStack.alignment = .fill
    vitalHistoryInnerStack.translatesAutoresizingMaskIntoConstraints = false

    // Column header row
    vitalHistoryInnerStack.addArrangedSubview(makeVSHeaderRow())

    // Loading placeholder — replaced by applyVitalSignsHistory
    let loading = UILabel()
    loading.text = "  Loading vital signs history…"
    loading.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    loading.textColor = subColor
    loading.heightAnchor.constraint(equalToConstant: 38).isActive = true
    vitalHistoryInnerStack.addArrangedSubview(loading)

    card.addSubview(titleLabel)
    card.addSubview(titleSep)
    card.addSubview(vitalHistoryInnerStack)

    NSLayoutConstraint.activate([
      // Title — inset 14pt from card edges
      titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
      titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
      titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

      // Full-width separator under title
      titleSep.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      titleSep.leadingAnchor.constraint(equalTo: card.leadingAnchor),
      titleSep.trailingAnchor.constraint(equalTo: card.trailingAnchor),
      titleSep.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

      // Table runs full-width, edge-to-edge (no horizontal inset)
      vitalHistoryInnerStack.topAnchor.constraint(equalTo: titleSep.bottomAnchor),
      vitalHistoryInnerStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
      vitalHistoryInnerStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
      vitalHistoryInnerStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
    ])

    return card
  }

  /// Teal column-header row: Name | Result | Previous | Previous
  private func makeVSHeaderRow() -> UIView {
    let container = UIView()
    container.backgroundColor = teal
    container.heightAnchor.constraint(equalToConstant: 36).isActive = true

    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 0
    stack.distribution = .fill
    stack.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      stack.topAnchor.constraint(equalTo: container.topAnchor),
      stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])

    let nameH = makeVSHeaderLabel("Name",     alignment: .left, leadInset: 10)
    let r0    = makeVSHeaderLabel("Result",   alignment: .center)
    let r1    = makeVSHeaderLabel("Previous", alignment: .center)
    let r2    = makeVSHeaderLabel("Previous", alignment: .center)

    [nameH, r0, r1, r2].forEach { stack.addArrangedSubview($0) }
    r0.widthAnchor.constraint(equalToConstant: 72).isActive = true
    r1.widthAnchor.constraint(equalTo: r0.widthAnchor).isActive = true
    r2.widthAnchor.constraint(equalTo: r0.widthAnchor).isActive = true

    return container
  }

  private func makeVSHeaderLabel(_ text: String,
                                  alignment: NSTextAlignment,
                                  leadInset: CGFloat = 2) -> UIView {
    let label = UILabel()
    label.text = text
    label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    label.textColor = .white
    label.textAlignment = alignment
    label.translatesAutoresizingMaskIntoConstraints = false
    let container = UIView()
    container.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: container.topAnchor),
      label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leadInset),
      label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -2)
    ])
    return container
  }

  /// Removes all rows except the teal header, then rebuilds from `vitals`.
  private func applyVitalSignsHistory(_ vitals: [VitalSign]) {
    guard let stack = vitalHistoryInnerStack else { return }

    // Keep only [0] header row; drop the loading placeholder / previous rows.
    stack.arrangedSubviews.dropFirst().forEach { $0.removeFromSuperview() }

    if vitals.isEmpty {
      let empty = UILabel()
      empty.text = "  No vital signs recorded for this visit"
      empty.font = UIFont.systemFont(ofSize: 12, weight: .regular)
      empty.textColor = subColor
      empty.heightAnchor.constraint(equalToConstant: 38).isActive = true
      stack.addArrangedSubview(empty)
      return
    }

    for (index, vital) in vitals.enumerated() {
      stack.addArrangedSubview(makeVSDataRow(vital: vital, isEven: index % 2 == 0))
      // Hairline between rows (not after the last one)
      if index < vitals.count - 1 {
        let sep = UIView()
        sep.backgroundColor = hairline
        sep.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        stack.addArrangedSubview(sep)
      }
    }
  }

  /// One alternating-background table row for a single vital sign type.
  private func makeVSDataRow(vital: VitalSign, isEven: Bool) -> UIView {
    let container = UIView()
    container.backgroundColor = isEven ? cardBg : tealTint
    container.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true

    let row = UIStackView()
    row.axis = .horizontal
    row.spacing = 0
    row.distribution = .fill
    row.alignment = .center
    row.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(row)
    NSLayoutConstraint.activate([
      row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      row.topAnchor.constraint(equalTo: container.topAnchor),
      row.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])

    let details = vital.details ?? []
    let nameCell = makeVSNameCell(vital: vital)
    let v0 = makeVSValueCell(details.count > 0 ? details[0] : nil)
    let v1 = makeVSValueCell(details.count > 1 ? details[1] : nil)
    let v2 = makeVSValueCell(details.count > 2 ? details[2] : nil)

    [nameCell, v0, v1, v2].forEach { row.addArrangedSubview($0) }

    // Three equal-width value columns; name takes the remaining space.
    v0.widthAnchor.constraint(equalToConstant: 72).isActive = true
    v1.widthAnchor.constraint(equalTo: v0.widthAnchor).isActive = true
    v2.widthAnchor.constraint(equalTo: v0.widthAnchor).isActive = true

    return container
  }

  /// Left cell: vital name (teal) + bar-chart SF Symbol icon.
  private func makeVSNameCell(vital: VitalSign) -> UIView {
    let nameLabel = UILabel()
    nameLabel.text = vital.englishName
    nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    nameLabel.textColor = teal
    nameLabel.numberOfLines = 2
    nameLabel.lineBreakMode = .byWordWrapping

    let icon = UIImageView()
    icon.tintColor = teal
    icon.contentMode = .scaleAspectFit
    if #available(iOS 13, *) { icon.image = UIImage(systemName: "chart.bar.fill") }
    icon.widthAnchor.constraint(equalToConstant: 14).isActive = true
    icon.heightAnchor.constraint(equalToConstant: 14).isActive = true
    icon.setContentHuggingPriority(.required, for: .horizontal)

    let hStack = UIStackView(arrangedSubviews: [nameLabel, icon])
    hStack.axis = .horizontal
    hStack.spacing = 4
    hStack.alignment = .center
    hStack.translatesAutoresizingMaskIntoConstraints = false

    let container = UIView()
    container.addSubview(hStack)
    NSLayoutConstraint.activate([
      hStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
      hStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
      hStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
      hStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
    ])
    return container
  }

  /// Value cell: bold reading value on top, smaller date below.
  private func makeVSValueCell(_ detail: VitalSign.VitalSignDetail?) -> UIView {
    let container = UIView()
    guard let detail = detail else { return container }

    // Combine systolic + diastolic (or any two-part reading)
    let valueStr: String
    if let other = detail.itemValueOther,
       !other.trimmingCharacters(in: .whitespaces).isEmpty,
       other != "0" {
      valueStr = detail.itemValue + " / " + other
    } else {
      valueStr = detail.itemValue
    }

    let dateStr = Self.vsFmt1.string(from: detail.itemDateTime)
              + "\n"
              + Self.vsFmt2.string(from: detail.itemDateTime)

    let valueLabel = UILabel()
    valueLabel.text = valueStr
    valueLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
    valueLabel.textColor = labelColor
    valueLabel.textAlignment = .center
    valueLabel.adjustsFontSizeToFitWidth = true
    valueLabel.minimumScaleFactor = 0.75

    let dateLabel = UILabel()
    dateLabel.text = dateStr
    dateLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
    dateLabel.textColor = subColor
    dateLabel.textAlignment = .center
    dateLabel.numberOfLines = 2

    let vStack = UIStackView(arrangedSubviews: [valueLabel, dateLabel])
    vStack.axis = .vertical
    vStack.spacing = 1
    vStack.alignment = .center
    vStack.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(vStack)
    NSLayoutConstraint.activate([
      vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
      vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -2),
      vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
      vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
    ])
    return container
  }

  // MARK: - Visit History card

  /// Builds the skeleton card with a "Loading…" placeholder. The inner stack
  /// is repopulated by `applyPatientHistory` once the API responds.
  private func makeVisitHistoryCard() -> UIView {
    visitHistoryInnerStack = UIStackView()
    visitHistoryInnerStack.axis = .vertical
    visitHistoryInnerStack.spacing = 8
    visitHistoryInnerStack.alignment = .fill

    let loading = UILabel()
    loading.text = "Loading visit history…"
    loading.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    loading.textColor = subColor
    visitHistoryInnerStack.addArrangedSubview(loading)

    return wrapInCard(visitHistoryInnerStack, title: "Visit History")
  }

  private func applyPatientHistory(_ history: PatientHistory?) {
    guard let stack = visitHistoryInnerStack else { return }

    // Clear placeholder / previous content.
    stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    guard let history = history else {
      let err = UILabel()
      err.text = "Visit history unavailable"
      err.font = UIFont.systemFont(ofSize: 12, weight: .regular)
      err.textColor = subColor
      stack.addArrangedSubview(err)
      return
    }

    // ── Current Doctor & Specialty ─────────────────────────────────────────
    let docName      = history.currentDoctor.name.isEmpty     ? "—" : history.currentDoctor.name
    let speciality   = history.currentSpeciality.name.isEmpty ? "—" : history.currentSpeciality.name

    stack.addArrangedSubview(makeHistoryInfoRow(icon: "person.fill",
                                                label: "Doctor",
                                                value: docName))
    stack.addArrangedSubview(makeHistoryInfoRow(icon: "stethoscope",
                                                label: "Specialty",
                                                value: speciality))

    // ── Recent visits (max 3, skip cancelled) ─────────────────────────────
    let recentVisits = history.patientVisits
      .filter { $0.cancelledVisit != "1" }
      .prefix(3)

    if recentVisits.isEmpty {
      let none = UILabel()
      none.text = "No recent visits"
      none.font = UIFont.systemFont(ofSize: 12, weight: .regular)
      none.textColor = subColor
      stack.addArrangedSubview(none)
      return
    }

    // Separator
    let sep = UIView()
    sep.backgroundColor = hairline
    sep.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
    stack.addArrangedSubview(sep)

    for visit in recentVisits {
      stack.addArrangedSubview(makeVisitRow(visit))
    }
  }

  /// Icon + label / value pair row used in the Visit History card.
  private func makeHistoryInfoRow(icon: String, label: String, value: String) -> UIView {
    let iconView = UIImageView()
    iconView.tintColor = teal
    iconView.contentMode = .scaleAspectFit
    if #available(iOS 13, *) { iconView.image = UIImage(systemName: icon) }
    iconView.widthAnchor.constraint(equalToConstant: 14).isActive = true
    iconView.heightAnchor.constraint(equalToConstant: 14).isActive = true

    let labelL = UILabel()
    labelL.text = label + ":"
    labelL.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    labelL.textColor = subColor
    labelL.setContentHuggingPriority(.required, for: .horizontal)
    labelL.widthAnchor.constraint(equalToConstant: 72).isActive = true

    let valueL = UILabel()
    valueL.text = value
    valueL.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    valueL.textColor = labelColor
    valueL.numberOfLines = 1
    valueL.lineBreakMode = .byTruncatingTail

    let row = UIStackView(arrangedSubviews: [iconView, labelL, valueL])
    row.axis = .horizontal
    row.spacing = 6
    row.alignment = .center
    return row
  }

  /// Compact single-line row for one visit entry.
  private func makeVisitRow(_ visit: PatientVisit) -> UIView {
    // Badge: "IP" (Inpatient) or "OP" (Outpatient) or "—"
    let badge = UILabel()
    badge.text  = visit.isInpatient ? "IP" : "OP"
    badge.font  = UIFont.systemFont(ofSize: 10, weight: .bold)
    badge.textColor  = .white
    badge.textAlignment = .center
    badge.backgroundColor = visit.isInpatient ? tealDark : teal
    badge.layer.cornerRadius = 4
    badge.layer.masksToBounds = true
    badge.widthAnchor.constraint(equalToConstant: 26).isActive = true
    badge.heightAnchor.constraint(equalToConstant: 18).isActive = true

    // Date label
    let dateL = UILabel()
    // Trim time portion "05/02/2025 05:05 pm" → "05/02/2025"
    let rawDate = visit.startDate ?? "—"
    dateL.text = String(rawDate.prefix(10))
    dateL.font = UIFont.systemFont(ofSize: 11, weight: .regular)
    dateL.textColor = labelColor
    dateL.setContentHuggingPriority(.required, for: .horizontal)

    // Clinic or speciality fallback
    let clinicL = UILabel()
    clinicL.text = visit.clinicNameEn ?? visit.specialityNameEn ?? visit.docCaseNameEn ?? "—"
    clinicL.font = UIFont.systemFont(ofSize: 11, weight: .regular)
    clinicL.textColor = subColor
    clinicL.numberOfLines = 1
    clinicL.lineBreakMode = .byTruncatingTail

    // Status pill
    let statusL = UILabel()
    let isOpen   = visit.isOpen
    statusL.text  = isOpen ? "Open" : (visit.endDateEn ?? "Closed")
    statusL.font  = UIFont.systemFont(ofSize: 10, weight: .semibold)
    statusL.textColor = isOpen
      ? UIColor(red: 0.15, green: 0.65, blue: 0.40, alpha: 1)
      : subColor
    statusL.setContentHuggingPriority(.required, for: .horizontal)

    let row = UIStackView(arrangedSubviews: [badge, dateL, clinicL, statusL])
    row.axis = .horizontal
    row.spacing = 8
    row.alignment = .center
    return row
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
    // Radio row: "Has Special Habits"  /  "No Known Special Habits"
    habitsHasButton  = makeRadioButton(title: "Has Special Habits")
    habitsNoneButton = makeRadioButton(title: "No Known Special Habits")
    habitsHasButton.addTarget(self, action: #selector(didTapHabitsHas),  for: .touchUpInside)
    habitsNoneButton.addTarget(self, action: #selector(didTapHabitsNone), for: .touchUpInside)

    let radioRow = UIStackView(arrangedSubviews: [habitsHasButton, habitsNoneButton])
    radioRow.axis = .horizontal
    radioRow.spacing = 12
    radioRow.distribution = .fillEqually

    // Options list (hidden until "Has Special Habits" is chosen)
    habitsOptionsStack = UIStackView()
    habitsOptionsStack.axis = .vertical
    habitsOptionsStack.spacing = 8
    habitsOptionsStack.isHidden = true

    let options: [(String, String)] = [
      ("alcohol",      "Alcohol"),
      ("smoker",       "Smoker"),
      ("morphine",     "Morphine"),
      ("cannabinoid",  "Cannabinoid"),
      ("substanceUse", "Substance use / Illicit drugs"),
      ("shisha",       "Shisha"),
      ("vape",         "Vape"),
      ("other",        "Other")
    ]
    for (key, title) in options {
      habitsOptionsStack.addArrangedSubview(makeHabitCheckbox(key: key, title: title))
    }

    let stack = UIStackView(arrangedSubviews: [radioRow, habitsOptionsStack])
    stack.axis = .vertical
    stack.spacing = 12

    return wrapInCard(stack, title: "Special Habits")
  }

  private func makeRadioButton(title: String) -> UIButton {
    let btn = UIButton(type: .system)
    btn.setTitle("  " + title, for: .normal)
    btn.setTitleColor(labelColor, for: .normal)
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    btn.titleLabel?.adjustsFontSizeToFitWidth = true
    btn.titleLabel?.minimumScaleFactor = 0.85
    btn.titleLabel?.lineBreakMode = .byTruncatingTail
    btn.contentHorizontalAlignment = .left
    btn.tintColor = teal
    if #available(iOS 13, *) {
      btn.setImage(UIImage(systemName: "circle"), for: .normal)
      btn.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .selected)
    }
    btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
    return btn
  }

  private func makeHabitCheckbox(key: String, title: String) -> UIButton {
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
    btn.accessibilityIdentifier = key
    btn.addTarget(self, action: #selector(toggleHabitCheckbox(_:)), for: .touchUpInside)
    btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
    habitCheckboxes[key] = btn
    return btn
  }

  @objc private func didTapHabitsHas() {
    habitsHasButton.isSelected = true
    habitsNoneButton.isSelected = false
    values.hasSpecialHabits = true
    setHabitsOptions(visible: true)
  }

  @objc private func didTapHabitsNone() {
    habitsHasButton.isSelected = false
    habitsNoneButton.isSelected = true
    values.hasSpecialHabits = false
    // Also clear any ticked options so "None" is actually consistent.
    clearHabitOptions()
    setHabitsOptions(visible: false)
  }

  private func setHabitsOptions(visible: Bool) {
    UIView.animate(withDuration: 0.2) {
      self.habitsOptionsStack.isHidden = !visible
      self.habitsOptionsStack.alpha = visible ? 1 : 0
      self.view.layoutIfNeeded()
    }
  }

  private func clearHabitOptions() {
    for (_, btn) in habitCheckboxes { btn.isSelected = false }
    values.habitAlcohol = false
    values.habitSmoker = false
    values.habitMorphine = false
    values.habitCannabinoid = false
    values.habitSubstanceUse = false
    values.habitShisha = false
    values.habitVape = false
    values.habitOther = false
  }

  @objc private func toggleHabitCheckbox(_ sender: UIButton) {
    sender.isSelected.toggle()
    guard let key = sender.accessibilityIdentifier else { return }
    switch key {
    case "alcohol":      values.habitAlcohol = sender.isSelected
    case "smoker":       values.habitSmoker = sender.isSelected
    case "morphine":     values.habitMorphine = sender.isSelected
    case "cannabinoid":  values.habitCannabinoid = sender.isSelected
    case "substanceUse": values.habitSubstanceUse = sender.isSelected
    case "shisha":       values.habitShisha = sender.isSelected
    case "vape":         values.habitVape = sender.isSelected
    case "other":        values.habitOther = sender.isSelected
    default: break
    }
    // Any tick implies "Has Special Habits"
    if sender.isSelected && values.hasSpecialHabits != true {
      didTapHabitsHas()
    }
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
    recomputeCTAS()
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

  // MARK: - CTAS (auto-calculated)
  /// Read-only card. Value is driven by `recomputeCTAS()` off the current
  /// vitals + pain scale. Matches the Android auto-calc behaviour.
  private var ctasBadge: UILabel!

  private func makeCTASCard() -> UIView {
    let titleLabel = UILabel()
    titleLabel.text = "CTAS Evidence-based Score"
    titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    titleLabel.textColor = labelColor

    let autoHint = UILabel()
    autoHint.text = "Auto-calculated"
    autoHint.font = UIFont.systemFont(ofSize: 10, weight: .regular)
    autoHint.textColor = subColor

    let titleStack = UIStackView(arrangedSubviews: [titleLabel, autoHint])
    titleStack.axis = .vertical
    titleStack.spacing = 1

    ctasValueLabel = UILabel()
    ctasValueLabel.text = "Not yet evaluated"
    ctasValueLabel.textColor = subColor
    ctasValueLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    ctasValueLabel.textAlignment = .right
    ctasValueLabel.numberOfLines = 0

    ctasBadge = UILabel()
    ctasBadge.text = "—"
    ctasBadge.textAlignment = .center
    ctasBadge.textColor = .white
    ctasBadge.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    ctasBadge.backgroundColor = UIColor.gray
    ctasBadge.layer.cornerRadius = 14
    ctasBadge.layer.masksToBounds = true
    ctasBadge.translatesAutoresizingMaskIntoConstraints = false
    ctasBadge.widthAnchor.constraint(equalToConstant: 28).isActive = true
    ctasBadge.heightAnchor.constraint(equalToConstant: 28).isActive = true

    let row = UIStackView(arrangedSubviews: [titleStack, ctasValueLabel, ctasBadge])
    row.axis = .horizontal
    row.alignment = .center
    row.spacing = 10
    return wrapInCard(row, padding: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
  }

  /// CTAS auto-calculation. Uses worst-case rules across the entered vitals
  /// and pain scale. Returns nil until at least one vital is entered so the
  /// user isn't shown a misleading "CTAS 5" on an empty form.
  private func computeCTASLevel() -> Int? {
    // Read current field values (not yet committed to `values` for vitals).
    func num(_ key: String) -> Double? {
      guard let t = vitalFields[key]?.text?.trimmingCharacters(in: .whitespaces),
            !t.isEmpty, let v = Double(t) else { return nil }
      return v
    }

    let pulse   = num("pulse")
    let rr      = num("respiratoryRate")
    let o2      = num("o2Sat")
    let temp    = num("temperature")
    let sys     = num("bpSystolic")
    let dia     = num("bpDiastolic")
    let sugar   = num("bloodSugar")
    let pain    = values.painScale   // 0...10

    // If no input yet, no score.
    if pulse == nil && rr == nil && o2 == nil && temp == nil &&
       sys == nil && dia == nil && sugar == nil && pain == 0 {
      return nil
    }

    var level = 5  // start at "Non-Urgent" and escalate

    func escalate(to newLevel: Int) { if newLevel < level { level = newLevel } }

    // Level 1 — Resuscitation
    if let v = o2,    v < 90                      { escalate(to: 1) }
    if let v = pulse, v < 40 || v > 150           { escalate(to: 1) }
    if let v = rr,    v < 10 || v > 30            { escalate(to: 1) }
    if let v = sys,   v < 80                      { escalate(to: 1) }

    // Level 2 — Emergent
    if let v = o2,    v < 92                      { escalate(to: 2) }
    if let v = pulse, v < 50 || v > 130           { escalate(to: 2) }
    if let v = rr,    v < 12 || v > 24            { escalate(to: 2) }
    if let v = sys,   v < 90 || v > 200           { escalate(to: 2) }
    if let v = dia,   v > 120                     { escalate(to: 2) }
    if let v = temp,  v >= 40.0                   { escalate(to: 2) }
    if let v = sugar, v < 60 || v > 400           { escalate(to: 2) }
    if pain >= 8                                  { escalate(to: 2) }

    // Level 3 — Urgent
    if let v = o2,    v < 95                      { escalate(to: 3) }
    if let v = pulse, v < 60 || v > 110           { escalate(to: 3) }
    if let v = rr,    v < 14 || v > 20            { escalate(to: 3) }
    if let v = sys,   v < 100 || v > 160          { escalate(to: 3) }
    if let v = temp,  v >= 39.0                   { escalate(to: 3) }
    if let v = sugar, v < 70 || v > 250           { escalate(to: 3) }
    if pain >= 4 && pain <= 7                     { escalate(to: 3) }

    // Level 4 — Less Urgent
    if let v = temp,  v >= 38.0                   { escalate(to: 4) }
    if pain >= 1 && pain <= 3                     { escalate(to: 4) }

    return level
  }

  private func ctasTitle(forLevel level: Int) -> String {
    switch level {
    case 1: return "CTAS 1 — Resuscitation"
    case 2: return "CTAS 2 — Emergent"
    case 3: return "CTAS 3 — Urgent"
    case 4: return "CTAS 4 — Less Urgent"
    default: return "CTAS 5 — Non-Urgent"
    }
  }

  private func ctasColor(forLevel level: Int) -> UIColor {
    switch level {
    case 1: return UIColor(red: 0.85, green: 0.20, blue: 0.20, alpha: 1) // red
    case 2: return UIColor(red: 0.95, green: 0.45, blue: 0.20, alpha: 1) // orange
    case 3: return UIColor(red: 0.95, green: 0.75, blue: 0.20, alpha: 1) // yellow
    case 4: return UIColor(red: 0.30, green: 0.60, blue: 0.90, alpha: 1) // blue
    default: return UIColor(red: 0.30, green: 0.70, blue: 0.45, alpha: 1) // green
    }
  }

  @objc private func recomputeCTAS() {
    guard ctasValueLabel != nil, ctasBadge != nil else { return }
    // Server CTAS wins over local calc once it has been loaded.
    if serverCTAS != nil { applyServerCTAS(); return }
    if let level = computeCTASLevel() {
      let title = ctasTitle(forLevel: level)
      ctasValueLabel.text = title
      ctasValueLabel.textColor = labelColor
      ctasBadge.text = "\(level)"
      ctasBadge.backgroundColor = ctasColor(forLevel: level)
      values.ctasScore = title
    } else {
      ctasValueLabel.text = "Not yet evaluated"
      ctasValueLabel.textColor = subColor
      ctasBadge.text = "—"
      ctasBadge.backgroundColor = UIColor.gray
      values.ctasScore = nil
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
    tf.addTarget(self, action: #selector(vitalFieldChanged(_:)), for: .editingChanged)
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

  /// Live CTAS recalculation as the user types into any vital field.
  /// Only the fields CTAS cares about (pulse, rr, o2, sys/dia, temp, sugar)
  /// actually shift the score, but calling `recomputeCTAS()` unconditionally
  /// is cheap and keeps the code simple.
  @objc func vitalFieldChanged(_ tf: UITextField) {
    recomputeCTAS()
  }
}

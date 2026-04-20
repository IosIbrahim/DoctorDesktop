//
//  VitalSignCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 3/14/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class VitalSignCell: UITableViewCell {
  var presenter: VitalSignCellPresenter!

  @IBOutlet weak var imgProgress: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var currentResult: UILabel!
  @IBOutlet weak var firstPreviousResult: UILabel!
  @IBOutlet weak var secondPreviousResult: UILabel!

  // Left accent strip — added programmatically so no XIB change needed
  private let accentStrip = UIView()

  private static let teal   = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)
  private static let evenBg = UIColor.white
  private static let oddBg  = UIColor(red: 0.93, green: 0.98, blue: 0.97, alpha: 1)

  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
    setupAccentStrip()
    setupFonts()
    setupIcon()
  }

  // MARK: - One-time setup

  private func setupAccentStrip() {
    accentStrip.translatesAutoresizingMaskIntoConstraints = false
    accentStrip.layer.cornerRadius = 2
    contentView.addSubview(accentStrip)
    NSLayoutConstraint.activate([
      accentStrip.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      accentStrip.topAnchor.constraint(equalTo: contentView.topAnchor),
      accentStrip.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      accentStrip.widthAnchor.constraint(equalToConstant: 4)
    ])
  }

  private func setupFonts() {
    title.font                    = UIFont.systemFont(ofSize: 14, weight: .semibold)
    currentResult.numberOfLines   = 0
    firstPreviousResult.numberOfLines  = 0
    secondPreviousResult.numberOfLines = 0
  }

  private func setupIcon() {
    if #available(iOS 13, *) {
      imgProgress.image        = UIImage(systemName: "chart.bar.fill")
      imgProgress.tintColor    = VitalSignCell.teal
      imgProgress.contentMode  = .scaleAspectFit
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    title.text                     = ""
    currentResult.attributedText   = nil
    firstPreviousResult.attributedText  = nil
    secondPreviousResult.attributedText = nil
    currentResult.text             = ""
    firstPreviousResult.text       = ""
    secondPreviousResult.text      = ""
  }
}

// MARK: - Configure
extension VitalSignCell {
  func configure(with presenter: VitalSignCellPresenter, rowIndex: Int = 0) {
    self.presenter = presenter

    // Title
    title.text      = presenter.vitalSignTitle
    title.textColor = VitalSignCell.teal

    // Result labels — bold value, small gray date
    currentResult.attributedText        = styled(presenter.currentResult)
    firstPreviousResult.attributedText  = styled(presenter.firstPreviousResult)
    secondPreviousResult.attributedText = styled(presenter.secondPreviousResult)

    // Zebra background
    let hasData = !presenter.currentResult.isEmpty
    backgroundColor         = rowIndex % 2 == 0 ? VitalSignCell.evenBg : VitalSignCell.oddBg
    contentView.backgroundColor = backgroundColor

    // Accent strip: teal when has data, light gray when empty
    accentStrip.backgroundColor = hasData
      ? VitalSignCell.teal
      : UIColor(white: 0.82, alpha: 1)

    // Chart icon
    imgProgress.isHidden = !hasData
  }

  /// Returns an NSAttributedString: value line in bold dark + date lines in small gray.
  private func styled(_ text: String) -> NSAttributedString {
    guard !text.isEmpty else { return NSAttributedString(string: "") }
    let lines  = text.components(separatedBy: "\n")
    let result = NSMutableAttributedString()

    // First line = value (e.g. "37.2" or "102 / 58")
    if let value = lines.first {
      result.append(NSAttributedString(string: value, attributes: [
        .font           : UIFont.systemFont(ofSize: 15, weight: .bold),
        .foregroundColor: UIColor(white: 0.15, alpha: 1)
      ]))
    }

    // Remaining lines = date
    if lines.count > 1 {
      let dateStr = lines.dropFirst().joined(separator: "\n")
      result.append(NSAttributedString(string: "\n" + dateStr, attributes: [
        .font           : UIFont.systemFont(ofSize: 11, weight: .regular),
        .foregroundColor: UIColor.gray
      ]))
    }

    return result
  }
}

// MARK: - Helper Methods
extension VitalSignCell {
  public static var cellId: String { return "VitalSignCell" }

  public static var bundle: Bundle { return Bundle(for: VitalSignCell.self) }

  public static var nib: UINib {
    return UINib(nibName: VitalSignCell.cellId, bundle: VitalSignCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(VitalSignCell.nib, forCellReuseIdentifier: VitalSignCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> VitalSignCell {
    return bundle.loadNibNamed(VitalSignCell.cellId, owner: owner, options: nil)?.first as! VitalSignCell
  }

  public static func dequeue(from tableView: UITableView,
                             for indexPath: IndexPath,
                             with presenter: VitalSignCellPresenter) -> VitalSignCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: VitalSignCell.cellId,
                                             for: indexPath) as! VitalSignCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> VitalSignCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: VitalSignCell.cellId) as! VitalSignCell
    cell.title.text               = "Name"
    cell.title.font               = UIFont.systemFont(ofSize: 14, weight: .bold)
    cell.title.textColor          = .white
    cell.currentResult.text       = "Result"
    cell.currentResult.font       = UIFont.systemFont(ofSize: 13, weight: .semibold)
    cell.currentResult.textColor  = .white
    cell.firstPreviousResult.text  = "Previous"
    cell.firstPreviousResult.font  = UIFont.systemFont(ofSize: 13, weight: .semibold)
    cell.firstPreviousResult.textColor = .white
    cell.secondPreviousResult.text  = "Previous"
    cell.secondPreviousResult.font  = UIFont.systemFont(ofSize: 13, weight: .semibold)
    cell.secondPreviousResult.textColor = .white
    cell.imgProgress.isHidden     = true
    cell.accentStrip.isHidden     = true
    cell.backgroundColor          = UIColor(red: 0.28, green: 0.58, blue: 0.62, alpha: 1)
    cell.contentView.backgroundColor = cell.backgroundColor
    return cell
  }
}

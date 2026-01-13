//
//  ScoringCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/3/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class ScoringCell: UITableViewCell {
  var presenter: ScoringCellPresenter!

  @IBOutlet weak var scoreName: UILabel!
  @IBOutlet weak var conclusion: UILabel!
  @IBOutlet weak var value: UIButton!
  @IBOutlet weak var valueContainer: UIView!

  override func prepareForReuse() {
    self.scoreName.text = ""
    self.conclusion.text = ""
    self.value.setTitle("", for: .normal)
  }
}

//MARK: - Configure
extension ScoringCell {
  func configure(with presenter: ScoringCellPresenter) {
    self.presenter = presenter
    self.scoreName.text = presenter.scoreName
    self.conclusion.text = presenter.conclusion
    if let value = presenter.value {
      self.value.setTitle(value, for: .normal)
      self.value.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
      self.valueContainer.backgroundColor = #colorLiteral(red: 0.2745098039, green: 0.7411764706, blue: 0.7490196078, alpha: 1)
      self.valueContainer.layer.cornerRadius = self.valueContainer.bounds.height/2
    } else {
      self.value.setTitle("", for: .normal)
    }
  }
}

//MARK: - Helper Methods
extension ScoringCell {
  public static var cellId: String {
    return "ScoringCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: ScoringCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: ScoringCell.cellId, bundle: ScoringCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(ScoringCell.nib, forCellReuseIdentifier: ScoringCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> ScoringCell {
    return bundle.loadNibNamed(ScoringCell.cellId, owner: owner, options: nil)?.first as! ScoringCell
  }

  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: ScoringCellPresenter) -> ScoringCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ScoringCell.cellId, for: indexPath) as! ScoringCell
    cell.configure(with: presenter)
    return cell
  }

  public static func dequeueHeader(from tableView: UITableView) -> ScoringCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ScoringCell.cellId) as! ScoringCell
    cell.scoreName.text = "Score Name"
    cell.conclusion.text = "Conclusion"
    cell.value.setTitle("Value", for: .normal)
    cell.scoreName.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.conclusion.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    cell.value.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
    cell.backgroundColor = #colorLiteral(red: 0.3556457162, green: 0.6066671014, blue: 0.6494460106, alpha: 1)
    return cell
  }
}

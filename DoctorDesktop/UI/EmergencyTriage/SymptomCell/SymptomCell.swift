//
//  SymptomCell.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class SymptomCell: UITableViewCell {
  @IBOutlet weak var name: UILabel!
  private var presenter: SymptomCellPresenter!
  override func prepareForReuse() {
    super.prepareForReuse()
  }
}

//MARK: - Configure
extension SymptomCell {
  func configure(with presenter: SymptomCellPresenter) {
    self.presenter = presenter
    self.name.text = self.presenter.symptom.arabicName
  }
}

//MARK: - Helper Methods
extension SymptomCell {
  public static var cellId: String {
    return "SymptomCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: SymptomCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: SymptomCell.cellId, bundle: SymptomCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(SymptomCell.nib, forCellReuseIdentifier: SymptomCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> SymptomCell {
    return bundle.loadNibNamed(SymptomCell.cellId, owner: owner, options: nil)?.first as! SymptomCell
  }
  
  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: SymptomCellPresenter) -> SymptomCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SymptomCell.cellId, for: indexPath) as! SymptomCell
    cell.configure(with: presenter)
    return cell
  }
}

extension SymptomCell {
  var id: String { return self.presenter.symptom.id }
  var ser: String? { return self.presenter.symptom.ser }
}



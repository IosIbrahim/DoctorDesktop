//
//  SymptomCategoryCell.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class SymptomCategoryCell: UITableViewCell {
  private var presenter: SymptomCategoryCellPresenter!
  
  @IBOutlet weak var name: UILabel!
}

//MARK: - Configure
extension SymptomCategoryCell {
  func configure(with presenter: SymptomCategoryCellPresenter) {
    self.presenter = presenter
    self.name.text = self.presenter.symptomCategory.arabicName
  }
}

//MARK: - Helper Methods
extension SymptomCategoryCell {
  public static var cellId: String {
    return "SymptomCategoryCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: SymptomCategoryCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: SymptomCategoryCell.cellId, bundle: SymptomCategoryCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(SymptomCategoryCell.nib, forCellReuseIdentifier: SymptomCategoryCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> SymptomCategoryCell {
    return bundle.loadNibNamed(SymptomCategoryCell.cellId, owner: owner, options: nil)?.first as! SymptomCategoryCell
  }
  
  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: SymptomCategoryCellPresenter) -> SymptomCategoryCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SymptomCategoryCell.cellId, for: indexPath) as! SymptomCategoryCell
    cell.configure(with: presenter)
    return cell
  }
}

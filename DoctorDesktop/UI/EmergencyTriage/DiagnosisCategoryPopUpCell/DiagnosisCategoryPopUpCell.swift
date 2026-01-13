//
//  DiagnosisCategoryPopUpCell.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 2/20/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

class DiagnosisCategoryPopUpCell: UITableViewCell {
  @IBOutlet weak var title: UILabel!
  
  private var presenter: DiagnosisCategoryPopUpCellPresenter!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    title.text = ""
  }
}

//MARK: - Configure
extension DiagnosisCategoryPopUpCell {
  func configure(with presenter: DiagnosisCategoryPopUpCellPresenter) {
    self.presenter = presenter
    self.title.text = self.presenter.diagnosisCategory.arabicName
  }
}

//MARK: - Helper Methods
extension DiagnosisCategoryPopUpCell {
  public static var cellId: String {
    return "DiagnosisCategoryPopUpCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: DiagnosisCategoryPopUpCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: DiagnosisCategoryPopUpCell.cellId, bundle: DiagnosisCategoryPopUpCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(DiagnosisCategoryPopUpCell.nib, forCellReuseIdentifier: DiagnosisCategoryPopUpCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> DiagnosisCategoryPopUpCell {
    return bundle.loadNibNamed(DiagnosisCategoryPopUpCell.cellId, owner: owner, options: nil)?.first as! DiagnosisCategoryPopUpCell
  }
  
  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: DiagnosisCategoryPopUpCellPresenter) -> DiagnosisCategoryPopUpCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DiagnosisCategoryPopUpCell.cellId, for: indexPath) as! DiagnosisCategoryPopUpCell
    cell.configure(with: presenter)
    return cell
  }
}

//
//  NotesCell.swift
//  DoctorDesktop
//
//  Created by Ibrahim on 17/03/2026.
//  Copyright © 2026 khabeer Group. All rights reserved.
//

import UIKit

class NotesCell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var pickerStatus: UIView!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var pickerNotes: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgUser.layer.cornerRadius = 30
        pickerNotes.makeShadow(color: .lightGray, alpha: 0.25, radius: 8)
        pickerStatus.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func replyOnTap(_ sender: Any) {
    }
    
    @IBAction func deleteOnTap(_ sender: Any) {
    }
    
    func drawCell(_ note:NurseRemark) {
        lblUser.text = note.doctorEnglishName
        lblDate.text = note.nurseTransactionDate
        lblNote.text = note.englishDescription
        if note.status == "1" {
            pickerStatus.backgroundColor = .systemGreen
            lblStatus.textColor = .white
            lblStatus.text = "Normal"
        }else {
            pickerStatus.backgroundColor = .systemRed
            lblStatus.textColor = .white
            lblStatus.text = "Urgent"
        }
    }
}


//MARK: - Helper Methods
extension NotesCell {
  public static var cellId: String {
    return "NotesCell"
  }

  public static var bundle: Bundle {
    return Bundle(for: NotesCell.self)
  }

  public static var nib: UINib {
    return UINib(nibName: NotesCell.cellId, bundle: NotesCell.bundle)
  }

  public static func register(with tableView: UITableView) {
    tableView.register(NotesCell.nib, forCellReuseIdentifier: NotesCell.cellId)
  }

  public static func loadFromNib(owner: Any?) -> NotesCell {
    return bundle.loadNibNamed(NotesCell.cellId, owner: owner, options: nil)?.first as! NotesCell
  }

  /// Dequeues a `NotesCell` already configured with `note`.
  /// Used by `ProgressNotesViewController` which registers the cell programmatically.
  public static func dequeue(from tableView: UITableView,
                             for indexPath: IndexPath,
                             with note: NurseRemark) -> NotesCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: NotesCell.cellId, for: indexPath) as! NotesCell
    cell.drawCell(note)
    return cell
  }

//  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: ScoringCellPresenter) -> ScoringCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: ScoringCell.cellId, for: indexPath) as! ScoringCell
//    cell.configure(with: presenter)
//    return cell
//  }
}

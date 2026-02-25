//
//  OutpatientCell.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 12/18/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

protocol OutpatientStatus {
    func changeStatus(_ index:Int)
}
class OutpatientCell: UITableViewCell {
  
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var lblgeValue: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblScoreValue: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblRow: UILabel! // shift
    @IBOutlet weak var pickerRow: UIView!
    @IBOutlet weak var lblPain: UILabel!
    @IBOutlet weak var pickerPain: UIView!
    @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var genderAgeView: UIView!
  @IBOutlet weak var genderAgeImageView: UIImageView!
  @IBOutlet weak var patientNameLabel: UILabel!
  @IBOutlet weak var patientNationalityLabel: UILabel!
  @IBOutlet weak var clinicTitleLabel: UILabel!
  @IBOutlet weak var statusButton: UIButton!
    
    var mobile:String = ""
    var delegade:OutpatientStatus?
    var selectIndex:Int = .zero
    
  override func awakeFromNib() {
    super.awakeFromNib()
    cellView.layer.cornerRadius = 10
    genderAgeView.layer.cornerRadius = genderAgeView.bounds.width/2
    statusButton.layer.cornerRadius = 8
      pickerRow.layer.cornerRadius = 4
      pickerPain.layer.cornerRadius = 8
      btnCall.layer.cornerRadius = 8

  }
  
  override func prepareForReuse() {
    patientNameLabel.text = ""
    patientNationalityLabel.text = ""
    clinicTitleLabel.text = ""
    genderAgeImageView.image = nil
  }
    
    @IBAction func checkoutOnTap(_ sender: Any) {
        // checkout
        delegade?.changeStatus(selectIndex)
    }
    
    @IBAction func callOnTap(_ sender: Any) {
        // call
        phone(phoneNum: mobile)
    }
    
    func phone(phoneNum: String) {
        if let url = URL(string: "tel://\(phoneNum)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
}

//MARK: - Configure
extension OutpatientCell {
  func configure(with presenter: OutpatientCellPresenter) {
      self.genderAgeImageView.image = presenter.genderAgeImage
      self.patientNameLabel.text = presenter.patientName
      lblRow.text = presenter.queue
      lblRow.text = "\(selectIndex + 1)"
      pickerPain.isHidden = true
      self.patientNationalityLabel.text = "DR/ \(presenter.doctorName)"
      lblTime.text = presenter.time
      self.clinicTitleLabel.text = presenter.clinicTitle
      statusButton.setTitle(presenter.status, for: .normal)
      statusButton.backgroundColor = UIColor.fromHex(hex: presenter.statusColor)
      lblScore.isHidden = true
      lblScoreValue.isHidden = true
      mobile = presenter.patMobile
      lblgeValue.text = presenter.age
      setBtnServStatus(presenter.servStatus, time: presenter.time)
      
  }
    func setBtnServStatus(_ status:String,time:String) {
        let endDate = time.ConvertToDate
        let startDate = Date()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.second], from: startDate, to: endDate)

        if let seconds = dateComponents.second {
            print("Difference in seconds: \(seconds)")
            let min = seconds / 60
            let second =  seconds % 60
            lblTime.text = "\(min):\(second)"
            if seconds < 5 {
                lblTime.isHidden = true
            }
        }
        statusButton.isHidden = false
        if status == "B" {
            // المريض وصل ولسه منتظر الدخول اخضر
            statusButton.setTitle("Arrival", for: .normal)
            statusButton.backgroundColor = UIColor(red: 37, green: 182, blue: 110, alpha: 1.0)
            
        }else if status == "A"{
            // كده المريض دحل ولسه مخرجش ازرق
            statusButton.setTitle("Check In", for: .normal)
            statusButton.backgroundColor = UIColor(red: 28, green: 170, blue: 222, alpha: 1.0)

        }else if status == "S"{
            // كده المريض خرج احمر
            statusButton.setTitle("Check Out", for: .normal)
            statusButton.backgroundColor = UIColor(red: 248, green: 38, blue: 7, alpha: 1.0)
        }else if status == "D" {
            statusButton.setTitle("OverView", for: .normal)
            statusButton.backgroundColor = UIColor(red: 28, green: 170, blue: 222, alpha: 1.0)
        }else {
            statusButton.isHidden = true
        }
    }
}

//MARK: - Helper Methods
extension OutpatientCell {
  public static var cellId: String {
    return "OutpatientCell"
  }
  
  public static var bundle: Bundle {
    return Bundle(for: OutpatientCell.self)
  }
  
  public static var nib: UINib {
    return UINib(nibName: OutpatientCell.cellId, bundle: OutpatientCell.bundle)
  }
  
  public static func register(with tableView: UITableView) {
    tableView.register(OutpatientCell.nib, forCellReuseIdentifier: OutpatientCell.cellId)
  }
  
  public static func loadFromNib(owner: Any?) -> OutpatientCell {
    return bundle.loadNibNamed(OutpatientCell.cellId, owner: owner, options: nil)?.first as! OutpatientCell
  }
  
  public static func dequeue(from tableView: UITableView, for indexPath: IndexPath, with presenter: OutpatientCellPresenter) -> OutpatientCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: OutpatientCell.cellId, for: indexPath) as! OutpatientCell
    cell.configure(with: presenter)
    return cell
  }
}




extension UIColor {
    
    class func fromHex(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return #colorLiteral(red: 0, green: 0.702642262, blue: 0.6274331808, alpha: 1)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return  .black
    }
//
//    open class var titleColor: UIColor {
//        return #colorLiteral(red: 0, green: 0.702642262, blue: 0.6274331808, alpha: 1)
//    }
    
    class func fromHex(hex:String, alpha: CGFloat) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}


extension String {
    var ConvertToDate: Date
    {
        let dateString = self
        let spitDate = dateString.components(separatedBy: .whitespaces)
        print("Splits:\(spitDate)")
        print("Date:\(dateString)")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        
        dateFormatter.dateFormat = "dd/mm/yyyy hh24:mi:ss"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm a"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        
        dateFormatter.dateFormat = "MMM d yyyy h:mm"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        
        dateFormatter.dateFormat = "HH:mm:ss"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        dateFormatter.dateFormat = "HH:mm a"
        if dateFormatter.date(from: dateString) != nil {
            return dateFormatter.date(from: dateString)!
        }
        
        if dateString == ""
        {
            return Date()
        }
        if let conDate = dateFormatter.date(from:dateString) {
            return conDate
        }else {
            let spitDate = dateString.components(separatedBy: .whitespaces)
            print("Splits:\(spitDate)")
        }
        return dateFormatter.date(from:dateString) ?? Date()
    }
}

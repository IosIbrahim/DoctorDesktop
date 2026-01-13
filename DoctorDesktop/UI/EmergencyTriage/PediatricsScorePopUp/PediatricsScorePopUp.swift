//
//  PediatricsScorePopUp.swift
//  DoctorDesktop
//
//  Created by Mostafa Abdel Fattah on 3/7/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit

private enum PediatricScoreTableConstants: Int {
  case rows = 5
  case columns = 4
  case items = 20
}

protocol PediatricsScorePopUpDelegate {
  func didClickSave(_ pediatricsScorePopUp: PediatricsScorePopUp, totalScore: Int, selectedChoices: [PediatricsScoreChoice])
}

class PediatricsScorePopUp: UIViewController {
  var presenter: PediatricsScorePopUpPresenter!
  var delegate: PediatricsScorePopUpDelegate?
  var selectedChoices: [Int: IndexPath] = [:]
  
  @IBOutlet weak var cellView: UICollectionView!
  @IBOutlet weak var totalScore: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    PediatricsScorePopUpCell.register(with: cellView)
    cellView.allowsMultipleSelection = true
    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    self.cellView.collectionViewLayout.invalidateLayout()
  }
  
  @IBAction func didClickSaveButton(_ sender: Any) {
    self.dismiss(animated: true){
      self.delegate?.didClickSave(self, totalScore: self.presenter.totalScore, selectedChoices: self.presenter.selectedScoreChoices)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
  }
  
  init(with presenter: PediatricsScorePopUpPresenter) {
    self.presenter = presenter
    super.init(nibName: "PediatricsScorePopUpView", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension PediatricsScorePopUp: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return PediatricScoreTableConstants.items.rawValue
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let element = self.presenter.pediatricsScoreElements[indexPath.row / PediatricScoreTableConstants.columns.rawValue]
    let index: Int = indexPath.row % PediatricScoreTableConstants.columns.rawValue
    if indexPath.row % PediatricScoreTableConstants.columns.rawValue == 0 {
      let pediatricsScoreCellPresenter = PediatricsScorePopUpCellPresenterImpl(with: element)
      return PediatricsScorePopUpCell.dequeue(from: cellView, for: indexPath, with: pediatricsScoreCellPresenter)
    } else {
      if let element = element as? PediatricsScoreCategory {
        let pediatricsScoreCellPresenter = PediatricsScorePopUpCellPresenterImpl(with: (element.secondLevelScore?.secondLevelElements[index - 1])!)
        let cell = PediatricsScorePopUpCell.dequeue(from: cellView, for: indexPath, with: pediatricsScoreCellPresenter)
        if self.presenter.selectedScoreChoices.contains(where: { choice in return choice.id == cell.id }) {
          self.collectionView(collectionView, didSelectItemAt: indexPath)
          collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
          cell.cellView.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        }
        return cell
      } else { return UICollectionViewCell() }
    }
  }
}

extension PediatricsScorePopUp: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let height = collectionView.bounds.height / CGFloat(PediatricScoreTableConstants.rows.rawValue)
    let width = collectionView.bounds.width / CGFloat(PediatricScoreTableConstants.columns.rawValue)
    return CGSize(
      width: width,
      height: height
    )
  }
}

extension PediatricsScorePopUp: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectItem(from: collectionView, at: indexPath)
    if let cell = collectionView.cellForItem(at: indexPath) as? PediatricsScorePopUpCell, let choice = cell.choice {
      self.presenter.selectedScoreChoices.append(choice)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return indexPath.row % PediatricScoreTableConstants.columns.rawValue != 0
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    deselectItem(from: collectionView, at: indexPath)
    if let cell = collectionView.cellForItem(at: indexPath) as? PediatricsScorePopUpCell, let choice = cell.choice {
     self.presenter.selectedScoreChoices.remove(at: self.presenter.selectedScoreChoices.index {other in return other.id == choice.id}!)
    }
  }
  
  func selectItem(from collectionView: UICollectionView, at indexPath: IndexPath) {
    // get the row number of the selected cell
    let key: Int = indexPath.row / PediatricScoreTableConstants.columns.rawValue
    // check if there was a cell selected in the same row .. if true deselect it first
    if self.selectedChoices.keys.contains(key) { self.collectionView(collectionView, didDeselectItemAt: self.selectedChoices[key]!) }
    // add the selected cell to the selected cell dicitionaries
    self.selectedChoices[key] = indexPath
    // change cell background color
    if let cell = collectionView.cellForItem(at: indexPath) as? PediatricsScorePopUpCell {
      collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
      cell.cellView.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    }
    // update the score
    self.presenter.totalScore += ((indexPath.row % PediatricScoreTableConstants.columns.rawValue) - 1)
    self.totalScore.text = "\(self.presenter.totalScore)"
  }
  
  func deselectItem(from collectionView: UICollectionView, at indexPath: IndexPath) {
    // get the row number of the deselected cell
    let key: Int = indexPath.row / PediatricScoreTableConstants.columns.rawValue
    // remove the index path of the deselected cell
    self.selectedChoices.removeValue(forKey: key)
    // reset cell background color
    if let cell = collectionView.cellForItem(at: indexPath) as? PediatricsScorePopUpCell {
      collectionView.deselectItem(at: indexPath, animated: false)
      cell.cellView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    // update the score
    self.presenter.totalScore -= ((indexPath.row % PediatricScoreTableConstants.columns.rawValue) - 1)
    self.totalScore.text = "\(self.presenter.totalScore)"
  }
}

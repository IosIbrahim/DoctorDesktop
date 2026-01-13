//
//  ComponentVC.swift
//  Doctor DeskTop
//
//  Created by Eng Nour Hegazy on 12/6/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit

typealias ColorAndImageTuple = (startColor: UIColor, endColor: UIColor, image: UIImage)

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributes = super.layoutAttributesForElements(in: rect)
    var leftMargin = sectionInset.left
    var maxY: CGFloat = -1.0
    attributes?.forEach { layoutAttribute in
      if layoutAttribute.frame.origin.y >= maxY {
        leftMargin = sectionInset.left
      }
      layoutAttribute.frame.origin.x = leftMargin
      leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
      maxY = max(layoutAttribute.frame.maxY , maxY)
    }
    return attributes
  }
}

class ComponentCollectionViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!

  private var presenter: ComponentCollectionPresenter!
  private var componentCellMaker: DependencyRegistry.ComponentCellMaker!
  private weak var navigationCoordinator: NavigationCoordinator?

  var isFinishedLoadingCounts = false
  
  func configure(with presenter: ComponentCollectionPresenter,
                 componentCellMaker: @escaping DependencyRegistry.ComponentCellMaker,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.componentCellMaker = componentCellMaker
    self.navigationCoordinator = navigationCoordinator
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.collectionView.reloadData()
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    if isMovingFromParentViewController {
      navigationCoordinator?.movingBack()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.setHidesBackButton(true, animated:false)
    
    ComponentCell.register(with: collectionView)
    
    presenter.getPatientsCount() {
      self.isFinishedLoadingCounts = true
      self.collectionView.reloadData()
    }
  }
  
  func getComponentBackgroundColorAndImage(componentType: ComponentType) -> ColorAndImageTuple {
    var startColor = #colorLiteral(red: 0.9058823529, green: 0.5882352941, blue: 0.1254901961, alpha: 1)
    var endColor = #colorLiteral(red: 0.8039215686, green: 0.4431372549, blue: 0.1215686275, alpha: 1)
    var image = #imageLiteral(resourceName: "icu")

    switch componentType {
    case .inpatient:
      image = #imageLiteral(resourceName: "inpatients")
      startColor = #colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.7333333333, alpha: 1)
      endColor = #colorLiteral(red: 0.2941176471, green: 0.4901960784, blue: 0.737254902, alpha: 1)
    case .ICU:
      image = #imageLiteral(resourceName: "icu")
      startColor = #colorLiteral(red: 0.9137254902, green: 0.4078431373, blue: 0.6196078431, alpha: 1)
      endColor = #colorLiteral(red: 0.7647058824, green: 0.1764705882, blue: 0.5333333333, alpha: 1)
    case .outpatient:
      image = #imageLiteral(resourceName: "outpatients")
      startColor = #colorLiteral(red: 0.6274509804, green: 0.4196078431, blue: 0.631372549, alpha: 1)
      endColor = #colorLiteral(red: 0.537254902, green: 0.3411764706, blue: 0.6274509804, alpha: 1)
    case .emergency:
      image = #imageLiteral(resourceName: "emergency")
      startColor = #colorLiteral(red: 0.9254901961, green: 0.2901960784, blue: 0.2666666667, alpha: 1)
      endColor = #colorLiteral(red: 0.8588235294, green: 0.1529411765, blue: 0.1098039216, alpha: 1)
    case .operations:
      startColor = #colorLiteral(red: 0.9058823529, green: 0.5882352941, blue: 0.1254901961, alpha: 1)
      endColor = #colorLiteral(red: 0.8039215686, green: 0.4431372549, blue: 0.1215686275, alpha: 1)
    case .clinicalAlert:
      image = #imageLiteral(resourceName: "clinical alerts")
      startColor = #colorLiteral(red: 0.3921568627, green: 0.4980392157, blue: 0.7882352941, alpha: 1)
      endColor = #colorLiteral(red: 0.1568627451, green: 0.3137254902, blue: 0.5176470588, alpha: 1)
    case .consultation:
      startColor = #colorLiteral(red: 0.3490196078, green: 0.7568627451, blue: 0.2901960784, alpha: 1)
      endColor = #colorLiteral(red: 0.262745098, green: 0.4588235294, blue: 0.2156862745, alpha: 1)
    }
    return ColorAndImageTuple(startColor, endColor, image)
  }
}

extension ComponentCollectionViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return isFinishedLoadingCounts ? presenter.components.count : 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let componentType = ComponentType(rawValue: presenter.components[indexPath.row].processInfoCode)!
    let colorAndImageTuble = getComponentBackgroundColorAndImage(componentType: componentType)
    return componentCellMaker(collectionView, indexPath,
                              presenter.components[indexPath.row],
                              colorAndImageTuble)
  }
}

extension ComponentCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let orientation = UIDevice.current.orientation
//    let numberOfHorizontalCells: CGFloat = orientation.isPortrait || orientation.isFlat  ? 3 : 5
//    let numberOfVerticalCells: CGFloat = orientation.isPortrait || orientation.isFlat ? 3 : 2
    return CGSize(width: (collectionView.bounds.width / 2)-10, height: 100)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
  }
}


extension ComponentCollectionViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let componentType = presenter.components[indexPath.row].type else { return }
    
    print(componentType)
    let args = ["componentType": componentType, "user": presenter.user] as [String : Any]
    navigationCoordinator?.next(arguments: args)
  }
}

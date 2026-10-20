//
//  ComponentVC.swift
//  Doctor DeskTop
//
//  Created by Eng Nour Hegazy on 12/6/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

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

class ComponentCollectionViewController: UIViewController, NVActivityIndicatorViewable {
  
  @IBOutlet weak var collectionView: UICollectionView!

  private var presenter: ComponentCollectionPresenter!
  private var componentCellMaker: DependencyRegistry.ComponentCellMaker!
  private weak var navigationCoordinator: NavigationCoordinator?

    var isFinishedLoadingCounts = false
    lazy var toastBar: ToastBar = .init(settings: .agent, in: parent?.view)

  func configure(with presenter: ComponentCollectionPresenter,
                 componentCellMaker: @escaping DependencyRegistry.ComponentCellMaker,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.componentCellMaker = componentCellMaker
    self.navigationCoordinator = navigationCoordinator
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Only invalidate the layout so cells resize correctly on rotation —
    // do NOT call reloadData() here; it was firing on every layout pass and
    // causing the collection view to rebuild all cells continuously.
    collectionView.collectionViewLayout.invalidateLayout()
  }
  // viewWillDisappear consolidated below (after viewWillAppear) — it now
  // also restores the nav bar that was hidden in viewDidLoad.

  /// Pull-to-refresh control wired to the collection view in viewDidLoad.
  private let refreshControl = UIRefreshControl()

  /// Re-entrancy guard so a tap-back + pull-down can't fire two parallel
  /// `getPatientsCount` requests against the server.
  private var isRefreshing = false

  // Header card — owned by this VC so we can update the date / count
  // labels live without rebuilding the whole hierarchy.
  private let greetingHeader = HomeGreetingHeaderView()
  /// Decorative background — soft gradient + ECG heartbeat line +
  /// dot patterns. Replaces the previous "footer banner" approach with
  /// art that lives BEHIND the cards instead of stealing screen space.
  private let backgroundArt = HomeBackgroundView()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.setHidesBackButton(true, animated:false)

    // ── Medical-themed background ───────────────────────────────────────
    // Hide the doctor-photo background that ships from the storyboard
    // (asset "loginSreen") and install `HomeBackgroundView` BEHIND every
    // other view. It renders a soft gradient, an ECG heartbeat line,
    // two corner dot patterns, and organic blob shapes — gives the
    // screen unmistakable "healthcare" identity without consuming
    // foreground real estate.
    view.backgroundColor = .clear
    for sub in view.subviews where sub is UIImageView {
        sub.isHidden = true
    }
    backgroundArt.translatesAutoresizingMaskIntoConstraints = false
    view.insertSubview(backgroundArt, at: 0)
    NSLayoutConstraint.activate([
        backgroundArt.topAnchor.constraint(equalTo: view.topAnchor),
        backgroundArt.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        backgroundArt.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        backgroundArt.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    collectionView.backgroundColor = .clear

    // Hide the navigation bar entirely on this screen — the greeting card
    // doubles as the screen header.
    navigationController?.setNavigationBarHidden(true, animated: false)

    // ── Greeting header (Hello, Dr. … + date + count summary) ────────────
    greetingHeader.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(greetingHeader)
    NSLayoutConstraint.activate([
        greetingHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
        greetingHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        greetingHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    ])
    greetingHeader.configure(doctorName: presenter.user.englishName ?? presenter.user.userName ?? "Doctor")

    // Push the collection view's content below the header so the cards
    // start where the header ends. We don't need a bottom inset any
    // more — the heartbeat artwork sits BEHIND the cards.
    view.layoutIfNeeded()
    collectionView.contentInset = UIEdgeInsets(
        top:    greetingHeader.frame.height + 16,
        left:   0,
        bottom: 32,
        right:  0
    )
    collectionView.scrollIndicatorInsets = collectionView.contentInset

    ComponentCell.register(with: collectionView)

    // Pull-to-refresh.
    collectionView.alwaysBounceVertical = true
    refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
    if #available(iOS 10.0, *) {
        collectionView.refreshControl = refreshControl
    } else {
        collectionView.addSubview(refreshControl)
    }

    loadCounts()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Always re-hide the nav bar when popping back from a child screen.
    navigationController?.setNavigationBarHidden(true, animated: animated)
    // Refresh when popping back from a child screen — but skip the very
    // first appearance (already kicked off in viewDidLoad).
    if isFinishedLoadingCounts {
        loadCounts()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // Restore the nav bar for downstream screens (Patients list,
    // Operations list, etc. — they expect it visible).
    navigationController?.setNavigationBarHidden(false, animated: animated)
    if isMovingFromParentViewController {
      navigationCoordinator?.movingBack()
    }
  }

  @objc private func refreshTriggered() {
    loadCounts()
  }

  /// Single entry point for fetching tile counts. Used by viewDidLoad,
  /// viewWillAppear (pop-back), and the pull-to-refresh control.
  ///
  /// While the request is in flight we show a centred spinner using
  /// `NVActivityIndicatorViewable` — the same loader the rest of the
  /// app uses (Lite Overview, Operations list). Pull-to-refresh has
  /// its own UIRefreshControl indicator at the top of the collection
  /// view, so we skip the central spinner when the request was kicked
  /// off by a pull-down (otherwise the user sees two spinners at once).
  private func loadCounts() {
    guard !isRefreshing else { return }
    isRefreshing = true

    let isPullToRefresh = refreshControl.isRefreshing
    if !isPullToRefresh {
        startAnimating(message: "Loading...")
    }

    presenter.getPatientsCount { [weak self] in
        guard let self = self else { return }
        self.isRefreshing = false
        self.refreshControl.endRefreshing()
        self.stopAnimating()
        if !self.presenter.error.isEmpty {
            self.toastBar.show(with: self.presenter.error)
        }
        self.isFinishedLoadingCounts = true
        self.collectionView.reloadData()
    }
  }
  
  func getComponentBackgroundColorAndImage(componentType: ComponentType) -> ColorAndImageTuple {
    var startColor = #colorLiteral(red: 0.9058823529, green: 0.5882352941, blue: 0.1254901961, alpha: 1)
    var endColor = #colorLiteral(red: 0.8039215686, green: 0.4431372549, blue: 0.1215686275, alpha: 1)
    var image = #imageLiteral(resourceName: "icu")

    switch componentType {
    case .nicu:
        startColor = #colorLiteral(red: 0.9058823529, green: 0.5882352941, blue: 0.1254901961, alpha: 1)
        endColor = #colorLiteral(red: 0.8039215686, green: 0.4431372549, blue: 0.1215686275, alpha: 1)
        startColor = #colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.7333333333, alpha: 1)
        endColor = #colorLiteral(red: 0.2941176471, green: 0.4901960784, blue: 0.737254902, alpha: 1)
    case .outpatient:
    //  image = #imageLiteral(resourceName: "outpatients")
        image = UIImage(named: "outpatients") ?? .init()
        startColor = #colorLiteral(red: 0.6274509804, green: 0.4196078431, blue: 0.631372549, alpha: 1)
        endColor = #colorLiteral(red: 0.537254902, green: 0.3411764706, blue: 0.6274509804, alpha: 1)
    case .inpatient:
        image = UIImage(named: "inpatients") ?? .init()
        startColor = #colorLiteral(red: 0.3921568627, green: 0.4980392157, blue: 0.7882352941, alpha: 1)
        endColor = #colorLiteral(red: 0.1568627451, green: 0.3137254902, blue: 0.5176470588, alpha: 1)
    case .ICU:
      image = UIImage(named: "icu") ?? .init()
      startColor = #colorLiteral(red: 0.9137254902, green: 0.4078431373, blue: 0.6196078431, alpha: 1)
      endColor = #colorLiteral(red: 0.7647058824, green: 0.1764705882, blue: 0.5333333333, alpha: 1)
    case .emergency:
   //   image = #imageLiteral(resourceName: "emergency")
      image = UIImage(named: "emergency") ?? .init()
      startColor = #colorLiteral(red: 0.9254901961, green: 0.2901960784, blue: 0.2666666667, alpha: 1)
      endColor = #colorLiteral(red: 0.8588235294, green: 0.1529411765, blue: 0.1098039216, alpha: 1)
    case .operations:
        // Amber-orange gradient — distinct from inpatient blue / emergency
        // red. Falls back to the inpatient bed icon if no operation icon
        // ships in the asset catalog.
        startColor = #colorLiteral(red: 0.9058823529, green: 0.5882352941, blue: 0.1254901961, alpha: 1)
        endColor   = #colorLiteral(red: 0.8039215686, green: 0.4431372549, blue: 0.1215686275, alpha: 1)
        image = UIImage(named: "ic-operation")
            ?? UIImage(named: "inpatients")
            ?? UIImage()
    case .consultation:
      startColor = #colorLiteral(red: 0.3490196078, green: 0.7568627451, blue: 0.2901960784, alpha: 1)
      endColor = #colorLiteral(red: 0.262745098, green: 0.4588235294, blue: 0.2156862745, alpha: 1)
//    case .clinicalAlert:
//     // image = #imageLiteral(resourceName: "clinical alerts")
//      image = UIImage(named: "clinical alerts") ?? .init()
//      startColor = #colorLiteral(red: 0.3921568627, green: 0.4980392157, blue: 0.7882352941, alpha: 1)
//      endColor = #colorLiteral(red: 0.1568627451, green: 0.3137254902, blue: 0.5176470588, alpha: 1)
//    case .notifications:
//        startColor = #colorLiteral(red: 0.9058823529, green: 0.5882352941, blue: 0.1254901961, alpha: 1)
//        endColor = #colorLiteral(red: 0.8039215686, green: 0.4431372549, blue: 0.1215686275, alpha: 1)
//        image = UIImage(named:"ic-bell") ?? .init()
//    case .search:
//        image = UIImage(named: "inpatients") ?? .init()
//        startColor = #colorLiteral(red: 0.6274509804, green: 0.4196078431, blue: 0.631372549, alpha: 1)
//        endColor = #colorLiteral(red: 0.537254902, green: 0.3411764706, blue: 0.6274509804, alpha: 1)
    }
      
    return ColorAndImageTuple(startColor, endColor, image)
  }
}

extension ComponentCollectionViewController: UICollectionViewDataSource {

  /// Components visible in the grid — search and notifications are hidden.
  private var visibleComponents: [Component] {
//      return presenter.components
    return presenter.components.filter {
      let type = ComponentType(rawValue: $0.processInfoCode)
      return type != .ICU && type != .nicu && type != .consultation
    }
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return isFinishedLoadingCounts ? visibleComponents.count : 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let component = visibleComponents[indexPath.row]
    let componentType = ComponentType(rawValue: component.processInfoCode) ?? .inpatient
    let colorAndImageTuble = getComponentBackgroundColorAndImage(componentType: componentType)
    return componentCellMaker(collectionView, indexPath, component, colorAndImageTuble)
  }
}

extension ComponentCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    // Full-width rows. Section insets are 16 each side, so width =
    // bounds.width - 32. Height 116 gives the card noticeable presence
    // (matches the user's reference screenshot — taller cards, generous
    // vertical breathing room).
    let width = collectionView.bounds.width - 32
    return CGSize(width: width, height: 116)
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 14
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
  }
}


extension ComponentCollectionViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      navigationCoordinator?.setNavigationStatus(.atComponentCollection)
      let component = visibleComponents[indexPath.row]
      guard let componentType = component.type else { return }
      let originalIndex = presenter.components.firstIndex(where: { $0.processInfoCode == component.processInfoCode }) ?? indexPath.row
      // The synthetic Operations tile has no matching slot in `permissions`
      // (the server returned permission rows only for the components it
      // shipped in `userComponent`). Fall back to an empty PermissionModel
      // for any out-of-range index so the tap doesn't crash.
      let permission: PermissionModel = (originalIndex < presenter.permissions.count)
          ? presenter.permissions[originalIndex]
          : PermissionModel()
      let args = ["componentType": componentType, "user": presenter.user, "permission": permission] as [String : Any]
      navigationCoordinator?.next(arguments: args)
  }
}

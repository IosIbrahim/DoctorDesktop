//
//  WebViewerViewController.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/1/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import UIKit
import WebKit

class WebViewerViewController: UIViewController {
  @IBOutlet weak var webViewer: WKWebView!

  private weak var navigationCoordinator: NavigationCoordinator?
  private var presenter: WebViewerPresenter!

  override func viewDidLoad() {
    super.viewDidLoad()
    //let urlRequest = URLRequest(url: presenter.url)
    let urlRequest = URLRequest(url: URL(string: "https://google.com.eg")!)
    webViewer.load(urlRequest)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    if isMovingFromParentViewController {
      navigationCoordinator?.movingBack()
    }
  }

  func configure(with presenter: WebViewerPresenter,
                 navigationCoordinator: NavigationCoordinator) {
    self.presenter = presenter
    self.navigationCoordinator = navigationCoordinator
  }
}

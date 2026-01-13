//
//  WebViewerPresenter.swift
//  DoctorDesktop
//
//  Created by Mohammed Sami on 4/1/18.
//  Copyright © 2018 khabeer Group. All rights reserved.
//

import Foundation

protocol WebViewerPresenter {
  var url: URL { get }
}

class WebViewerPresenterImpl: WebViewerPresenter {
  let url: URL
  init(url: URL) {
    self.url = url
  }
}

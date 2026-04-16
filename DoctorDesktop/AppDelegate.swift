//
//  AppDelegate.swift
//  Doctor DeskTop
//
//  Created by Eng Nour Hegazy on 12/2/17.
//  Copyright © 2017 khabeer Group. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  static var dependencyRegistry: DependencyRegistry!
  static var navigationCoordinator: NavigationCoordinator!
  let log = SwiftyBeaver.self

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    initSwiftyBeaver()
    AppDelegate.enableScreenLogging()
    IQKeyboardManager.shared.enable = true
    return true
  }

  func initSwiftyBeaver() {
    // add log destinations. at least one is needed!
    let console = ConsoleDestination()  // log to Xcode Console
    console.levelString.verbose = "💜 VERBOSE"
    console.levelString.debug = "💚 DEBUG"
    console.levelString.info = "💙 INFO"
    console.levelString.warning = "💛 WARNING"
    console.levelString.error = "❤️ ERROR"

    let file = FileDestination()  // log to default swiftybeaver.log file

    // use custom format and set console output to short time, log level & message
    console.format = "$DHH:mm:ss$d $L $M"

    log.addDestination(console)
    log.addDestination(file)
  }

  // MARK: - Screen Logging (method swizzling)

  private static let _swizzleOnce: Void = {
    let original = #selector(UIViewController.viewDidAppear(_:))
    let swizzled = #selector(UIViewController.logged_viewDidAppear(_:))
    guard
      let originalMethod = class_getInstanceMethod(UIViewController.self, original),
      let swizzledMethod  = class_getInstanceMethod(UIViewController.self, swizzled)
    else { return }
    method_exchangeImplementations(originalMethod, swizzledMethod)
  }()

  static func enableScreenLogging() { _ = _swizzleOnce }
}

// MARK: - UIViewController screen name logging
private extension UIViewController {
  @objc func logged_viewDidAppear(_ animated: Bool) {
    logged_viewDidAppear(animated)
    SwiftyBeaver.debug("📱 Screen: \(String(describing: type(of: self)))")
  }
}


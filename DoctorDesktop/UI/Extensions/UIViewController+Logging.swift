import UIKit
import SwiftyBeaver

extension UIViewController {

    private static let _swizzleOnce: Void = {
        let original = #selector(UIViewController.viewDidAppear(_:))
        let swizzled = #selector(UIViewController.logged_viewDidAppear(_:))
        guard
            let originalMethod = class_getInstanceMethod(UIViewController.self, original),
            let swizzledMethod  = class_getInstanceMethod(UIViewController.self, swizzled)
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    static func enableScreenLogging() {
        _ = _swizzleOnce
    }

    @objc private func logged_viewDidAppear(_ animated: Bool) {
        logged_viewDidAppear(animated)
        let name = String(describing: type(of: self))
        SwiftyBeaver.debug("📱 Screen: \(name)")
    }
}

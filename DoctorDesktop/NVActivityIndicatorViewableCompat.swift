//
//  NVActivityIndicatorViewableCompat.swift
//  DoctorDesktop
//
//  Compatibility shim: NVActivityIndicatorView 5.x removed the
//  NVActivityIndicatorViewable protocol. This file re-introduces the
//  protocol + a UIViewController extension so existing call sites
//  (startAnimating(message:) / stopAnimating()) continue to compile
//  without changes.
//

import UIKit

// MARK: - Protocol

/// Empty marker protocol — kept so existing `: NVActivityIndicatorViewable`
/// conformance declarations still compile.
protocol NVActivityIndicatorViewable: AnyObject {}

// MARK: - UIViewController extension (provides the actual implementation)

private var _overlayKey: UInt8 = 0

extension UIViewController {

    // The semi-transparent overlay added to the key window while loading.
    private var activityOverlay: UIView? {
        get { return objc_getAssociatedObject(self, &_overlayKey) as? UIView }
        set { objc_setAssociatedObject(self, &_overlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Shows a full-screen loading overlay with an optional message label.
    func startAnimating(message: String? = nil) {
        DispatchQueue.main.async {
            guard self.activityOverlay == nil else { return }

            let overlay = UIView()
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
            overlay.translatesAutoresizingMaskIntoConstraints = false

            let container = UIView()
            container.backgroundColor = UIColor(white: 0.12, alpha: 0.9)
            container.layer.cornerRadius = 12
            container.translatesAutoresizingMaskIntoConstraints = false

            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()

            container.addSubview(spinner)

            if let text = message, !text.isEmpty {
                let label = UILabel()
                label.text = text
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                label.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(label)

                NSLayoutConstraint.activate([
                    spinner.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
                    spinner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10),
                    label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
                    label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
                    container.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
                ])
            } else {
                NSLayoutConstraint.activate([
                    spinner.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
                    spinner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    container.bottomAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16),
                ])
            }

            overlay.addSubview(container)

            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                container.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            ])

            // Attach to the key window so it floats above everything.
            let target: UIView
            if let window = UIApplication.shared.keyWindow {
                target = window
            } else {
                target = self.view
            }
            target.addSubview(overlay)
            NSLayoutConstraint.activate([
                overlay.topAnchor.constraint(equalTo: target.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: target.bottomAnchor),
                overlay.leadingAnchor.constraint(equalTo: target.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: target.trailingAnchor),
            ])

            self.activityOverlay = overlay
        }
    }

    /// Removes the loading overlay.
    func stopAnimating() {
        DispatchQueue.main.async {
            self.activityOverlay?.removeFromSuperview()
            self.activityOverlay = nil
        }
    }
}

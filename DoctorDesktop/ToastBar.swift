//
//  ToastBar.swift
//  DoctorDesktop
//
//  In-project replacement for the prebuilt Toastlity.xcframework.
//  The xcframework was a binary drop with no dSYM, which caused
//  "Upload Symbols Failed" warnings on every App Store / TestFlight
//  upload. Replacing it with native code drops the warning and gives
//  us full source-level control over toast styling.
//
//  Public surface preserved (call sites unchanged):
//      lazy var toastBar: ToastBar = .init(settings: .agent, in: parent?.view)
//      toastBar.show(with: "message")
//

import UIKit

// MARK: - Settings

/// Visual configuration for `ToastBar`.
public struct ToastBarSettings {
    public var background: UIColor
    public var textColor:  UIColor
    public var font:       UIFont
    public var duration:   TimeInterval
    public var height:     CGFloat

    public init(background: UIColor = UIColor(red: 0.18, green: 0.34, blue: 0.62, alpha: 1),
                textColor:  UIColor = .white,
                font:       UIFont  = .systemFont(ofSize: 14, weight: .medium),
                duration:   TimeInterval = 2.5,
                height:     CGFloat = 44) {
        self.background = background
        self.textColor  = textColor
        self.font       = font
        self.duration   = duration
        self.height     = height
    }

    /// Default appearance used everywhere in the app — matches the look of
    /// the previous Toastlity `.agent` style.
    public static let agent = ToastBarSettings()
}

// MARK: - ToastBar

/// Lightweight banner that slides in from the top of the host view.
public final class ToastBar {

    private weak var hostView: UIView?
    private let settings: ToastBarSettings
    private var currentBanner: UIView?

    public init(settings: ToastBarSettings, in view: UIView?) {
        self.settings = settings
        self.hostView = view
    }

    /// Show a toast message. Subsequent calls cancel and replace any
    /// in-flight banner so messages don't stack.
    public func show(with text: String) {
        guard !text.isEmpty else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Resolve target — fall back to the key window when no host
            // view was provided (matches Toastlity's behavior).
            let target = self.resolveTarget()
            guard let parent = target else { return }

            // Cancel any currently-visible banner.
            self.currentBanner?.layer.removeAllAnimations()
            self.currentBanner?.removeFromSuperview()

            let banner = self.makeBanner(text: text, in: parent)
            self.currentBanner = banner

            // Slide-down animation.
            banner.transform = CGAffineTransform(translationX: 0, y: -self.settings.height - 40)
            UIView.animate(withDuration: 0.28,
                           delay: 0,
                           usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.6,
                           options: [.curveEaseOut],
                           animations: {
                banner.transform = .identity
            }, completion: nil)

            // Auto-dismiss.
            DispatchQueue.main.asyncAfter(deadline: .now() + self.settings.duration) { [weak banner] in
                guard let banner = banner, banner.superview != nil else { return }
                UIView.animate(withDuration: 0.22,
                               animations: {
                                banner.transform = CGAffineTransform(translationX: 0, y: -self.settings.height - 40)
                                banner.alpha = 0
                               }, completion: { _ in
                                banner.removeFromSuperview()
                               })
            }
        }
    }

    // MARK: - Private

    private func resolveTarget() -> UIView? {
        if let host = hostView { return host }
        return UIApplication.shared.keyWindow
    }

    private func makeBanner(text: String, in parent: UIView) -> UIView {
        let banner = UIView()
        banner.backgroundColor = settings.background
        banner.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.font = settings.font
        label.textColor = settings.textColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        banner.addSubview(label)
        parent.addSubview(banner)

        let topAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            topAnchor = parent.safeAreaLayoutGuide.topAnchor
        } else {
            topAnchor = parent.topAnchor
        }

        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            banner.topAnchor.constraint(equalTo: topAnchor),
            banner.heightAnchor.constraint(greaterThanOrEqualToConstant: settings.height),

            label.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: banner.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -10),
        ])
        return banner
    }
}

//
//  HomeBackgroundView.swift
//  DoctorDesktop
//
//  Decorative background for the home screen. Draws:
//    • A wavy ECG heartbeat line near the bottom — instantly signals
//      "medical app" without taking screen real estate from the cards.
//    • Two soft dot-grid patterns in the bottom-left + top-right
//      corners (à la modern medical-app launch screens).
//    • A subtle organic blob behind the top-right corner so the screen
//      doesn't feel like a flat white sheet.
//
//  Drawn with CAShapeLayer for crisp scaling at any size. All artwork
//  lives behind every other view — the controller adds this view as
//  subview 0 and everything else stacks on top.
//

import UIKit

final class HomeBackgroundView: UIView {

    // MARK: - Theme

    /// Soft cool-blue used by every decorative stroke / fill. Low alpha
    /// so the foreground cards / text always read first.
    private static let accent     = UIColor(red: 0.58, green: 0.71, blue: 0.86, alpha: 1)
    private static let accentSoft = UIColor(red: 0.58, green: 0.71, blue: 0.86, alpha: 0.35)
    private static let blobTint   = UIColor(red: 0.84, green: 0.92, blue: 0.98, alpha: 1)

    // MARK: - Layers

    private let baseGradient   = CAGradientLayer()
    private let topBlob        = CAShapeLayer()
    private let bottomBlob     = CAShapeLayer()
    private let heartbeatLayer = CAShapeLayer()
    private let dotsLeftLayer  = CALayer()
    private let dotsRightLayer = CALayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Soft mint → cream base gradient (calming medical canvas).
        baseGradient.colors = [
            UIColor(red: 0.95, green: 0.97, blue: 0.99, alpha: 1).cgColor,
            UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1).cgColor,
        ]
        baseGradient.startPoint = CGPoint(x: 0.5, y: 0)
        baseGradient.endPoint   = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(baseGradient, at: 0)

        // Organic blobs — light tint, no stroke.
        for blob in [topBlob, bottomBlob] {
            blob.fillColor = HomeBackgroundView.blobTint.cgColor
            blob.strokeColor = nil
            layer.addSublayer(blob)
        }

        // ECG heartbeat — colored stroke, no fill.
        heartbeatLayer.strokeColor = HomeBackgroundView.accent.cgColor
        heartbeatLayer.fillColor = nil
        heartbeatLayer.lineWidth = 2
        // `CAShapeLayer.lineCap` is typed as `String` in this project's
        // Swift target (the newer `.round` enum-case syntax compiles to
        // a `String` member lookup and fails). Use the kCA… constants
        // which work on every version.
        heartbeatLayer.lineCap  = kCALineCapRound
        heartbeatLayer.lineJoin = kCALineJoinRound
        layer.addSublayer(heartbeatLayer)

        // Dot patterns — built each layout pass into the two corner layers.
        layer.addSublayer(dotsLeftLayer)
        layer.addSublayer(dotsRightLayer)

        // This view is purely decorative — it must never block taps on the
        // cards or footer above it.
        isUserInteractionEnabled = false
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        baseGradient.frame = bounds

        // ─── Top-right blob ─────────────────────────────────────────────
        let topPath = UIBezierPath()
        let tr = CGPoint(x: bounds.maxX, y: bounds.minY)
        topPath.move(to: CGPoint(x: tr.x - 220, y: tr.y))
        topPath.addQuadCurve(to: CGPoint(x: tr.x, y: tr.y + 180),
                             controlPoint: CGPoint(x: tr.x + 40, y: tr.y + 30))
        topPath.addLine(to: tr)
        topPath.close()
        topBlob.path = topPath.cgPath

        // ─── Bottom-left blob ───────────────────────────────────────────
        let bottomPath = UIBezierPath()
        let bl = CGPoint(x: bounds.minX, y: bounds.maxY)
        bottomPath.move(to: CGPoint(x: bl.x, y: bl.y - 160))
        bottomPath.addQuadCurve(to: CGPoint(x: bl.x + 200, y: bl.y),
                                controlPoint: CGPoint(x: bl.x - 30, y: bl.y + 30))
        bottomPath.addLine(to: bl)
        bottomPath.close()
        bottomBlob.path = bottomPath.cgPath

        // ─── ECG heartbeat line ─────────────────────────────────────────
        heartbeatLayer.path = buildHeartbeatPath().cgPath

        // ─── Dot patterns (rebuild on resize) ───────────────────────────
        rebuildDotPattern(in: dotsLeftLayer,
                          origin: CGPoint(x: 16, y: bounds.maxY - 200),
                          cols: 8, rows: 10)
        rebuildDotPattern(in: dotsRightLayer,
                          origin: CGPoint(x: bounds.maxX - 110, y: bounds.maxY - 140),
                          cols: 6, rows: 7)
    }

    // MARK: - Heartbeat path

    /// Builds a single horizontal ECG line near the bottom of the view —
    /// flatline for most of the width with one QRS-style spike in the
    /// centre. The geometry scales to the view's width, so it looks the
    /// same on small phones and iPads.
    private func buildHeartbeatPath() -> UIBezierPath {
        let p = UIBezierPath()
        let y = bounds.maxY - 70                 // baseline height
        let leftX  = bounds.minX + 80
        let rightX = bounds.maxX - 80
        let midX   = bounds.midX

        p.move(to: CGPoint(x: leftX, y: y))

        // Flatline to just before the spike.
        let spikeStart = midX - 50
        let spikeEnd   = midX + 50
        p.addLine(to: CGPoint(x: spikeStart, y: y))

        // P-wave (small bump up)
        p.addLine(to: CGPoint(x: spikeStart + 8,  y: y - 8))
        p.addLine(to: CGPoint(x: spikeStart + 16, y: y))

        // QRS complex (small dip, big peak, small dip)
        p.addLine(to: CGPoint(x: spikeStart + 22, y: y + 8))
        p.addLine(to: CGPoint(x: midX,             y: y - 38))
        p.addLine(to: CGPoint(x: spikeEnd - 22,    y: y + 8))
        p.addLine(to: CGPoint(x: spikeEnd - 16,    y: y))

        // T-wave (small rounded bump)
        p.addLine(to: CGPoint(x: spikeEnd - 8, y: y - 6))
        p.addLine(to: CGPoint(x: spikeEnd,     y: y))

        // Flatline to the right edge.
        p.addLine(to: CGPoint(x: rightX, y: y))
        return p
    }

    // MARK: - Dot grid

    /// Builds (or rebuilds) a `cols × rows` grid of small circular dots
    /// inside `layer`. Each dot is its own sublayer so the pattern stays
    /// crisp on every screen scale.
    private func rebuildDotPattern(in layer: CALayer,
                                   origin: CGPoint,
                                   cols: Int,
                                   rows: Int) {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let spacing: CGFloat = 14
        let radius:  CGFloat = 2
        for r in 0..<rows {
            for c in 0..<cols {
                let dot = CALayer()
                dot.frame = CGRect(
                    x: origin.x + CGFloat(c) * spacing - radius,
                    y: origin.y + CGFloat(r) * spacing - radius,
                    width: radius * 2, height: radius * 2
                )
                dot.cornerRadius = radius
                dot.backgroundColor = HomeBackgroundView.accentSoft.cgColor
                layer.addSublayer(dot)
            }
        }
    }
}

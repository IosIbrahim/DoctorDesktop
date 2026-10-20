//
//  ComponentCell.swift
//  Doctor DeskTop
//
//  Modern full-width tile for the home grid.
//
//  ┌──────────────────────────────────────────────────────────┐
//  │  ╭────╮                                                  │
//  │  │ 🏥 │   Inpatients                          33      ›  │
//  │  ╰────╯   Active cases on your wards                     │
//  └──────────────────────────────────────────────────────────┘
//
//  Built programmatically — no XIB. The IBOutlets from the previous
//  version are gone; outside callers only touch `configure(with:)`.
//

import UIKit

class ComponentCell: UICollectionViewCell {

    // MARK: - Theme

    private static let cardBG    = UIColor.white
    private static let title     = UIColor(white: 0.08, alpha: 1)
    private static let subtitle  = UIColor(white: 0.45, alpha: 1)
    private static let chevron   = UIColor(white: 0.72, alpha: 1)

    // MARK: - Subviews

    private let card: UIView = {
        let v = UIView()
        v.backgroundColor = ComponentCell.cardBG
        v.layer.cornerRadius = 18
        v.layer.shadowColor   = UIColor(red: 0.07, green: 0.22, blue: 0.34, alpha: 1).cgColor
        v.layer.shadowOpacity = 0.14
        v.layer.shadowRadius  = 14
        v.layer.shadowOffset  = CGSize(width: 0, height: 6)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// 4-pt rounded accent strip floating inside the card's leading edge.
    /// We inset it vertically (and round both ends) so it can't poke past
    /// the card's rounded corner and doesn't need a clipping wrapper —
    /// the card keeps its shadow without `masksToBounds` issues.
    private let accentBar: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// Soft-tinted circle holding the category icon.
    private let iconCircle: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 28
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        i.tintColor = .white
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        l.textColor = ComponentCell.title
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = ComponentCell.subtitle
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    /// Big tinted count — the headline metric of the row.
    private let countLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()

    private let chevronView: UIImageView = {
        let i = UIImageView()
        i.tintColor = ComponentCell.chevron
        i.contentMode = .scaleAspectFit
        i.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            i.image = UIImage(systemName: "chevron.right", withConfiguration: cfg)
        }
        return i
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    /// Cache the shadow path so scrolling stays buttery.
    override func layoutSubviews() {
        super.layoutSubviews()
        card.layer.shadowPath = UIBezierPath(
            roundedRect: card.bounds,
            cornerRadius: card.layer.cornerRadius
        ).cgPath
    }

    private func buildUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(card)
        card.addSubview(accentBar)
        card.addSubview(iconCircle)
        iconCircle.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(countLabel)
        card.addSubview(chevronView)

        NSLayoutConstraint.activate([
            // Card fills the cell with a small margin so the shadow shows.
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            // Accent bar — inset 14pt from top/bottom so it sits well
            // inside the card's rounded corners, 8pt from the leading
            // edge so it floats rather than touching the edge.
            accentBar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            accentBar.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            accentBar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            accentBar.widthAnchor.constraint(equalToConstant: 4),

            // Icon circle
            iconCircle.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 12),
            iconCircle.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 56),
            iconCircle.heightAnchor.constraint(equalToConstant: 56),

            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 30),
            iconView.heightAnchor.constraint(equalToConstant: 30),

            // Chevron — far right
            chevronView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 10),
            chevronView.heightAnchor.constraint(equalToConstant: 16),

            // Count — to the left of chevron
            countLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -10),
            countLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            // Title — between icon and count
            titleLabel.leadingAnchor.constraint(equalTo: iconCircle.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: iconCircle.topAnchor, constant: 6),

            // Subtitle — under title
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -10),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text    = ""
        subtitleLabel.text = ""
        countLabel.text    = ""
        iconView.image     = nil
        iconCircle.backgroundColor = .clear
        accentBar.backgroundColor  = .clear
        countLabel.textColor       = ComponentCell.title
    }

    // MARK: - Press feedback

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.card.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.98, y: 0.98)
                    : .identity
                self.card.layer.shadowOpacity = self.isHighlighted ? 0.08 : 0.14
            }
        }
    }
}

// MARK: - Configure

extension ComponentCell {
    func configure(with presenter: ComponentCellPresenter) {
        titleLabel.text    = presenter.title
        subtitleLabel.text = presenter.subtitle
        countLabel.text    = presenter.count
        iconView.image     = presenter.image.withRenderingMode(.alwaysTemplate)

        // Use the presenter's start colour as the tile's "brand" colour:
        // the accent bar, icon circle background, and count text all use
        // it so the row is colour-coded at a glance.
        let brand = presenter.startColor
        accentBar.backgroundColor  = brand
        iconCircle.backgroundColor = brand
        countLabel.textColor       = brand
    }
}

// MARK: - Helper Methods

extension ComponentCell {
    public static var cellId: String { return "ComponentCell" }

    public static func register(with collectionView: UICollectionView) {
        collectionView.register(ComponentCell.self, forCellWithReuseIdentifier: ComponentCell.cellId)
    }

    public static func dequeue(from collectionView: UICollectionView,
                               for indexPath: IndexPath,
                               with presenter: ComponentCellPresenter) -> ComponentCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ComponentCell.cellId, for: indexPath) as! ComponentCell
        cell.configure(with: presenter)
        return cell
    }
}

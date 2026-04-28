//
//  ProgressNoteReplyCell.swift
//  DoctorDesktop
//
//  Right-aligned chat bubble for a reply attached to a progress note.
//  Mirrors the Android design (see screenshot in design folder):
//
//      ┌────────────────────────────────────────┐
//      │                       Author Name      │  (green-tinted card)
//      │                                  ┌───┐ │
//      │                       Reply body │ 👤│ │
//      │                                  └───┘ │
//      │                          18/10/2025…   │
//      └────────────────────────────────────────┘
//
//  Avatar sits on the trailing edge, the bubble itself hugs the right side
//  of the contentView with a generous leading margin so it visually reads
//  as an outgoing / response message.
//
//  Data source: `DoctorNurseNoteReply` (decoded from REPLY.REPLY_ROW).
//
//  NOTE: A trash button is intentionally NOT shown here yet — reply
//  deletion needs the Android POST trace (BUFFER_STATUS / PROCESS_ID for
//  the reply path) before it can be wired. Until then the cell is read-only.
//

import UIKit

final class ProgressNoteReplyCell: UITableViewCell {

    static let reuseId = "ProgressNoteReplyCell"

    // MARK: Colours
    //
    // Green tint matches the outgoing-message bubble in the Android screen.

    private static let bubbleBG = UIColor(red: 0.86, green: 0.96, blue: 0.91, alpha: 1)
    private static let teal     = UIColor(red: 0.22, green: 0.72, blue: 0.62, alpha: 1)

    // MARK: Views

    private let card      = UIView()
    private let avatar    = UIImageView()
    private let nameLabel = UILabel()
    private let bodyLabel = UILabel()
    private let dateLabel = UILabel()

    // MARK: Init

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none
        buildUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: Build UI

    private func buildUI() {

        // ── Card (green-tinted bubble) ─────────────────────────────────────────
        card.backgroundColor = Self.bubbleBG
        card.layer.cornerRadius = 12
        card.layer.shadowColor   = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius  = 4
        card.layer.shadowOffset  = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        // ── Avatar (sits to the right of the card) ─────────────────────────────
        avatar.backgroundColor = Self.teal
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        avatar.contentMode = .center
        avatar.tintColor = .white
        if #available(iOS 13, *) {
            avatar.image = UIImage(systemName: "person.fill")
        }
        avatar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatar)

        // ── Author name ─────────────────────────────────────────────────────────
        nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel.textColor = UIColor(white: 0.30, alpha: 1)
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)

        // ── Reply body ──────────────────────────────────────────────────────────
        bodyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = UIColor(white: 0.18, alpha: 1)
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bodyLabel)

        // ── Date ────────────────────────────────────────────────────────────────
        dateLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        dateLabel.textColor = UIColor(white: 0.50, alpha: 1)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(dateLabel)

        // ── Layout ──────────────────────────────────────────────────────────────
        // Card hugs the right side. Leading edge has a `>=` constraint so the
        // bubble narrows to fit short replies but never spans the full width
        // (matching the Android outgoing-message style).
        NSLayoutConstraint.activate([
            // Card: top/bottom + right side (avatar lives outside)
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor,
                                          constant: 60),
            card.trailingAnchor.constraint(equalTo: avatar.leadingAnchor, constant: -8),

            // Avatar: pinned to the trailing edge, top-aligned with the card
            avatar.topAnchor.constraint(equalTo: card.topAnchor),
            avatar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40),

            // Name across the top of the bubble
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // Body below the name
            bodyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            bodyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            bodyLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // Date in the bottom-trailing corner of the bubble
            dateLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            dateLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
        ])
    }

    // MARK: Configure

    func configure(with reply: DoctorNurseNoteReply) {
        // Author — locale-aware (handled by reply.authorName).
        let author = reply.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        nameLabel.text = author.isEmpty ? "—" : author

        // Body — already trimmed by the model.
        let body = reply.body
        bodyLabel.text = body.isEmpty ? "—" : body

        // Author + body alignment follow the user's locale (Arabic readers
        // see the bubble laid out RTL; English readers see LTR with the
        // text trailing-aligned to feel like a chat message).
        let isArabic = Locale.current.languageCode == "ar"
        nameLabel.textAlignment = isArabic ? .right : .left
        bodyLabel.textAlignment = isArabic ? .right : .left
        dateLabel.textAlignment = .right

        dateLabel.text = reply.dateEnter ?? ""
    }

    // MARK: Reuse reset

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        bodyLabel.text = nil
        dateLabel.text = nil
    }
}

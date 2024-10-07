//
//  CommentCell.swift
//  MindReader
//
//  Created by J oyce on 2024/9/19.
//

import Foundation
import UIKit

class CommentCell: UITableViewCell {
    var reportButtonTappedClosure: ((String) -> Void)?

    // MARK: - Properties
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0 // 可以換行
        return label
    }()

    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.numberOfLines = 1
        return label
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.brown.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    let reportButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupViews() {
        contentView.backgroundColor = .white
        contentView.addSubview(cardView)
        cardView.addSubview(reportButton)
        cardView.addSubview(authorLabel)
        cardView.addSubview(contentLabel)
        cardView.addSubview(timestampLabel)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            reportButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            reportButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),

            authorLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            authorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            authorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),

            contentLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 5),
            contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),

            // 時間標籤的約束
            timestampLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 5),
            timestampLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            timestampLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
        ])

        setupReportMenu()
    }

    private func setupReportMenu() {
        let reportAction = UIAction(title: "檢舉", image: UIImage(systemName: "exclamationmark.bubble")) { _ in
            self.reportButtonTappedClosure?("檢舉")
        }

        let blockAction = UIAction(title: "封鎖", image: UIImage(systemName: "hand.raised")) { _ in
            self.reportButtonTappedClosure?("封鎖")
        }

        let menu = UIMenu(title: "", children: [reportAction, blockAction])
        reportButton.menu = menu
        reportButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - Configuration
    func configure(author: String, content: String, timestamp: Date) {
        authorLabel.text = author
        contentLabel.text = content
        timestampLabel.text = timeAgoDisplay(from: timestamp)
    }

    private func timeAgoDisplay(from timestamp: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: timestamp, to: now)

        if let year = components.year, year >= 1 {
            return "\(year) 年前"
        } else if let month = components.month, month >= 1 {
            return "\(month) 個月前"
        } else if let week = components.weekOfYear, week >= 1 {
            return "\(week) 週前"
        } else if let day = components.day, day >= 1 {
            return "\(day) 天前"
        } else if let hour = components.hour, hour >= 1 {
            return "\(hour) 小時前"
        } else if let minute = components.minute, minute >= 1 {
            return "\(minute) 分鐘前"
        } else {
            return "剛剛"
        }
    }
}

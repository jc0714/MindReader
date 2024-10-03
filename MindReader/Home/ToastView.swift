//
//  ToastView.swift
//  MindReader
//
//  Created by J oyce on 2024/10/3.
//

import Foundation
import UIKit

class ToastView: UIView, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    
    private var possibleMeanings: [String] = []
    private var responseMethods: [String] = []

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundColor = .orange
        self.layer.cornerRadius = 20
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 5

        addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        closeButton.addTarget(self, action: #selector(closeToast), for: .touchUpInside)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResponseCell")
        tableView.register(ResponseCopyCell.self, forCellReuseIdentifier: "ResponseCopyCell")

        tableView.backgroundColor = UIColor(red: 255/255, green: 223/255, blue: 186/255, alpha: 1)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 15
        tableView.separatorStyle = .none
        
        self.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }

    func configure(with possibleMeanings: [String], responseMethods: [String]) {
        self.possibleMeanings = possibleMeanings
        self.responseMethods = responseMethods
        tableView.reloadData()
    }

    @objc private func closeToast() {
        self.removeFromSuperview()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // “可能含義”和“推薦回覆”
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return possibleMeanings.count
        } else {
            return responseMethods.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResponseCell", for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.backgroundColor = .clear

            cell.textLabel?.text = "\(indexPath.row + 1). \(possibleMeanings[indexPath.row])"

            return cell
        } else {          
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResponseCopyCell", for: indexPath) as? ResponseCopyCell

            let text = "\(responseMethods[indexPath.row])"
            cell?.configure(with: text)

            return cell!
        }
    }

    // MARK: - Section Headers

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 255/255, green: 223/255, blue: 186/255, alpha: 1)

        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .systemBrown
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        if section == 0 {
            titleLabel.text = "可能含義"
        } else {
            titleLabel.text = "推薦回覆"
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    // MARK: - Long Press Gesture Handler

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        if let cell = gesture.view as? UITableViewCell, let indexPath = tableView.indexPath(for: cell), indexPath.section == 1 {
            let responseToCopy = responseMethods[indexPath.row]
            UIPasteboard.general.string = responseToCopy
            print("Copied to clipboard: \(responseToCopy)")
        }
    }

    func showInView(_ parentView: UIView) {
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false

        let offScreenBottomConstraint = self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 300)
        offScreenBottomConstraint.isActive = true

        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            self.widthAnchor.constraint(equalToConstant: 330),
            self.heightAnchor.constraint(equalToConstant: 550)
        ])

        parentView.layoutIfNeeded()

        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            offScreenBottomConstraint.constant = -100
            parentView.layoutIfNeeded()
        })
    }

}

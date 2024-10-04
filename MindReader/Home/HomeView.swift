//
//  HomeView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import Foundation
import UIKit
import Lottie

class HomeView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var waitingAnimationView: LottieAnimationView = {
        // 使用自定義的 LottieConfiguration，指定 renderingEngine 為 .mainThread
        let configuration = LottieConfiguration(renderingEngine: .mainThread)
        let animationView = LottieAnimationView(
            name: "runningDoggy",
            configuration: configuration
        )
        return animationView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "人性翻譯機"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .pink3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let chatButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis.message"), for: .normal)
        button.tintColor = .pink3
        button.layer.cornerRadius = 10
        return button
    }()

    let imageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Image", for: .normal)
        button.backgroundColor = .pink1
        button.layer.cornerRadius = 10
        return button
    }()

    let textButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Text", for: .normal)
        button.backgroundColor = .pink1
        button.layer.cornerRadius = 10
        return button
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .pink1
        imageView.layer.cornerRadius = 10
        imageView.image = UIImage(named: "uploadImage")
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let promptTextField: UITextView = {
        let field = UITextView()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 10
        field.clipsToBounds = true
        field.backgroundColor = .milkYellow
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        field.returnKeyType = .done
        field.font = UIFont.systemFont(ofSize: 16)
        field.isHidden = true
        return field
    }()

    let submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Generate", for: .normal)
        button.backgroundColor = .pink1
        button.layer.cornerRadius = 10
        button.tag = 0 // 初始設定在圖片
        return button
    }()

    let generateImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: "photo.artframe"), for: .normal)
        button.setTitle("製作早安圖", for: .normal)
        button.backgroundColor = .pink1
        button.layer.cornerRadius = 10
        button.isHidden = true
        return button
    }()

    let indicatorView = UIView()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    private let audienceOptions = ["朋友", "家人", "同事", "陌生人"]
    private let replyStyleOptions = ["直接", "溫和", "幽默", "正式"]

    var selectedAudienceIndex: IndexPath?
    var selectedReplyStyleIndex: IndexPath?

    var selectedAudienceText: String? {
        guard let index = selectedAudienceIndex?.item else { return nil }
        return audienceOptions[index]
    }

    var selectedReplyStyleText: String? {
        guard let index = selectedReplyStyleIndex?.item else { return nil }
        return replyStyleOptions[index]
    }

    private let audienceCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private let replyStyleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureCollectionViews()

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
        configureCollectionViews()

    }

    private func configureUI() {
        backgroundColor = .systemBackground

        waitingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(waitingAnimationView)
        addSubview(titleLabel)

        addSubview(chatButton)
        addSubview(imageButton)
        addSubview(textButton)

        addSubview(promptTextField)

        addSubview(imageView)

        addSubview(audienceCollectionView)
        addSubview(replyStyleCollectionView)

        addSubview(submitButton)
        addSubview(indicatorView)

        addSubview(generateImageButton)

        indicatorView.isHidden = true
        indicatorView.frame = bounds
        indicatorView.backgroundColor = .milkYellow
        indicatorView.alpha = 0.95

        indicatorView.addSubview(activityIndicator)
        activityIndicator.center = center

        NSLayoutConstraint.activate([
            chatButton.topAnchor.constraint(equalTo: topAnchor, constant: 120),
            chatButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            
            imageButton.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            imageButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: -120),
            imageButton.widthAnchor.constraint(equalToConstant: 100),
            imageButton.heightAnchor.constraint(equalToConstant: 30),

            textButton.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            textButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 20),
            textButton.widthAnchor.constraint(equalToConstant: 100),
            textButton.heightAnchor.constraint(equalToConstant: 30),

            promptTextField.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 30),
            promptTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            promptTextField.widthAnchor.constraint(equalToConstant: 300),
            promptTextField.heightAnchor.constraint(equalToConstant: 150),

            imageView.topAnchor.constraint(equalTo: imageButton.bottomAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            audienceCollectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            audienceCollectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            audienceCollectionView.widthAnchor.constraint(equalToConstant: 300),
            audienceCollectionView.heightAnchor.constraint(equalToConstant: 50),

            replyStyleCollectionView.topAnchor.constraint(equalTo: audienceCollectionView.bottomAnchor, constant: 20),
            replyStyleCollectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            replyStyleCollectionView.widthAnchor.constraint(equalToConstant: 300),
            replyStyleCollectionView.heightAnchor.constraint(equalToConstant: 50),

            submitButton.topAnchor.constraint(equalTo: replyStyleCollectionView.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 300),
            submitButton.heightAnchor.constraint(equalToConstant: 50),

            generateImageButton.bottomAnchor.constraint(equalTo: chatButton.bottomAnchor),
            generateImageButton.trailingAnchor.constraint(equalTo: chatButton.trailingAnchor, constant: 15),

            waitingAnimationView.centerXAnchor.constraint(equalTo: promptTextField.centerXAnchor, constant: 0),
            waitingAnimationView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 80),
            waitingAnimationView.widthAnchor.constraint(equalToConstant: 300),
            waitingAnimationView.heightAnchor.constraint(equalToConstant: 300)
        ])
        waitingAnimationView.isHidden = true

        bringSubviewToFront(chatButton)
        bringSubviewToFront(waitingAnimationView)
    }

    private func configureCollectionViews() {
            // Register cell class for both collection views
        audienceCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "AudienceCell")
        replyStyleCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ReplyStyleCell")

        // Set delegates and data sources
        audienceCollectionView.delegate = self
        audienceCollectionView.dataSource = self

        replyStyleCollectionView.delegate = self
        replyStyleCollectionView.dataSource = self
    }

    // MARK: - Helper Methods to Configure Cells
    private func configureCell(_ cell: UICollectionViewCell, withText text: String, isSelected: Bool, at indexPath: IndexPath) {

        // 設置背景顏色
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = isSelected ? 2 : 0
        cell.contentView.layer.borderColor = isSelected ? UIColor.green.cgColor : UIColor.clear.cgColor
        cell.contentView.backgroundColor = isSelected ? .white.withAlphaComponent(0.2) : .pink2

        // 移除現有的 label 再添加新的
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])

        // 點按放大效果
        cell.contentView.transform = isSelected ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity

        // 添加動畫
        if isSelected {
            UIView.animate(withDuration: 0.3, animations: {
                cell.contentView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                cell.contentView.transform = .identity
            })
        }
    }

    // 顯示動畫
    func showLoadingAnimation() {
        self.bringSubviewToFront(self.waitingAnimationView)
        waitingAnimationView.isHidden = false
        waitingAnimationView.loopMode = .loop
        self.waitingAnimationView.play()
        self.layoutIfNeeded()
    }

    // 隱藏動畫
    func hideLoadingAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.waitingAnimationView.alpha = 0
        }) { _ in
            self.waitingAnimationView.stop()
            self.waitingAnimationView.isHidden = true
            self.waitingAnimationView.alpha = 1
        }
    }
}

extension HomeView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == audienceCollectionView ? audienceOptions.count : replyStyleOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView == audienceCollectionView ? "AudienceCell" : "ReplyStyleCell", for: indexPath)

        let text = collectionView == audienceCollectionView ? audienceOptions[indexPath.item] : replyStyleOptions[indexPath.item]
        let isSelected = (collectionView == audienceCollectionView && selectedAudienceIndex == indexPath) ||
                         (collectionView == replyStyleCollectionView && selectedReplyStyleIndex == indexPath)
        configureCell(cell, withText: text, isSelected: isSelected, at: indexPath)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == audienceCollectionView {
            // Deselect previously selected item
            if let previousIndex = selectedAudienceIndex {
                collectionView.deselectItem(at: previousIndex, animated: true)
            }
            selectedAudienceIndex = indexPath
        } else {
            // Deselect previously selected item
            if let previousIndex = selectedReplyStyleIndex {
                collectionView.deselectItem(at: previousIndex, animated: true)
            }
            selectedReplyStyleIndex = indexPath
        }

        // Reload the collection view to update the selection state
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 40)
    }
}

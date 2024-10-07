//
//  ImageCollectionView.swift
//  MindReader
//
//  Created by J oyce on 2024/9/21.
//

import UIKit

protocol ImageCollectionViewDelegate: AnyObject {
    func didSelectImage(named imageName: String)
}

class ImageCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    weak var delegate: ImageCollectionViewDelegate?

    private let imageNames = ["photo1", "photo2", "photo3", "photo4", "photo5", "photo6", "photo7","photo8", "photo9", "photo10", "photo11", "photo12", "photo13", "photo14", "photo15"]

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        return collectionView
    }()

    private var selectedIndexPath: IndexPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        let imageView = UIImageView(image: UIImage(named: imageNames[indexPath.item]))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImageName = imageNames[indexPath.item]
        delegate?.didSelectImage(named: selectedImageName)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }

    // MARK: - ScrollView Delegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 處理滑動時的卡片縮放效果
        for cell in collectionView.visibleCells {
            let cellCenter = collectionView.convert(cell.center, to: nil)
            let screenCenter = collectionView.superview!.center
            let distance = abs(screenCenter.x - cellCenter.x)
            let scale = max(1 - distance / screenCenter.x, 0.9)
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)

            if scale >= 1.0 {
                HapticFeedbackManager.lightFeedback()
            }
        }
    }
}

//
//  AlbumFullScreenVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/22.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseStorage

class AlbumFullScreenVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var imageUrls: [URL] = []
    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCollectionView()
        setupCloseButton()
        setupToolbar()

        // 滑動到當前選中的圖片
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = view.bounds.size

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")

        view.addSubview(collectionView)
    }

    func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeFullScreen), for: .touchUpInside)

        view.addSubview(closeButton)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc func closeFullScreen() {
        dismiss(animated: true, completion: nil)
    }

    func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        toolbar.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(toolbar)

        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveImage))
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareImage))
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteImage))

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([saveButton, flexibleSpace, shareButton, flexibleSpace, deleteButton], animated: false)

        NSLayoutConstraint.activate([
            toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell
        let imageUrl = imageUrls[indexPath.item]
        cell?.configure(with: imageUrl)
        return cell!
    }

    // MARK: - Toolbar Actions

    @objc func saveImage() {
        if let visibleCell = collectionView.visibleCells.first as? ImageCell, let image = visibleCell.imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }

    @objc func shareImage() {
        if let visibleCell = collectionView.visibleCells.first as? ImageCell, let image = visibleCell.imageView.image {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
        }
    }

    @objc func deleteImage() {
        let indexPath = collectionView.indexPathsForVisibleItems.first
        if let index = indexPath?.item {
            let imageUrl = imageUrls[index]

            let storageRef = Storage.storage().reference(forURL: imageUrl.absoluteString)

            storageRef.delete { error in
                if let error = error {
                    print("Error deleting image: \(error.localizedDescription)")
                    return
                }

                guard let userId = UserDefaults.standard.string(forKey: "userID") else {
                    print("User ID is nil")
                    return
                }

                let db = Firestore.firestore()
                let morningImageRef = db.collection("Users").document(userId).collection("MorningImage")

                morningImageRef.whereField("imageURL", isEqualTo: imageUrl.absoluteString).getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching documents: \(error.localizedDescription)")
                        return
                    }

                    snapshot?.documents.first?.reference.delete { error in
                        if let error = error {
                            print("Error deleting Firestore document: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async { [self] in
                                self.imageUrls.remove(at: index)
                                collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}

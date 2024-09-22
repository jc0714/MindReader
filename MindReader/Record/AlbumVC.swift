//
//  AlbumVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/19.
//

import Foundation
import UIKit
import FirebaseStorage

class AlbumVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var imageUrls: [URL] = []
    let storageRef = Storage.storage().reference()

    let layout = UICollectionViewFlowLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pink3
        setupCollectionView()
        fetchImagesFromFirebase()
    }

    func setupCollectionView() {
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)

        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: "AlbumCell")
        collectionView.backgroundColor = .white

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func fetchImagesFromFirebase() {
        let userId = "9Y2GjnVg8TEoze0GUJSU"

        let imagesRef = storageRef.child("MorningImages/\(userId)/")

        imagesRef.listAll { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error listing images: \(error.localizedDescription)")
                return
            }

            guard let items = result?.items, !items.isEmpty else {
                print("No images found.")
                return
            }

            self.imageUrls.removeAll()

            let dispatchGroup = DispatchGroup()

            for item in items {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else if let url = url {
                        self.imageUrls.append(url)
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.collectionView.reloadData()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell
        let imageUrl = imageUrls[indexPath.row]

        cell?.configure(with: imageUrl)

        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 30
        let totalSpacing: CGFloat = layout.minimumInteritemSpacing * 2
        let availableWidth = view.frame.width - padding - totalSpacing
        let side = availableWidth / 3
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullScreenVC = AlbumFullScreenVC()
        fullScreenVC.imageUrls = imageUrls // 傳遞所有圖片的 URL 列表
        fullScreenVC.currentIndex = indexPath.row // 傳遞當前選中的圖片
//        fullScreenVC.imageUrl = imageUrls[indexPath.row] // 傳遞當前選中的圖片的 URL
        fullScreenVC.modalPresentationStyle = .fullScreen

        present(fullScreenVC, animated: true, completion: nil) // 顯示全螢幕圖片檢視
    }
}

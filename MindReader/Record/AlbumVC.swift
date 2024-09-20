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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if imageUrls.isEmpty {
            fetchImagesFromFirebase()
        }
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

        imagesRef.listAll { (result, error) in
            if let error = error {
                print("Error listing images: \(error.localizedDescription)")
                return
            }

            for item in result!.items {
                item.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else if let url = url {
                        self.imageUrls.append(url)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
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
}

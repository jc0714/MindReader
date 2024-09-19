//
//  PhotoAlbumVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/19.
//


import Foundation
import UIKit
import FirebaseStorage

class PhotoAlbumVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var imageUrls: [URL] = []
    let storageRef = Storage.storage().reference()

    let layout = UICollectionViewFlowLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell
        let imageUrl = imageUrls[indexPath.row]

        cell?.configure(with: imageUrl)

        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 30
        let totalSpacing: CGFloat = layout.minimumInteritemSpacing * 2
        let availableWidth = view.frame.width - padding - totalSpacing
        let side = availableWidth / 3 // 每个 Cell 的宽度为可用宽度的三分之一
        return CGSize(width: side, height: side)
    }
}

class PhotoCell: UICollectionViewCell {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = self.contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // swiftlint:disable nused_closure_parameter
    func configure(with url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }.resume()
    }
    // swiftlint:enable nused_closure_parameter
}

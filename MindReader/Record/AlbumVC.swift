//
//  AlbumVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/19.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class AlbumVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var imageUrls: [URL] = []
    let storageRef = Storage.storage().reference()

    let layout = UICollectionViewFlowLayout()

    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pink3

        setupCollectionView()

        setUpAction()
        fetchImagesFromFirebase()
    }

    func setUpAction() {
        refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(fetchImagesFromFirebase), for: UIControl.Event.valueChanged)
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

    @objc func fetchImagesFromFirebase() {
        var newImageUrls: [URL] = []

        let db = Firestore.firestore()

        guard let userId = UserManager.shared.userId else {
            print("User ID is nil")
            return
        }
        
        let morningImageRef = db.collection("Users").document(userId).collection("MorningImage")

        // 按 createdTime 排序
        morningImageRef.order(by: "createdTime", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()  // 確保失敗時停止刷新動畫
                }
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()  // 當沒有文件時也停止刷新動畫
                }
                return
            }

            for document in documents {
                let data = document.data()
                if let imageURLString = data["imageURL"] as? String, let imageURL = URL(string: imageURLString) {
                    newImageUrls.append(imageURL)
                }
            }

            // 所有圖片連結加載完成後，更新 UI
            DispatchQueue.main.async {
                self.imageUrls = newImageUrls
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()  // 成功時停止刷新動畫
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

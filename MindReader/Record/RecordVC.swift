//
//  RecordVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/19.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class RecordVC: UIViewController {

    private let albumVC = AlbumVC()
    private let myPostVC = MyPostVC()

    private let RView = RecordView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecordView()
        setupInitialViewController()
    }

    private func setupRecordView() {
        RView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(RView)

        NSLayoutConstraint.activate([
            RView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            RView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            RView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            RView.heightAnchor.constraint(equalToConstant: 50)
        ])
        RView.setData()

        RView.buttons.forEach { button in
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }

    // 初始化時加載相簿頁面
    private func setupInitialViewController() {
        addChild(albumVC) // 預設顯示相簿頁面
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            // 顯示相簿頁面
            removeContentController(myPostVC)
            addContentController(albumVC)
        case 1:
            // 顯示我的POST頁面
            removeContentController(albumVC)
            addContentController(myPostVC)
        default:
            break
        }
    }

    // 新的自定義方法來添加子VC
    private func addContentController(_ childVC: UIViewController) {
       addChild(childVC)
       childVC.view.frame = CGRect(x: 0, y: RView.frame.maxY, width: view.bounds.width, height: view.bounds.height - RView.frame.maxY)
       view.addSubview(childVC.view)
       childVC.didMove(toParent: self)
    }

    // 新的自定義方法來移除子VC
    private func removeContentController(_ childVC: UIViewController) {
       childVC.willMove(toParent: nil)
       childVC.view.removeFromSuperview()
       childVC.removeFromParent()
    }
}

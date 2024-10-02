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
    private var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecordView()
        setupInitialViewController()

        setupSwipeGestures()
    }

    private func setupRecordView() {
        RView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(RView)

        NSLayoutConstraint.activate([
            RView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            RView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            RView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            RView.heightAnchor.constraint(equalToConstant: 50)
        ])
        RView.setData()

        RView.buttons.forEach { button in
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }

    private func setupInitialViewController() {
        addContentController(albumVC)
        currentViewController = albumVC
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        let newViewController: UIViewController
        switch sender.tag {
        case 0:
            newViewController = albumVC
        case 1:
            newViewController = myPostVC
        default:
            return
        }

        if currentViewController == newViewController {
            return
        }

        if let currentVC = currentViewController {
            removeContentController(currentVC)
        }
        addContentController(newViewController)
        currentViewController = newViewController
    }

    private func setupSwipeGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            // 左滑顯示 myPostVC
            if currentViewController != myPostVC {
                RView.updateIndicator(forIndex: 1)
                switchToViewController(myPostVC)
            }
        case .right:
            // 右滑顯示 albumVC
            if currentViewController != albumVC {
                RView.updateIndicator(forIndex: 0)
                switchToViewController(albumVC)
            }
        default:
            break
        }
    }

    private func switchToViewController(_ newViewController: UIViewController) {
        if let currentVC = currentViewController {
            removeContentController(currentVC)
        }
        addContentController(newViewController)
        currentViewController = newViewController
    }

    private func addContentController(_ childVC: UIViewController) {
        addChild(childVC)
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childVC.view)

        NSLayoutConstraint.activate([
            childVC.view.topAnchor.constraint(equalTo: RView.bottomAnchor),
            childVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        childVC.didMove(toParent: self)
    }

    private func removeContentController(_ childVC: UIViewController) {
        childVC.willMove(toParent: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
    }
}

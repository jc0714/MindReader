//
//  CustomTabBarController.swift
//  MindReader
//
//  Created by J oyce on 2024/10/5.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        self.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.layer.zPosition = 1
    }

    private func setupTabBar() {
        tabBar.layer.cornerRadius = 20
        tabBar.layer.masksToBounds = true

        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -5)
        tabBar.layer.shadowRadius = 10

        tabBar.backgroundColor = UIColor.milkYellow

        let borderView = UIView()
        borderView.backgroundColor = .white
        borderView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(borderView)

        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: tabBar.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1) // 邊框的高度
        ])

        var newFrame = tabBar.frame
        newFrame.size.height = 70
        newFrame.origin.y = self.view.frame.height - 70
        tabBar.frame = newFrame
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        HapticFeedbackManager.lightFeedback()
    }
}

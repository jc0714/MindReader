//
//  CustomTabBarController.swift
//  MindReader
//
//  Created by J oyce on 2024/10/5.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 自定義 Tab Bar
        setupTabBar()
    }

    private func setupTabBar() {
        tabBar.layer.cornerRadius = 20
        tabBar.layer.masksToBounds = true

        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -5)
        tabBar.layer.shadowRadius = 10

        tabBar.backgroundColor = UIColor.milkYellow

        var newFrame = tabBar.frame
        newFrame.size.height = 70
        newFrame.origin.y = self.view.frame.height - 70
        tabBar.frame = newFrame
    }
}

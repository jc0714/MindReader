//
//  HideTabBarVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/25.
//

import Foundation
import UIKit

class HideTabBarVC: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}

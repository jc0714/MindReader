//
//  PostManager.swift
//  MindReader
//
//  Created by J oyce on 2024/11/14.
//

import Foundation
import UIKit

class PostManager {
    static func createReportMenu(actionHandler: @escaping (String) -> Void) -> UIMenu {
        let reportAction = UIAction(title: "檢舉", image: UIImage(systemName: "exclamationmark.bubble")) { _ in
            actionHandler("檢舉")
        }

        let blockAction = UIAction(title: "封鎖", image: UIImage(systemName: "hand.raised")) { _ in
            actionHandler("封鎖")
        }

        return UIMenu(title: "", children: [reportAction, blockAction])
    }
}

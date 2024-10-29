//
//  AlertKitManager.swift
//  MindReader
//
//  Created by J oyce on 2024/10/9.
//

import Foundation
import AlertKit
import UIKit

class AlertKitManager {

    static func presentSuccessAlert(in viewController: UIViewController, title: String) {
        AlertKitAPI.present(
            title: title,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }

    static func presentErrorAlert(in viewController: UIViewController, title: String) {
        AlertKitAPI.present(
            title: title,
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }

    static func presentHeartAlert(in viewController: UIViewController, title: String) {
        AlertKitAPI.present(
            title: title,
            icon: .heart,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
}

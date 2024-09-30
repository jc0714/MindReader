//
//  AppDelegate.swift
//  MindReader
//
//  Created by J oyce on 2024/9/11.
//

import UIKit
import FirebaseCore
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        UserDefaults.standard.removeObject(forKey: "ForumVC_selectedTag")
        UserDefaults.standard.removeObject(forKey: "MyPostVC_selectedTag")
//        IQKeyboardManager.shared.keyboardDistanceFromTextField = -10

//        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")

        window = UIWindow(frame: UIScreen.main.bounds)

        // 檢查用戶登入狀態
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")

        let rootViewController: UIViewController
        if isLoggedIn {
            // 用戶已登入，進入 HomeVC
            rootViewController = HomeVC()
        } else {
            // 用戶未登入，呈現登入頁
            rootViewController = LoginVC()
        }

        // 創建 UINavigationController 並設置為 rootViewController
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController

        // 顯示視窗
        window?.makeKeyAndVisible()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

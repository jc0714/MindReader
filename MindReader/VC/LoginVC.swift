//
//  LoginVC.swift
//  MindReader
//
//  Created by J oyce on 2024/9/26.
//

import Foundation
import UIKit
import AuthenticationServices
import Firebase

class LoginVC: UIViewController, ASAuthorizationControllerPresentationContextProviding {

    let appleSignInButton = ASAuthorizationAppleIDButton()
    private let firebaseService = FirestoreService()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        // 設置背景顏色
        setupUI()
        // 配置蘋果登入按鈕
        configureAppleSignInButton()
    }

    private func setupUI() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.milkYellow.cgColor, UIColor.pink3.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureAppleSignInButton() {
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(appleSignInButton)

        if #available(iOS 13.0, *) {
            appleSignInButton.isHidden = false
            appleSignInButton.addTarget(self, action: #selector(pressSignInWithAppleButton), for: .touchUpInside)
        } else {
            appleSignInButton.isHidden = true
        }

        // 設置按鈕在背景視圖的中心
        NSLayoutConstraint.activate([
            appleSignInButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            appleSignInButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc private func pressSignInWithAppleButton() {
        let authorizationAppleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
        authorizationAppleIDRequest.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [authorizationAppleIDRequest])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginVC: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            print("user: \(appleIDCredential.user)")
            print("fullName: \(String(describing: appleIDCredential.fullName))")
            print("Email: \(String(describing: appleIDCredential.email))")

            let fullName = "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")"
            let email = appleIDCredential.email
            let realUserStatus = appleIDCredential.realUserStatus.rawValue

            // 查詢 Firestore 以確認用戶是否已存在
            let usersCollection = Firestore.firestore().collection("Users")

            usersCollection.whereField("user", isEqualTo: userIdentifier).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error checking if user exists: \(error.localizedDescription)")
                    return
                }

                if let snapshot = snapshot, snapshot.documents.isEmpty {
                    // 用戶不存在
                    self.presentNameInputViewController(userIdentifier: userIdentifier, userFullName: fullName, email: email, realUserStatus: realUserStatus)
                    return
                } else {
                    // 用戶已經存在
                    if let document = snapshot?.documents.first {
                        let isDeleted = document.data()["isDeleted"] as? Bool ?? false

                        if isDeleted {
                            // 用戶已標記為刪除，創建新帳號

                            // 抓取舊的資料
                            let oldUserIdentifier = document.data()["appleUserIdentifier"] as? String ?? userIdentifier
                            let oldUserFullName = document.data()["appleUserFullName"] as? String ?? userIdentifier
                            let oldEmail = document.data()["email"] as? String ?? email

                            self.presentNameInputViewController(userIdentifier: oldUserIdentifier, userFullName: oldUserFullName, email: oldEmail, realUserStatus: realUserStatus)
                            return
                        } else {
                            // 用戶已經存在，使用現有帳號
                            let existingUserId = document.documentID
                            let chatRoomId = document.data()["chatRoomId"] as? String ?? ""
                            // 自行定義可改的名字
                            let userName = document.data()["userFullName"] as? String ?? ""
                            let appleUserIdentifier = document.data()["user"] as? String ?? ""
                            UserDefaults.standard.set(existingUserId, forKey: "userID")
                            UserDefaults.standard.set(chatRoomId, forKey: "chatRoomId")
                            UserDefaults.standard.set(userName, forKey: "userLastName")
                            UserDefaults.standard.set(appleUserIdentifier, forKey: "appleUserIdentifier")
                            print("User already exists in Firestore. UserId and chatRoomId saved to UserDefaults.")

                            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                            UserDefaults.standard.synchronize()

                            // 跳轉到 TabBarController
                            self.navigateToMainTabBarController()
                        }
                    }
                }
            }
        }
    }

    private func presentNameInputViewController(userIdentifier: String, userFullName: String?, email: String?, realUserStatus: Int) {
        let nameInputVC = WelcomeVC()
        nameInputVC.onNameEntered = { [weak self] name in
            guard let self = self else { return }
            self.firebaseService.saveUserInfoToFirestore(appleUserIdentifier: userIdentifier, appleUserFullName: userFullName, userFullName: name, email: email, realUserStatus: realUserStatus)
            UserDefaults.standard.set(name, forKey: "userLastName")
            UserDefaults.standard.set(userIdentifier, forKey: "appleUserIdentifier")

            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.synchronize()

            self.navigateToMainTabBarController()
        }
        nameInputVC.modalPresentationStyle = .fullScreen
        // 顯示名稱輸入頁面
        self.present(nameInputVC, animated: true, completion: nil)

    }

    private func navigateToMainTabBarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("找不到 MainTabBarController")
            return
        }
        UIApplication.shared.windows.first?.rootViewController = tabBarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("didCompleteWithError: \(error.localizedDescription)")
    }
}

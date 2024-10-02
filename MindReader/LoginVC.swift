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
        self.view.backgroundColor = .white // 確保背景是白色

        // 配置蘋果登入按鈕
        configureAppleSignInButton()
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
//            let fullName = appleIDCredential.fullName?.description
            let email = appleIDCredential.email
            let realUserStatus = appleIDCredential.realUserStatus.rawValue

            let dispatchGroup = DispatchGroup()  // 用於追蹤所有操作的完成狀態

            // 查詢 Firestore 以確認用戶是否已存在
            let usersCollection = Firestore.firestore().collection("Users")

            dispatchGroup.enter()  // 開始一個異步操作
            usersCollection.whereField("user", isEqualTo: userIdentifier).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error checking if user exists: \(error.localizedDescription)")
                    dispatchGroup.leave()  // 異步操作完成
                    return
                }

                if let snapshot = snapshot, snapshot.documents.isEmpty {
                    // 用戶不存在
                    self.firebaseService.saveUserInfoToFirestore(appleUserIdentifier: userIdentifier, appleUserFullName: fullName, email: email, realUserStatus: realUserStatus)
                    UserDefaults.standard.set(fullName, forKey: "appleUserFullName")
                    UserDefaults.standard.set(fullName, forKey: "userLastName")
                    UserDefaults.standard.set(userIdentifier, forKey: "appleUserIdentifier")
                } else {
                    // 用戶已經存在
                    if let document = snapshot?.documents.first {
                        let existingUserId = document.documentID
                        let chatRoomId = document.data()["chatRoomId"] as? String ?? ""
                        UserDefaults.standard.set(existingUserId, forKey: "userID")
                        UserDefaults.standard.set(chatRoomId, forKey: "chatRoomId")
                        print("User already exists in Firestore. UserId and chatRoomId saved to UserDefaults.")
                    }
                }

                dispatchGroup.leave()  // 異步操作完成
            }

            // 監聽所有異步操作是否完成
            dispatchGroup.notify(queue: .main) {
                // 保存登入狀態並跳轉到主頁面
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()

                // 跳轉到 TabBarController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
                    print("無法找到 MainTabBarController")
                    return
                }
                UIApplication.shared.windows.first?.rootViewController = tabBarController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("didCompleteWithError: \(error.localizedDescription)")
    }
}

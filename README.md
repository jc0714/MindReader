![App Screenshot](https://drive.google.com/uc?export=view&id=1SoPOGJQWi3vQ0LaDWcVSxRw-viaz9A07)

<div align="center">

![Platform](https://img.shields.io/badge/platform-iOS-blue)
![Release](https://img.shields.io/badge/release-v1.1.2-brightgreen)
![Language](https://img.shields.io/badge/language-Swift-orange)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

</div>

# MindReader - 您的日常好朋友

歡迎來到 **"MindReader 人性翻譯機"**，這款 app 可以幫您分析訊息、提供推薦回覆還能製作早安圖☀️！為您帶來聊天靈感。還有即時回覆的阿雲聊天室、交流板，快來挖掘聊天靈感吧～

[![Download on the App Store](https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg)](https://apps.apple.com/app/id6692625322)

## Features

### 訊息分析

人性翻譯機接受兩種輸入形式，訊息截圖和文字輸入，系統立即分析三種可能含義和三個推薦回覆，幫您節省思考時間。

### 製作早安圖

提供多張高畫質風景照，可以將訊息製作成個性化早安圖，收藏或分享給朋友，讓聊天變得有趣又恨好玩。

### 即時聊天室

阿雲聊天室隨時都在線！歡迎您分享生活點滴，阿雲會立即回覆給予滿滿支持。

### 交流版

可以與其他用戶互動，選擇自己有興趣的類別，留言加入討論。

### 靈活發文格式

支援不同發文格式，包括文字、圖片內容，發文時可以根據當下心情選擇最適合的頭貼搭配。

### 專屬相片牆

收藏你的所有早安圖，未來也可以回來相簿找找聊天靈感。

### 貼文管理

檢視、刪除或分享自己的貼文，分享時貼文將以圖像形式呈現。

### 變換淺色/ 深色模式

根據手機設定自動切換淺色或深色模式，提升視覺體驗。

## How to Use

1. **輸入或上傳**：輸入文字到翻譯機或上傳截圖，點擊「翻譯」按鈕進行分析。
2. **選擇回覆**：根據翻譯結果，系統會提供三種回覆選擇，並可一鍵複製。
3. **進行互動**：你可以在阿雲聊天室或交流板上發表貼文，與他人互動。
4. **創作早安圖**：將訊息轉換成個性化的早安圖，並展示於相片牆上。
5. **管理貼文**：在自己的貼文頁上查看過去的貼文，並選擇刪除或分享。

## Techniques

- **資料存取**：使用 Firebase Firestore 作為後端資料存儲服務，提供即時同步和安全的雲端管理。
- **OpenAI API 整合**：結合 OpenAI API 提供訊息分析及推薦回覆。
- **Vision**：透過 Vision 進行文字辨識。

## Libraries

- [Firebase](https://github.com/firebase/firebase-ios-sdk)
- [AlertKit](https://github.com/sparrowcode/AlertKit)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager)
- [SwiftLint](https://github.com/realm/SwiftLint)
- [Lottie](https://github.com/airbnb/lottie-ios)

## Requirements

- iOS 設備運行 iOS 17.0

## Installation

1. clone 這個專案到 local：
    
    ```bash
    git clone https://github.com/jc0714/MindReader.git
    ```
    
2. 使用 Xcode 打開專案。
3. 生成 `GoogleService-Info.plist`
    1. 前往 Firebase Console，登入並創建一個新專案。
    2. 在專案中添加 iOS 應用，輸入 bundle identifier。
    3. 下載生成的 `GoogleService-Info.plist` 文件。
    4. 將該文件拖入 Xcode 專案的根目錄中。
4. 加入 OpenAI API key。可寄信至 [0714joyce@gmail.com](mailto:0714joyce@gmail.com)，我可以提供給您。
5. 在你的 iOS 設備或模擬器上運行應用程式。

## Feedback and Support

如果您對 **MindReader** 應用程式有任何建議、回饋或問題，歡迎聯絡 0714joyce@gmail.com，謝謝！

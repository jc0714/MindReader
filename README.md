![App Screenshot](https://drive.google.com/uc?export=view&id=1SoPOGJQWi3vQ0LaDWcVSxRw-viaz9A07)

![Platform](https://img.shields.io/badge/platform-iOS-blue)
![Release](https://img.shields.io/badge/release-v1.1.2-brightgreen)
![Language](https://img.shields.io/badge/language-Swift-orange)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

# MindReader - 為您帶來聊天靈感

歡迎來到 **"MindReader 人性翻譯機"**，這款 app 可以幫您分析訊息、提供推薦回覆還能製作早安圖☀️！為您帶來滿滿的聊天靈感，還有即時回覆的阿雲聊天室、交流板，一起把聊天變好玩吧～

[![Download on the App Store](https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg)](https://apps.apple.com/app/id6692625322)

## 功能

### 訊息分析

人性翻譯機接受兩種輸入形式，訊息截圖和文字輸入，系統立即分析三種可能含義和三個推薦回覆，幫您節省思考時間。

### 製作早安圖

提供多張高畫質風景照，可以將訊息製作成個性化早安圖，收藏或分享給朋友，讓聊天變得有趣又好玩。

### 即時聊天室

阿雲聊天室隨時都在線！歡迎您分享生活點滴，阿雲會立即回覆給予滿滿支持。

![IMG_3504](https://github.com/user-attachments/assets/c7e693f2-d473-4bea-b425-d62d636a563c)
![IMG_3507](https://github.com/user-attachments/assets/df922486-da53-4245-a9ba-445d8202aece)
![IMG_3506](https://github.com/user-attachments/assets/afcef39e-0371-49ff-8fca-3b29432c5d48)

### 交流版

可以與其他用戶互動，選擇自己有興趣的類別，留言加入討論。

### 靈活發文格式

支援不同發文格式，包括文字、圖片內容，發文時可以根據當下心情選擇最適合的頭貼搭配。

### 專屬相片牆

收藏你的所有早安圖，未來也可以回來相簿找找聊天靈感。

![IMG_3511](https://github.com/user-attachments/assets/f2364dbb-d199-460c-b230-d9d32758c6d8)
![IMG_3510](https://github.com/user-attachments/assets/15d7db70-bfe2-4684-88ca-b0c8083b7a7d)
![IMG_3509](https://github.com/user-attachments/assets/e51220c7-8f15-40d8-8567-7b31b686e694)

### 貼文管理

檢視、刪除或分享自己的貼文，分享時貼文將以圖像形式呈現。

### 變換淺色/ 深色模式

根據手機設定自動切換淺色或深色模式，提升視覺體驗。

## 如何使用

- **使用翻譯機**：輸入文字到翻譯機或上傳截圖，點擊「開始分析」進行分析。
- **按下即複製**：會分析出三種可能含義並提供三句推薦回覆，一鍵複製還可以搭配風景照製作早安圖。
- **即時聊天室**：生活大小事都可以來跟阿雲聊聊，阿雲隨時都在，一定馬上回覆。
- **交流版**：可以跟其他用戶互動，加入不同話題的討論，包括：友情、愛情、日常等等。
- **管理貼文**：查看自己的貼文，可以選擇刪除或以圖片形式分享。
- **專屬相簿**：喜歡排版的大家一定要來相簿頁玩玩，設計專屬風格的早安圖相簿。
- **每日鼓勵小語**：有兩款大小的 Widget 可以加到桌面上，每天接收驚喜早安圖。

## 技術

- **資料存取**：使用 Firebase Firestore 作為後端資料存儲服務，提供即時同步和安全的雲端管理。
- **OpenAI API 整合**：結合 OpenAI API 提供訊息分析及推薦回覆。
- **Vision**：透過 Vision 進行文字辨識。

## 運用套件

- [Firebase](https://github.com/firebase/firebase-ios-sdk)
- [AlertKit](https://github.com/sparrowcode/AlertKit)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager)
- [SwiftLint](https://github.com/realm/SwiftLint)
- [Lottie](https://github.com/airbnb/lottie-ios)

## 設備要求

- iOS 設備運行 iOS 17.0

## 安裝方式

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

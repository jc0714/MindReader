# MindReader - iOS App

歡迎來到 **"MindReader"**，這款 app 可以幫您分析訊息、提供推薦回覆還能製作早安圖☀️！為您帶來聊天靈感。還有即時回覆的阿雲聊天室、交流板，快來挖掘聊天靈感吧～

## Features

### 1. **翻譯機**

- **訊息輸入**：輸入訊息到指定的文字欄，按下「翻譯」按鈕提交訊息，進行分析。
- **截圖翻譯**：支援截圖上傳，系統會自動分析圖片中的文字，提供翻譯及三個推薦回覆。
- **推薦回覆**：系統會根據分析結果提供三種不同的推薦回覆，供用戶選擇。
- **回覆複製**：選擇回覆後，點擊即可複製到剪貼板，方便快速使用。

### 2. **阿雲聊天室**

- **溫暖的對話空間**：阿雲聊天室隨時為你提供一個交流的場所，無論喜怒哀樂，總有人願意傾聽並給予支持。
- **即時互動**：你可以與其他用戶進行即時對話，分享生活中的點滴和感受。

### 3. **交流版**

- **主題貼文**：你可以在交流板上發表各種不同主題的貼文，與他人分享想法和心情。
- **標籤過濾**：利用標籤功能過濾貼文內容，幫助你快速找到感興趣的話題。

### 4. **早安圖相片牆**

- **製作個性化早安圖**：將每日的訊息或回覆轉換成溫馨的早安圖，並展示在你的專屬相片牆上。
- **相片收藏**：創建的早安圖可以收藏並隨時查看，分享給家人和朋友。

### 5. **貼文管理**

- **瀏覽與管理貼文**：在自己的貼文頁上，你可以檢視並管理過去發表的所有貼文。
- **刪除與分享**：你可以輕鬆刪除貼文或將其分享給他人，分享時會以圖像形式呈現。

## How to Use

1. **輸入或上傳**：輸入文字到翻譯機或上傳截圖，點擊「翻譯」按鈕進行分析。
2. **選擇回覆**：根據翻譯結果，系統會提供三種回覆選擇，並可一鍵複製。
3. **進行互動**：你可以在阿雲聊天室或交流板上發表貼文，與他人互動。
4. **創作早安圖**：將訊息轉換成個性化的早安圖，並展示於相片牆上。
5. **管理貼文**：在自己的貼文頁上查看過去的貼文，並選擇刪除或分享。

### Techniques (技術)

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
3. 如何生成 Firebase `GoogleService-Info.plist`
    1. 前往 Firebase Console，登錄並創建一個新專案。
    2. 在專案中添加 iOS 應用，輸入 bundle identifier。
    3. 下載生成的 `GoogleService-Info.plist` 文件。
    4. 將該文件拖入 Xcode 專案的根目錄中。
4. 加入 OpenAI API key。若有需要可寄信至 [0714joyce@gmail.com](mailto:0714joyce@gmail.com)，我可以提供給您。
5. 在你的 iOS 設備或模擬器上編譯並運行應用程式。

## Feedback and Support

如果您對 **MindReader** 應用程式有任何建議、回饋或問題，歡迎聯絡 0714joyce@gmail.com，謝謝！

//
//  EncouragementService.swift
//  MindReader
//
//  Created by J oyce on 2024/10/13.
//

import Foundation
import Firebase
import FirebaseFirestore

class EncouragementService {

    static let documentIDMap: [Int: String] = [
        1: "gMyAUg8kw0i3rkjiiK3e",  // 星期日
        2: "76gNPWk49uakrmN1FBPj",  // 星期一
        3: "LX0gzXKLJ2zn8nEUG346",  // 星期二
        4: "amSwVjsS8446Ot9vLONv",  // 星期三
        5: "5gpxJwezEirG8U4LIXMf",  // 星期四
        6: "5ld9RQQS3pRGpjDGjLNd",  // 星期五
        7: "3fjilVR8XPiDefHhLhaV"  // 星期六
    ]

    static func dailyEncouragement(for date: Date) async -> String {
        let dayOfWeek = Calendar.current.component(.weekday, from: date)

        // 檢查當天的資料是否已緩存
        let lastFetchDate = UserDefaults.standard.object(forKey: "lastFetchDate") as? Date ?? Date.distantPast
        let today = Calendar.current.startOfDay(for: date)

        if lastFetchDate < today {
            // 如果今天還沒有抓取資料，從 Firebase 抓取
            let db = Firestore.firestore()
            print(lastFetchDate)
            print(today)
            print(dayOfWeek)
            let documentRef = db.collection("WidgetDB").document("\(documentIDMap[dayOfWeek] ?? "EBFrMoxIGSjfXEGK7RpR")")

            do {
                let document = try await documentRef.getDocument()
                if let messages = document.data()?["messages"] as? [String] {
                    // 隨機選擇一條鼓勵語
                    let randomMessage = messages.randomElement() ?? "日日是好日，今天也會順利的🍀"

                    // 緩存抓取的數據和日期
                    UserDefaults.standard.set(messages, forKey: "cachedMessages")
                    UserDefaults.standard.set(today, forKey: "lastFetchDate")

                    return randomMessage
                }
            } catch {
                print("Error fetching document: \(error)")
            }
        }

        // 如果已有緩存，從本地讀取隨機一條
        let cachedMessages = UserDefaults.standard.array(forKey: "cachedMessages") as? [String] ?? []
        return cachedMessages.randomElement() ?? "日日是好日，今天也會順利的🍀"
    }
}

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
        1: "gMyAUg8kw0i3rkjiiK3e",  // 日
        2: "76gNPWk49uakrmN1FBPj",  // 一
        3: "LX0gzXKLJ2zn8nEUG346",  // 二
        4: "amSwVjsS8446Ot9vLONv",  // 三
        5: "5gpxJwezEirG8U4LIXMf",  // 四
        6: "5ld9RQQS3pRGpjDGjLNd",  // 五
        7: "3fjilVR8XPiDefHhLhaV"  // 六
    ]

    static func dailyEncouragement(for date: Date) async -> String {
        let dayOfWeek = Calendar.current.component(.weekday, from: date)

        let lastFetchDate = UserDefaults.standard.object(forKey: "lastFetchDate") as? Date ?? Date.distantPast
        let today = Calendar.current.startOfDay(for: date)

        if lastFetchDate < today {
            let db = Firestore.firestore()
            let documentRef = db.collection("WidgetDB").document("\(documentIDMap[dayOfWeek] ?? "EBFrMoxIGSjfXEGK7RpR")")

            do {
                let document = try await documentRef.getDocument()
                if let messages = document.data()?["messages"] as? [String] {
                    let randomMessage = messages.randomElement() ?? "日日是好日，今天也會順利的🍀"

                    UserDefaults.standard.set(messages, forKey: "cachedMessages")
                    UserDefaults.standard.set(today, forKey: "lastFetchDate")

                    return randomMessage
                }
            } catch {
                print("Error fetching document: \(error)")
            }
        }

        let cachedMessages = UserDefaults.standard.array(forKey: "cachedMessages") as? [String] ?? []
        return cachedMessages.randomElement() ?? "日日是好日，今天也會順利的🍀"
    }
}

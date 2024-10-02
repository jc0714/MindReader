//
//  DateFormatterExtension.swift
//  MindReader
//
//  Created by J oyce on 2024/9/24.
//

import Foundation

extension DateFormatter {
    static let sharedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 可調整為"yyyy-MM-ddHH:mm:ss"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }()

    static let yyyyMMddFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }()

//    static let ChatFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone.current
//        formatter.locale = Locale.current
//
//        formatter.dateFormat = "E, MM/dd"
//
//        return formatter
//    }()

    static let chatFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }()

    static func formatChatDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            chatFormatter.dateFormat = "今天"
        } else if calendar.isDateInYesterday(date) {
            chatFormatter.dateFormat = "昨天"
        } else {
            chatFormatter.dateFormat = "E, MM/dd"
        }

        return chatFormatter.string(from: date)
    }

}

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
        formatter.dateFormat = "HH:mm"
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

extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: self, to: now)

        if let year = components.year, year >= 1 {
            return "\(year) 年前"
        } else if let month = components.month, month >= 1 {
            return "\(month) 個月前"
        } else if let week = components.weekOfYear, week >= 1 {
            return "\(week) 週前"
        } else if let day = components.day, day >= 1 {
            return "\(day) 天前"
        } else if let hour = components.hour, hour >= 1 {
            return "\(hour) 小時前"
        } else if let minute = components.minute, minute >= 1 {
            return "\(minute) 分鐘前"
        } else {
            return "剛剛"
        }
    }
}

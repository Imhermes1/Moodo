//
//  DateFormatting.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import Foundation

// MARK: - Centralized Date Formatting Utilities

struct DateFormatting {
    
    // MARK: - Cached Formatters (Performance Optimization)
    
    private static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private static let mediumDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let dayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, HH:mm"
        return formatter
    }()
    
    private static let compactFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.M.d, h:mm a"
        return formatter
    }()
    
    // MARK: - Public Functions
    
    static func formatCreationDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "today"
        } else if calendar.isDateInYesterday(date) {
            return "yesterday"
        } else {
            let daysAgo = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            if daysAgo <= 7 {
                return "\(daysAgo) days ago"
            } else {
                return shortDateFormatter.string(from: date)
            }
        }
    }
    
    static func formatReminderTime(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today \(formatter.string(from: date))"
        }
        
        let daysUntil = calendar.dateComponents([.day], from: now, to: date).day ?? 0
        if daysUntil == 1 {
            return "Tomorrow \(shortTimeFormatter.string(from: date))"
        } else if daysUntil <= 7 && daysUntil > 0 {
            return dayTimeFormatter.string(from: date)
        } else if daysUntil < 0 {
            return "Overdue \(shortDateFormatter.string(from: date))"
        } else {
            return shortDateFormatter.string(from: date) + " " + shortTimeFormatter.string(from: date)
        }
    }
    
    static func formatFullReminderTime(_ date: Date) -> String {
        return mediumDateTimeFormatter.string(from: date)
    }
    
    static func formatFullDeadlineTime(_ date: Date) -> String {
        return mediumDateTimeFormatter.string(from: date)
    }
    
    static func formatReminderShort(_ date: Date) -> String {
        return compactFormatter.string(from: date)
    }
    
    static func isDeadlineOverdue(_ date: Date) -> Bool {
        return date < Date()
    }
} 

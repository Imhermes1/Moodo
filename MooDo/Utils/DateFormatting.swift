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
        formatter.dateFormat = "d/M/yy, h:mm a"
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
        let calendar = Calendar.current
        let now = Date()
        
        // Get start of this week (Sunday)
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? now
        
        // Check if the date is within this week
        if date >= startOfWeek && date <= endOfWeek {
            // This week - show day name and time
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE" // Full day name
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a" // 5:00 PM format
            
            let dayName = dayFormatter.string(from: date)
            let timeString = timeFormatter.string(from: date)
            
            // Remove minutes if it's exactly on the hour (5:00 PM -> 5pm)
            let cleanTimeString = timeString.replacingOccurrences(of: ":00", with: "").lowercased()
            
            // Check if it's today or tomorrow
            if calendar.isDateInToday(date) {
                return "Today \(cleanTimeString)"
            } else if calendar.isDateInTomorrow(date) {
                return "Tomorrow \(cleanTimeString)"
            } else {
                return "\(dayName) \(cleanTimeString)"
            }
        } else if date < now {
            // Overdue
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"
            return "Overdue \(dateFormatter.string(from: date))"
        } else {
            // Beyond this week - show date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM" // 15 Aug format
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a" // 5:00 PM format
            
            let dateString = dateFormatter.string(from: date)
            let timeString = timeFormatter.string(from: date)
            
            return "\(dateString) \(timeString)"
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

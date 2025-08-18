//
//  ClickableTextView.swift
//  Moodo
//
//  Created by Assistant on 11/8/2025.
//

import SwiftUI

struct ClickableTextView: View {
    let text: String
    let font: Font
    let color: Color
    
    init(_ text: String, font: Font = .body, color: Color = .primary) {
        self.text = text
        self.font = font
        self.color = color
    }
    
    var body: some View {
        let segments = parseText(text)
        
        HStack(spacing: 0) {
            ForEach(segments.indices, id: \.self) { index in
                let segment = segments[index]
                
                switch segment.type {
                case .plain:
                    Text(segment.text)
                        .font(font)
                        .foregroundColor(color)
                case .phone:
                    if let url = URL(string: "tel:\(segment.text.replacingOccurrences(of: " ", with: ""))") {
                        Link(segment.text, destination: url)
                            .font(font)
                            .foregroundColor(.blue)
                    } else {
                        Text(segment.text)
                            .font(font)
                            .foregroundColor(color)
                    }
                case .email:
                    if let url = URL(string: "mailto:\(segment.text)") {
                        Link(segment.text, destination: url)
                            .font(font)
                            .foregroundColor(.blue)
                    } else {
                        Text(segment.text)
                            .font(font)
                            .foregroundColor(color)
                    }
                case .url:
                    if let url = URL(string: segment.text.hasPrefix("http") ? segment.text : "https://\(segment.text)") {
                        Link(segment.displayText ?? segment.text, destination: url)
                            .font(font)
                            .foregroundColor(.blue)
                    } else {
                        Text(segment.text)
                            .font(font)
                            .foregroundColor(color)
                    }
                }
            }
        }
    }
    
    private struct TextSegment {
        enum SegmentType {
            case plain
            case phone
            case email
            case url
        }
        
        let type: SegmentType
        let text: String
        let displayText: String?
    }
    
    private func parseText(_ text: String) -> [TextSegment] {
        var segments: [TextSegment] = []
        var currentText = text
        
        // Clean up any existing markdown phone/email links first
        currentText = currentText.replacingOccurrences(
            of: "\\[([^\\]]+)\\]\\(tel:[^\\)]+\\)",
            with: "$1",
            options: .regularExpression
        )
        currentText = currentText.replacingOccurrences(
            of: "\\[([^\\]]+)\\]\\(mailto:[^\\)]+\\)",
            with: "$1",
            options: .regularExpression
        )
        
        // Patterns for detection
        let phonePattern = "\\b((?:\\+61|0)[2-9]\\d{8})\\b"
        let emailPattern = "\\b([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,})\\b"
        let urlPattern = "\\b((?:https?://)?(?:www\\.)?[a-zA-Z0-9][a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9][a-zA-Z0-9-]+)+(?:/[^\\s]*)?)"
        
        // Combine all patterns
        let combinedPattern = "(\(phonePattern))|(\(emailPattern))|(\(urlPattern))"
        
        guard let regex = try? NSRegularExpression(pattern: combinedPattern, options: []) else {
            return [TextSegment(type: .plain, text: text, displayText: nil)]
        }
        
        let matches = regex.matches(in: currentText, options: [], range: NSRange(location: 0, length: currentText.count))
        var lastIndex = 0
        
        for match in matches {
            let matchRange = match.range
            
            // Add plain text before the match
            if matchRange.location > lastIndex {
                let plainRange = NSRange(location: lastIndex, length: matchRange.location - lastIndex)
                let plainText = (currentText as NSString).substring(with: plainRange)
                segments.append(TextSegment(type: .plain, text: plainText, displayText: nil))
            }
            
            // Determine match type and add appropriate segment
            let matchedText = (currentText as NSString).substring(with: matchRange)
            
            if match.range(at: 1).location != NSNotFound {
                // Phone number
                segments.append(TextSegment(type: .phone, text: matchedText, displayText: nil))
            } else if match.range(at: 3).location != NSNotFound {
                // Email
                segments.append(TextSegment(type: .email, text: matchedText, displayText: nil))
            } else if match.range(at: 5).location != NSNotFound {
                // URL
                let displayText = matchedText
                    .replacingOccurrences(of: "https://", with: "")
                    .replacingOccurrences(of: "http://", with: "")
                    .replacingOccurrences(of: "www.", with: "")
                segments.append(TextSegment(type: .url, text: matchedText, displayText: displayText))
            }
            
            lastIndex = matchRange.location + matchRange.length
        }
        
        // Add remaining plain text
        if lastIndex < currentText.count {
            let remainingText = (currentText as NSString).substring(from: lastIndex)
            segments.append(TextSegment(type: .plain, text: remainingText, displayText: nil))
        }
        
        // If no segments were created, return the whole text as plain
        if segments.isEmpty {
            segments.append(TextSegment(type: .plain, text: text, displayText: nil))
        }
        
        return segments
    }
}

struct ClickableTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            ClickableTextView("Call me at 0423633740")
            ClickableTextView("Email: test@example.com")
            ClickableTextView("Visit https://www.apple.com for more info")
            ClickableTextView("Mixed: Call 0423633740 or email test@example.com")
        }
        .padding()
    }
}
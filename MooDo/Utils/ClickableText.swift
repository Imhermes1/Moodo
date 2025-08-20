//
//  ClickableText.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI
import Foundation

// MARK: - Clickable Text Component for URLs in Task Descriptions

struct ClickableText: View {
    let text: String
    let font: Font
    let color: Color
    let linkColor: Color
    let lineLimit: Int?
    
    init(text: String, font: Font = .body, color: Color = .white, linkColor: Color = .blue, lineLimit: Int? = nil) {
        self.text = text
        self.font = font
        self.color = color
        self.linkColor = linkColor
        self.lineLimit = lineLimit
    }
    
    var body: some View {
        if hasLinks(in: text) {
            ClickableTextView(
                text: text,
                font: font,
                color: color,
                linkColor: linkColor,
                lineLimit: lineLimit
            )
        } else {
            Text(text)
                .font(font)
                .foregroundColor(color)
                .lineLimit(lineLimit)
        }
    }
    
    private func hasLinks(in text: String) -> Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = detector?.matches(in: text, options: [], range: range) ?? []
        return !matches.isEmpty
    }
}

// MARK: - UIViewRepresentable for Clickable Links

struct ClickableTextView: UIViewRepresentable {
    let text: String
    let font: Font
    let color: Color
    let linkColor: Color
    let lineLimit: Int?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.dataDetectorTypes = [.link, .phoneNumber]
        textView.linkTextAttributes = [
            .foregroundColor: UIColor(linkColor),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        // Configure text
        let attributedString = NSMutableAttributedString(string: text)
        
        // Apply base styling
        let range = NSRange(location: 0, length: text.count)
        attributedString.addAttribute(.foregroundColor, value: UIColor(color), range: range)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: getFontSize(for: font)), range: range)
        
        // Find and style links and phone numbers
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult.CheckingType.phoneNumber.rawValue) {
            let matches = detector.matches(in: text, options: [], range: range)
            for match in matches {
                attributedString.addAttribute(.foregroundColor, value: UIColor(linkColor), range: match.range)
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range)
            }
        }
        
        textView.attributedText = attributedString
        
        if let lineLimit = lineLimit {
            textView.textContainer.maximumNumberOfLines = lineLimit
            textView.textContainer.lineBreakMode = .byTruncatingTail
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update if needed
    }
    
    private func getFontSize(for font: Font) -> CGFloat {
        switch font {
        case .caption, .caption2:
            return 12
        case .footnote:
            return 13
        case .subheadline:
            return 15
        case .callout:
            return 16
        case .body:
            return 17
        case .headline:
            return 17
        case .title3:
            return 20
        case .title2:
            return 22
        case .title:
            return 28
        case .largeTitle:
            return 34
        default:
            return 17
        }
    }
}

// MARK: - Performance-Optimized Task Description View

struct TaskDescriptionView: View {
    let description: String
    let font: Font
    let color: Color
    let lineLimit: Int?
    
    init(_ description: String, font: Font = .caption, color: Color = .white.opacity(0.7), lineLimit: Int? = nil) {
        self.description = description
        self.font = font
        self.color = color
        self.lineLimit = lineLimit
    }
    
    var body: some View {
        ClickableText(
            text: description,
            font: font,
            color: color,
            linkColor: .blue.opacity(0.8),
            lineLimit: lineLimit
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
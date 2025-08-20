//
//  AppleNotesEditor.swift
//  MooDo
//
//  Rich text editor with Apple Notes-style functionality
//

import SwiftUI
import UIKit
import PhotosUI

// MARK: - Text Formatting Controller
class TextFormattingController: ObservableObject {
    weak var textView: UITextView?
    
    func applyBold() {
        guard let textView = textView else { return }
        toggleFontTrait(textView, trait: .traitBold)
    }
    
    func applyItalic() {
        guard let textView = textView else { return }
        toggleFontTrait(textView, trait: .traitItalic)
    }
    
    func applyUnderline() {
        guard let textView = textView else { return }
        toggleAttribute(textView, attribute: .underlineStyle, value: NSUnderlineStyle.single.rawValue)
    }
    
    func applyTitle() {
        guard let textView = textView else { return }
        applyParagraphStyle(textView, font: UIFont.systemFont(ofSize: 28, weight: .bold))
    }
    
    func applyHeading() {
        guard let textView = textView else { return }
        applyParagraphStyle(textView, font: UIFont.systemFont(ofSize: 22, weight: .semibold))
    }
    
    func applySubheading() {
        guard let textView = textView else { return }
        applyParagraphStyle(textView, font: UIFont.systemFont(ofSize: 20, weight: .medium))
    }
    
    func applyBody() {
        guard let textView = textView else { return }
        applyParagraphStyle(textView, font: UIFont.systemFont(ofSize: 17, weight: .regular))
    }
    
    func applyMonospaced() {
        guard let textView = textView else { return }
        let range = textView.selectedRange
        let fontSize = textView.font?.pointSize ?? 17
        
        if range.length > 0 {
            textView.textStorage.addAttribute(.font, value: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular), range: range)
        } else {
            textView.typingAttributes[.font] = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }
    }
    
    func insertBulletList() {
        guard let textView = textView else { return }
        insertLinePrefix(textView, prefix: "• ")
    }
    
    func insertNumberedList() {
        guard let textView = textView else { return }
        insertLinePrefix(textView, prefix: "1. ")
    }
    
    func insertChecklist() {
        guard let textView = textView else { return }
        insertLinePrefix(textView, prefix: "☐ ")
    }
    
    func insertImage(_ image: UIImage) {
        guard let textView = textView else { return }
        
        let attachment = NSTextAttachment()
        let maxWidth = textView.bounds.width - textView.textContainerInset.left - textView.textContainerInset.right - 16
        let scale = min(1.0, maxWidth / max(image.size.width, 1))
        
        if let cgImage = image.cgImage {
            attachment.image = UIImage(cgImage: cgImage, scale: 1.0/scale, orientation: image.imageOrientation)
        }
        
        let attributedImage = NSAttributedString(attachment: attachment)
        let mutableText = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
        mutableText.replaceCharacters(in: textView.selectedRange, with: attributedImage)
        
        textView.attributedText = mutableText
        textView.selectedRange = NSRange(location: textView.selectedRange.location + 1, length: 0)
    }
    
    // MARK: - Private Helper Methods
    
    private func toggleFontTrait(_ textView: UITextView, trait: UIFontDescriptor.SymbolicTraits) {
        let range = textView.selectedRange
        
        if range.length > 0 {
            textView.textStorage.enumerateAttribute(.font, in: range, options: []) { value, subrange, _ in
                let font = (value as? UIFont) ?? UIFont.systemFont(ofSize: 17)
                var traits = font.fontDescriptor.symbolicTraits
                
                if traits.contains(trait) {
                    traits.remove(trait)
                } else {
                    traits.insert(trait)
                }
                
                if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                    let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
                    textView.textStorage.addAttribute(.font, value: newFont, range: subrange)
                }
            }
        } else {
            let font = (textView.typingAttributes[.font] as? UIFont) ?? UIFont.systemFont(ofSize: 17)
            var traits = font.fontDescriptor.symbolicTraits
            
            if traits.contains(trait) {
                traits.remove(trait)
            } else {
                traits.insert(trait)
            }
            
            if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
                textView.typingAttributes[.font] = newFont
            }
        }
    }
    
    private func toggleAttribute(_ textView: UITextView, attribute: NSAttributedString.Key, value: Any) {
        let range = textView.selectedRange
        
        if range.length > 0 {
            var hasAttribute = false
            textView.textStorage.enumerateAttribute(attribute, in: range, options: []) { currentValue, _, stop in
                if currentValue != nil {
                    hasAttribute = true
                    stop.pointee = true
                }
            }
            
            if hasAttribute {
                textView.textStorage.removeAttribute(attribute, range: range)
            } else {
                textView.textStorage.addAttribute(attribute, value: value, range: range)
            }
        } else {
            if textView.typingAttributes[attribute] != nil {
                textView.typingAttributes[attribute] = nil
            } else {
                textView.typingAttributes[attribute] = value
            }
        }
    }
    
    private func applyParagraphStyle(_ textView: UITextView, font: UIFont) {
        let range = textView.selectedRange
        let text = textView.text as NSString
        let paragraphRange = text.paragraphRange(for: range)
        
        textView.textStorage.addAttribute(.font, value: font, range: paragraphRange)
    }
    
    private func insertLinePrefix(_ textView: UITextView, prefix: String) {
        let range = textView.selectedRange
        let text = textView.text as NSString
        let lineRange = text.lineRange(for: NSRange(location: range.location, length: 0))
        
        let mutableText = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
        mutableText.insert(NSAttributedString(string: prefix), at: lineRange.location)
        
        textView.attributedText = mutableText
        textView.selectedRange = NSRange(location: range.location + prefix.count, length: 0)
    }
}

// MARK: - AppleNotesEditor View
struct AppleNotesEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var isEditing: Bool
    let controller: TextFormattingController
    var placeholder: String = "Start writing..."
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        // Basic setup
        textView.backgroundColor = UIColor.systemBackground
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsEditingTextAttributes = true
        
        // Enable data detectors for links and phone numbers
        // Note: Data detectors only work when isEditable is false
        textView.dataDetectorTypes = [.link, .phoneNumber]
        textView.isUserInteractionEnabled = true
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        // Set default font and color
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = UIColor.label
        textView.typingAttributes = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.label
        ]
        
        // Content insets
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // Set initial text
        textView.attributedText = attributedText
        
        // Connect controller
        controller.textView = textView
        
        // Set delegate
        textView.delegate = context.coordinator
        
        // Add toolbar
        textView.inputAccessoryView = createToolbar(context: context)
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        // Only update if text actually changed to avoid cursor jumping
        if !textView.attributedText.isEqual(to: attributedText) {
            textView.attributedText = attributedText
        }
        
        // Update editable state - data detectors only work when not editable
        textView.isEditable = isEditing
        
        // Handle focus
        if isEditing && !textView.isFirstResponder {
            textView.becomeFirstResponder()
        } else if !isEditing && textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Toolbar Creation
    private func createToolbar(context: Context) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let boldButton = UIBarButtonItem(image: UIImage(systemName: "bold"), style: .plain, target: context.coordinator, action: #selector(Coordinator.boldTapped))
        let italicButton = UIBarButtonItem(image: UIImage(systemName: "italic"), style: .plain, target: context.coordinator, action: #selector(Coordinator.italicTapped))
        let underlineButton = UIBarButtonItem(image: UIImage(systemName: "underline"), style: .plain, target: context.coordinator, action: #selector(Coordinator.underlineTapped))
        
        let formatButton = UIBarButtonItem(image: UIImage(systemName: "textformat"), style: .plain, target: context.coordinator, action: #selector(Coordinator.formatTapped))
        
        let bulletButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: context.coordinator, action: #selector(Coordinator.bulletTapped))
        let checklistButton = UIBarButtonItem(image: UIImage(systemName: "checklist"), style: .plain, target: context.coordinator, action: #selector(Coordinator.checklistTapped))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))
        
        toolbar.items = [
            boldButton,
            italicButton,
            underlineButton,
            formatButton,
            bulletButton,
            checklistButton,
            flexSpace,
            doneButton
        ]
        
        return toolbar
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AppleNotesEditor
        
        init(_ parent: AppleNotesEditor) {
            self.parent = parent
        }
        
        // MARK: - Toolbar Actions
        @objc func boldTapped() {
            parent.controller.applyBold()
        }
        
        @objc func italicTapped() {
            parent.controller.applyItalic()
        }
        
        @objc func underlineTapped() {
            parent.controller.applyUnderline()
        }
        
        @objc func formatTapped() {
            // Show format menu
            guard let textView = parent.controller.textView else { return }
            
            let alertController = UIAlertController(title: "Format", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Title", style: .default) { _ in
                self.parent.controller.applyTitle()
            })
            alertController.addAction(UIAlertAction(title: "Heading", style: .default) { _ in
                self.parent.controller.applyHeading()
            })
            alertController.addAction(UIAlertAction(title: "Subheading", style: .default) { _ in
                self.parent.controller.applySubheading()
            })
            alertController.addAction(UIAlertAction(title: "Body", style: .default) { _ in
                self.parent.controller.applyBody()
            })
            alertController.addAction(UIAlertAction(title: "Monospaced", style: .default) { _ in
                self.parent.controller.applyMonospaced()
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alertController, animated: true)
            }
        }
        
        @objc func bulletTapped() {
            parent.controller.insertBulletList()
        }
        
        @objc func checklistTapped() {
            parent.controller.insertChecklist()
        }
        
        @objc func doneTapped() {
            parent.isEditing = false
        }
        
        // MARK: - UITextViewDelegate
        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isEditing = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isEditing = false
        }
        
        // Handle link and phone number taps
        @available(iOS 17.0, *)
        func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
            if case .link(let url) = textItem.content {
                // Handle both regular URLs and tel: URLs
                return UIAction { _ in
                    UIApplication.shared.open(url)
                }
            }
            return defaultAction
        }
        
        // Fallback for iOS 16 and earlier
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            // Open the URL (works for both http:// and tel:// URLs)
            UIApplication.shared.open(URL)
            return false
        }
    }
}

// MARK: - NSAttributedString Extension
extension NSAttributedString {
    func toRTFData() -> Data? {
        try? self.data(from: NSRange(location: 0, length: length), 
                      documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
    }
    
    static func fromRTFData(_ data: Data) -> NSAttributedString? {
        try? NSAttributedString(data: data, 
                                options: [.documentType: NSAttributedString.DocumentType.rtf], 
                                documentAttributes: nil)
    }
}
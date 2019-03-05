//
//  NSMutableAttributedString+.swift
//  FSNotes
//
//  Created by Oleksandr Glushchenko on 7/21/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

extension NSMutableAttributedString {
    public func unLoadImages(note: Note? = nil) -> NSMutableAttributedString {
        var offset = 0
        let content = self.mutableCopy() as? NSMutableAttributedString

        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.length)) { (value, range, _) in

            if let textAttachment = value as? NSTextAttachment,
                self.attribute(.todo, at: range.location, effectiveRange: nil) == nil {
                var path: String?
                var title: String?

                let filePathKey = NSAttributedStringKey(rawValue: "co.fluder.fsnotes.image.path")
                let titleKey = NSAttributedStringKey(rawValue: "co.fluder.fsnotes.image.title")

                if let note = note,
                    let components = textAttachment.fileWrapper?.filename?.components(separatedBy: "@::"),
                    components.count == 2 {

                    path = components.last
                    title = components.first

                    guard let unwrappedPath = path else { return }

                    let attachmentImageURL = URL(fileURLWithPath: unwrappedPath)
                    let mdImagePath = note.getMdImagePath(name: attachmentImageURL.lastPathComponent)
                    let currentImageURL = note.getImageUrl(imageName: mdImagePath)

                    if let currentURL = currentImageURL,
                        FileManager.default.fileExists(atPath: currentURL.path),
                        currentURL.fileSize == attachmentImageURL.fileSize {
                        path = mdImagePath
                    } else if let data = textAttachment.fileWrapper?.regularFileContents,
                        let fileName = ImagesProcessor.writeImage(data: data, note: note) {
                        path = note.getMdImagePath(name: fileName)
                    }

                } else if
                    let filePath = self.attribute(filePathKey, at: range.location, effectiveRange: nil) as? String {

                    path = filePath
                    title = self.attribute(titleKey, at: range.location, effectiveRange: nil) as? String
                } else if let note = note,
                    let imageData = textAttachment.fileWrapper?.regularFileContents,
                    let fileName = ImagesProcessor.writeImage(data: imageData, note: note) {

                    path = note.getMdImagePath(name: fileName)
                }

                let newRange = NSRange(location: range.location + offset, length: range.length)

                guard let unwrappedPath = path, unwrappedPath.count > 0 else { return }
                let unrappedTitle = title ?? ""

                if let pathEncoded = unwrappedPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {

                    content?.removeAttribute(.attachment, range: newRange)
                    content?.replaceCharacters(in: newRange, with: "![\(unrappedTitle)](\(pathEncoded))")
                    offset += 4 + unwrappedPath.count + unrappedTitle.count
                }
            }
        }

        return content!
    }

    public func unLoadCheckboxes() -> NSMutableAttributedString {
        var offset = 0
        let content = self.mutableCopy() as? NSMutableAttributedString

        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.length)) { (value, range, _) in
            if value != nil {
                let newRange = NSRange(location: range.location + offset, length: 1)

                guard range.length == 1,
                    let value = self.attribute(.todo, at: range.location, effectiveRange: nil) as? Int
                else { return }

                var gfm = "- [ ]"
                if value == 1 {
                    gfm = "- [x]"
                }
                content?.replaceCharacters(in: newRange, with: gfm)
                offset += 4
            }
        }

        return content!
    }

    #if os(OSX)
    public func loadCheckboxes() {
        while mutableString.contains("- [ ] ") {
            let range = mutableString.range(of: "- [ ] ")
            if length >= range.upperBound, let unChecked = AttributedBox.getUnChecked() {
                replaceCharacters(in: range, with: unChecked)
            }
        }

        while mutableString.contains("- [x] ") {
            let range = mutableString.range(of: "- [x] ")
            let parRange = mutableString.paragraphRange(for: range)

            if length >= range.upperBound, let checked = AttributedBox.getChecked() {

                let color = UserDataService.instance.isDark ? NSColor.white : NSColor.black
                addAttribute(.strikethroughColor, value: color, range: parRange)

                replaceCharacters(in: range, with: checked)
            }
        }
    }
    #endif
}

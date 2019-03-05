//
//  UserDefaultsManagement+.swift
//  FSNotesCore macOS
//
//  Created by Oleksandr Glushchenko on 10/25/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import Foundation
import MASShortcut

extension UserDefaultsManagement {
    private struct Constants {
        static let AppearanceTypeKey = "appearanceType"
        static let codeTheme = "codeTheme"
        static let NewNoteKeyModifier = "newNoteKeyModifier"
        static let NewNoteKeyCode = "newNoteKeyCode"
        static let SearchNoteKeyCode = "searchNoteKeyCode"
        static let SearchNoteKeyModifier = "searchNoteKeyModifier"
        static let StorageExtensionKey = "fileExtension"
    }

    static var appearanceType: AppearanceType {
        get {
            if let result = UserDefaults.standard.object(forKey: Constants.AppearanceTypeKey) as? Int {
                return AppearanceType(rawValue: result)!
            }

            if #available(OSX 10.14, *) {
                return AppearanceType.System
            } else {
                return AppearanceType.Custom
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.AppearanceTypeKey)
        }
    }

    static var storageExtension: String {
        get {
            if let storageExtension = UserDefaults.standard.object(forKey: Constants.StorageExtensionKey) as? String {
                return storageExtension
            } else {
                return "md"
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.StorageExtensionKey)
        }
    }

    static var newNoteShortcut: MASShortcut {
        get {
            let code = UserDefaults.standard.object(forKey: Constants.NewNoteKeyCode)
            let modifier = UserDefaults.standard.object(forKey: Constants.NewNoteKeyModifier)

            if code != nil && modifier != nil, let keyCode = code as? UInt, let modifierFlags = modifier as? UInt {
                return MASShortcut(keyCode: keyCode, modifierFlags: modifierFlags)
            }

            return MASShortcut(keyCode: 45, modifierFlags: 917504)
        }
        set {
            UserDefaults.standard.set(newValue.keyCode, forKey: Constants.NewNoteKeyCode)
            UserDefaults.standard.set(newValue.modifierFlags, forKey: Constants.NewNoteKeyModifier)
        }
    }

    static var searchNoteShortcut: MASShortcut {
        get {
            let code = UserDefaults.standard.object(forKey: Constants.SearchNoteKeyCode)
            let modifier = UserDefaults.standard.object(forKey: Constants.SearchNoteKeyModifier)

            if code != nil && modifier != nil, let keyCode = code as? UInt, let modifierFlags = modifier as? UInt {
                return MASShortcut(keyCode: keyCode, modifierFlags: modifierFlags)
            }

            return MASShortcut(keyCode: 37, modifierFlags: 917504)
        }
        set {
            UserDefaults.standard.set(newValue.keyCode, forKey: Constants.SearchNoteKeyCode)
            UserDefaults.standard.set(newValue.modifierFlags, forKey: Constants.SearchNoteKeyModifier)
        }
    }

    static var codeTheme: String {
        get {
            if let theme = UserDefaults.standard.object(forKey: Constants.codeTheme) as? String {
                return theme
            }

            return "atom-one-light"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.codeTheme)
        }
    }
}

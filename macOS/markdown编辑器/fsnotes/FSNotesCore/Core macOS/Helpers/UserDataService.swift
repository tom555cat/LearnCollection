//
//  UserDataService.swift
//  FSNotes
//
//  Created by Oleksandr Glushchenko on 1/30/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import Foundation

public class UserDataService {
    public static let instance = UserDataService()

    fileprivate var _searchTrigger = false
    fileprivate var _lastRenamed: URL?
    fileprivate var _fsUpdates = false
    fileprivate var _skipListReload = false
    fileprivate var _isNotesTableEscape = false
    fileprivate var _isDark = false

    public var searchTrigger: Bool {
        get {
            return _searchTrigger
        }
        set {
            _searchTrigger = newValue
        }
    }

    public var lastRenamed: URL? {
        get {
            return _lastRenamed
        }
        set {
            _lastRenamed = newValue
        }
    }

    public var fsUpdatesDisabled: Bool {
        get {
            return _fsUpdates
        }
        set {
            _fsUpdates = newValue
        }
    }

    public var skipListReload: Bool {
        get {
            return _skipListReload
        }
        set {
            _skipListReload = newValue
        }
    }
    
    public var isNotesTableEscape: Bool {
        get {
            return _isNotesTableEscape
        }
        set {
            _isNotesTableEscape = newValue
        }
    }

    public var isDark: Bool {
        get {
            return _isDark
        }
        set {
            _isDark = newValue
        }
    }
}

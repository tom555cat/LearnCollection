//
//  PrefsViewController.swift
//  FSNotes
//
//  Created by Oleksandr Glushchenko on 8/4/17.
//  Copyright © 2017 Oleksandr Glushchenko. All rights reserved.
//

import Cocoa
import MASShortcut
import CoreData
import FSNotesCore_macOS

class PrefsViewController: NSViewController {

    @IBOutlet var externalEditorApp: NSTextField!
    @IBOutlet weak var horizontalRadio: NSButton!
    @IBOutlet weak var verticalRadio: NSButton!
    @IBOutlet var tabView: NSTabView!
    @IBOutlet var hidePreview: NSButtonCell!
    @IBOutlet var fileExtensionOutlet: NSTextField!
    @IBOutlet var newNoteshortcutView: MASShortcutView!
    @IBOutlet var searchNotesShortcut: MASShortcutView!
    @IBOutlet weak var fontPreview: NSTextField!
    @IBOutlet weak var codeBlockHighlight: NSButtonCell!
    @IBOutlet weak var markdownCodeTheme: NSPopUpButton!
    @IBOutlet weak var liveImagesPreview: NSButton!
    @IBOutlet weak var cellSpacing: NSSlider!
    @IBOutlet weak var noteFontColor: NSColorWell!
    @IBOutlet weak var backgroundColor: NSColorWell!
    @IBOutlet weak var inEditorFocus: NSButton!
    @IBOutlet weak var restoreCursorButton: NSButton!
    @IBOutlet weak var autocloseBrackets: NSButton!
    @IBOutlet weak var defaultStoragePath: NSPathControl!
    @IBOutlet weak var showDockIcon: NSButton!
    @IBOutlet weak var archivePathControl: NSPathControl!
    @IBOutlet weak var lineSpacing: NSSlider!
    @IBOutlet weak var languagePopUp: NSPopUpButton!
    @IBOutlet weak var textMatchAutoSelection: NSButton!

    @IBOutlet weak var appearance: NSPopUpButton!
    @IBOutlet weak var appearanceLabel: NSTextField!

    @IBOutlet weak var imagesWidth: NSSlider!
    @IBOutlet weak var lineWidth: NSSlider!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var txtAsMarkdown: NSButton!
    @IBOutlet weak var showInMenuBar: NSButton!
    
    @IBAction func appearanceClick(_ sender: NSPopUpButton) {
        if let type = AppearanceType(rawValue: sender.indexOfSelectedItem) {
            UserDefaultsManagement.appearanceType = type

            if type == .Dark {
                UserDefaultsManagement.codeTheme = "monokai-sublime"
            } else if type == .System {
                if #available(OSX 10.14, *) {
                    if let appearance = NSApp.appearance, appearance.isDark {
                        UserDefaultsManagement.codeTheme = "monokai-sublime"
                    }
                }
            } else {
                UserDefaultsManagement.codeTheme = "atom-one-light"
            }
        }

        restart()
    }
    
    @IBAction func changeDefaultStorage(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                guard let url = openPanel.url else { return }
                guard let currentURL = UserDefaultsManagement.storageUrl else { return }
                
                let bookmark = SandboxBookmark.sharedInstance()
                let activeBookmars = bookmark.load()
                bookmark.remove(url: currentURL)
                bookmark.store(url: url)
                bookmark.save()
                
                UserDefaultsManagement.storagePath = url.path
                self.defaultStoragePath.stringValue = url.path

                // Resets archive if not bookmarked
                if let archiveURL = UserDefaultsManagement.archiveDirectory, !activeBookmars.contains(archiveURL) {
                    UserDefaultsManagement.archiveDirectory = nil
                }

                self.restart()
            }
        }
    }


    //MARK: global variables

    var fontPanelOpen: Bool = false
    let storage = Storage.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFontPreview()
        initShortcuts()
    }
    
    override func viewDidAppear() {
        self.view.window!.title = NSLocalizedString("Preferences", comment: "") 
        
        externalEditorApp.stringValue = UserDefaultsManagement.externalEditor
        
        if (UserDefaultsManagement.horizontalOrientation) {
            horizontalRadio.cell?.state = NSControl.StateValue(rawValue: 1)
        } else {
            verticalRadio.cell?.state = NSControl.StateValue(rawValue: 1)
        }
        
        hidePreview.state = UserDefaultsManagement.hidePreview ? NSControl.StateValue.on : NSControl.StateValue.off
        
        fileExtensionOutlet.stringValue = UserDefaultsManagement.storageExtension
                
        codeBlockHighlight.state = UserDefaultsManagement.codeBlockHighlight ? NSControl.StateValue.on : NSControl.StateValue.off
        
        liveImagesPreview.state = UserDefaultsManagement.liveImagesPreview ? NSControl.StateValue.on : NSControl.StateValue.off
        
        inEditorFocus.state = UserDefaultsManagement.focusInEditorOnNoteSelect ? NSControl.StateValue.on : NSControl.StateValue.off
        
        restoreCursorButton.state = UserDefaultsManagement.restoreCursorPosition ? .on : .off
        
        autocloseBrackets.state = UserDefaultsManagement.autocloseBrackets ? .on : .off

        markdownCodeTheme.selectItem(withTitle: UserDefaultsManagement.codeTheme)
        
        cellSpacing.doubleValue = Double(UserDefaultsManagement.cellSpacing)
        
        noteFontColor.color = UserDefaultsManagement.fontColor
        backgroundColor.color = UserDefaultsManagement.bgColor
        
        if let url = UserDefaultsManagement.storageUrl {
            defaultStoragePath.stringValue = url.path
        }
        
        showDockIcon.state = UserDefaultsManagement.showDockIcon ? .on : .off
        
        if let archiveDirectory = UserDefaultsManagement.archiveDirectory {
            archivePathControl.url = archiveDirectory
        }
        
        lineSpacing.floatValue = UserDefaultsManagement.editorLineSpacing
        imagesWidth.floatValue = UserDefaultsManagement.imagesWidth
        lineWidth.floatValue = UserDefaultsManagement.lineWidth

        let languages = [
            LanguageType(rawValue: 0x00),
            LanguageType(rawValue: 0x01),
            LanguageType(rawValue: 0x02)
        ]
        
        for language in languages {
            if let lang = language?.description, let id = language?.rawValue {
                languagePopUp.addItem(withTitle: lang)
                languagePopUp.lastItem?.state = (id == UserDefaultsManagement.defaultLanguage) ? .on : .off
                
                if id == UserDefaultsManagement.defaultLanguage {
                    languagePopUp.selectItem(withTitle: lang)
                }
            }
        }
        
        textMatchAutoSelection.state = UserDefaultsManagement.textMatchAutoSelection ? .on : .off

        if #available(OSX 10.14, *) {
            appearance.selectItem(at: UserDefaultsManagement.appearanceType.rawValue)
        } else {
            appearanceLabel.isHidden = true
            appearance.isHidden = true
        }

        if let dictionary = Bundle.main.infoDictionary,
            let ver = dictionary["CFBundleShortVersionString"] as? String,
            let build = dictionary["CFBundleVersion"] as? String {
            version.stringValue = "v\(ver) build \(build)"
        }

        txtAsMarkdown.state = UserDefaultsManagement.txtAsMarkdown ? .on : .off
        
        showInMenuBar.state = UserDefaultsManagement.showInMenuBar ? .on : .off
    }
    
    @IBAction func liveImagesPreview(_ sender: NSButton) {
        guard let vc = ViewController.shared() else { return }

        if UserDefaultsManagement.liveImagesPreview {
            if let note = EditTextView.note, let storage = vc.editArea.textStorage, storage.length > 0 {
                let processor = ImagesProcessor(styleApplier: storage, note: note)
                processor.unLoad()
                storage.setAttributedString(note.content)
            }
        }
        
        UserDefaultsManagement.liveImagesPreview = (sender.state == NSControl.StateValue.on)
        
        if let note = EditTextView.note, !UserDefaultsManagement.preview {
            NotesTextProcessor.fullScan(note: note)
            vc.refillEditArea()
        }
    }
    
    @IBAction func codeBlockHighlight(_ sender: NSButton) {
        UserDefaultsManagement.codeBlockHighlight = (sender.state == NSControl.StateValue.on)
        
        restart()
    }
    
    @IBAction func fileExtensionAction(_ sender: NSTextField) {
        let value = sender.stringValue
        UserDefaults.standard.set(value, forKey: "fileExtension")
    }
    
    @IBAction func changeHideOnDeactivate(_ sender: NSButton) {
        // We don't need to set the user defaults value here as the checkbox is
        // bound to it. We do need to update each window's hideOnDeactivate.
        for window in NSApplication.shared.windows {
            window.hidesOnDeactivate = UserDefaultsManagement.hideOnDeactivate
        }
    }
        
    @IBAction func externalEditor(_ sender: Any) {
        UserDefaultsManagement.externalEditor = externalEditorApp.stringValue
    }
    
    @IBAction func verticalOrientation(_ sender: Any) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.horizontalOrientation = false
        
        horizontalRadio.cell?.state = NSControl.StateValue(rawValue: 0)
        vc.splitView.isVertical = true
        vc.splitView.setPosition(215, ofDividerAt: 0)
        
        UserDefaultsManagement.cellSpacing = 38
        cellSpacing.doubleValue = Double(UserDefaultsManagement.cellSpacing)
        vc.setTableRowHeight()
    }
    
    @IBAction func horizontalOrientation(_ sender: Any) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.horizontalOrientation = true
        
        verticalRadio.cell?.state = NSControl.StateValue(rawValue: 0)
        vc.splitView.isVertical = false
        vc.splitView.setPosition(145, ofDividerAt: 0)

        UserDefaultsManagement.cellSpacing = 12
        cellSpacing.doubleValue = Double(UserDefaultsManagement.cellSpacing)

        vc.setTableRowHeight()
        vc.notesTableView.reloadData()
    }
    
    @IBAction func setFont(_ sender: NSButton) {
        let fontManager = NSFontManager.shared
        if UserDefaultsManagement.noteFont != nil {
            fontManager.setSelectedFont(UserDefaultsManagement.noteFont!, isMultiple: false)
        }
        
        fontManager.orderFrontFontPanel(self)
        fontPanelOpen = true
    }
    
    @IBAction func setFontColor(_ sender: NSColorWell) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.fontColor = sender.color
        vc.editArea.setEditorTextColor(sender.color)
        
        if let note = EditTextView.note {
            self.storage.fullCacheReset()
            note.reCache()
            vc.refillEditArea()
        }
    }
    
    @IBAction func setBgColor(_ sender: NSColorWell) {
        guard let vc = ViewController.shared() else { return }
        
        UserDefaultsManagement.bgColor = sender.color
        
        vc.editArea.backgroundColor = sender.color
    }
    
    @IBAction func changeCellSpacing(_ sender: NSSlider) {
        guard let vc = ViewController.shared() else { return }

        vc.setTableRowHeight()
    }
    
    @IBAction func changePreview(_ sender: Any) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.hidePreview = ((sender as AnyObject).state == NSControl.StateValue.on)
        vc.notesTableView.reloadData()
    }

    // changeFont is sent by the Font Panel.
    override func changeFont(_ sender: Any?) {
        guard let vc = ViewController.shared() else { return }

        let fontManager = NSFontManager.shared
        let newFont = fontManager.convert(UserDefaultsManagement.noteFont!)
        UserDefaultsManagement.noteFont = newFont
        
        if let note = EditTextView.note {
            self.storage.fullCacheReset()
            note.reCache()
            vc.refillEditArea()
        }
        
        vc.reloadView()
        setFontPreview()
    }

    func setFontPreview() {
        fontPreview.font = NSFont(name: UserDefaultsManagement.fontName, size: 13)
        fontPreview.stringValue = "\(UserDefaultsManagement.fontName) \(UserDefaultsManagement.fontSize)pt"
    }

    func restart() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
    
    func initShortcuts() {
        guard let vc = ViewController.shared() else { return }

        let mas = MASShortcutMonitor.shared()
        
        newNoteshortcutView.shortcutValue = UserDefaultsManagement.newNoteShortcut
        searchNotesShortcut.shortcutValue = UserDefaultsManagement.searchNoteShortcut
        
        newNoteshortcutView.shortcutValueChange = { (sender) in
            if ((self.newNoteshortcutView.shortcutValue) != nil) {
                mas?.unregisterShortcut(UserDefaultsManagement.newNoteShortcut)
                
                let keyCode = self.newNoteshortcutView.shortcutValue.keyCode
                let modifierFlags = self.newNoteshortcutView.shortcutValue.modifierFlags
                
                UserDefaultsManagement.newNoteShortcut = MASShortcut(keyCode: keyCode, modifierFlags: modifierFlags)
                
                MASShortcutMonitor.shared().register(self.newNoteshortcutView.shortcutValue, withAction: {
                    vc.makeNoteShortcut()
                })
            }
        }
        
        searchNotesShortcut.shortcutValueChange = { (sender) in
            if ((self.searchNotesShortcut.shortcutValue) != nil) {
                mas?.unregisterShortcut(UserDefaultsManagement.searchNoteShortcut)
                
                let keyCode = self.searchNotesShortcut.shortcutValue.keyCode
                let modifierFlags = self.searchNotesShortcut.shortcutValue.modifierFlags
                
                UserDefaultsManagement.searchNoteShortcut = MASShortcut(keyCode: keyCode, modifierFlags: modifierFlags)
                
                MASShortcutMonitor.shared().register(self.searchNotesShortcut.shortcutValue, withAction: {
                    vc.searchShortcut()
                })
            }
        }
    }
        
    @IBAction func markdownCodeThemeAction(_ sender: NSPopUpButton) {
        guard let vc = ViewController.shared() else { return }
        guard let item = sender.selectedItem else {
            return
        }
        
        UserDefaultsManagement.codeTheme = item.title

        NotesTextProcessor.hl = nil
        self.storage.fullCacheReset()
        vc.refillEditArea()
    }
    
    @IBAction func inEditorFocus(_ sender: NSButton) {
        UserDefaultsManagement.focusInEditorOnNoteSelect = (sender.state == .on)
    }
    
    @IBAction func restoreCursor(_ sender: NSButton) {
        UserDefaultsManagement.restoreCursorPosition = (sender.state == .on)
    }
    
    @IBAction func autocloseBrackets(_ sender: NSButton) {
        UserDefaultsManagement.autocloseBrackets = (sender.state == .on)
    }
    
    @IBAction func showDockIcon(_ sender: NSButton) {
        let isEnabled = sender.state == .on
        UserDefaultsManagement.showDockIcon = isEnabled
        
        NSApp.setActivationPolicy(isEnabled ? .regular : .accessory)
        
        DispatchQueue.main.async {
            NSMenu.setMenuBarVisible(true)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @IBAction func changeArchiveStorage(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                guard let url = openPanel.url else { return }
                guard let currentURL = UserDefaultsManagement.archiveDirectory else { return }
                
                let bookmark = SandboxBookmark.sharedInstance()
                _ = bookmark.load()
                bookmark.remove(url: currentURL)
                bookmark.store(url: url)
                bookmark.save()
                
                UserDefaultsManagement.archiveDirectory = url
                self.archivePathControl.url = url
                
                let storage = self.storage
                guard let vc = ViewController.shared() else { return }
                
                if let archive = storage.getArchive() {
                    archive.url = url
                    storage.unload(project: archive)
                    storage.loadLabel(archive)
                    storage.cacheMarkdown(project: archive)

                    vc.fsManager?.restart()
                    vc.notesTableView.reloadData()
                    vc.storageOutlineView.reloadData()
                    vc.storageOutlineView.selectArchive()
                }
            }
        }
    }
    
    @IBAction func lineSpacing(_ sender: NSSlider) {
        guard let vc = ViewController.shared() else { return }
        UserDefaultsManagement.editorLineSpacing = sender.floatValue
        
        vc.editArea.applyLeftParagraphStyle()
    }
    
    @IBAction func languagePopUp(_ sender: NSPopUpButton) {
        let type = LanguageType.withName(rawValue: sender.title)
        
        UserDefaultsManagement.defaultLanguage = type.rawValue
        
        UserDefaults.standard.set([type.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        restart()
    }
    
    @IBAction func textMatchAutoSelection(_ sender: NSButton) {
        UserDefaultsManagement.textMatchAutoSelection = (sender.state == .on)
    }

    @IBAction func imagesWidth(_ sender: NSSlider) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.imagesWidth = sender.floatValue

        if let note = EditTextView.note, !UserDefaultsManagement.preview {
            NotesTextProcessor.fullScan(note: note)
            vc.refillEditArea()
        }
    }

    @IBAction func lineWidth(_ sender: NSSlider) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.lineWidth = sender.floatValue

        if let _ = EditTextView.note, !UserDefaultsManagement.preview {
            vc.editArea.updateTextContainerInset()
        }
    }

    @IBAction func txtAsMarkdown(_ sender: NSButton) {
        UserDefaultsManagement.txtAsMarkdown = sender.state == .on
    }
    
    @IBAction func showInMenuBar(_ sender: NSButton) {
        UserDefaultsManagement.showInMenuBar = sender.state == .on
        
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        
        if sender.state == .off {
            appDelegate.removeMenuBar(nil)
            return
        }
        
        appDelegate.addMenuBar(nil)
    }
    
}

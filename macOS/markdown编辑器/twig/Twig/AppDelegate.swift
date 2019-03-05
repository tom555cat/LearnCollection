//
//  AppDelegate.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

let defaults = UserDefaults.standard

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  /// The key window's `WindowController` instance
  private var keyWindowController: WindowController? {
    return NSApp.keyWindow?.windowController as? WindowController
  }

  override init() {
    // Hacky way to get in before NSDocumentController instantiates its shared instance.
    // This way we can subclass NSDocumentController and use our class as the shared instance
    _ = DocumentController.init()

    super.init()
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    if #available(OSX 10.12.2, *) {
      NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
    }
  }

  func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
    return preferences.openNewDocumentOnStartup
  }

  // MARK: - First responder methods that can be called anywhere in the application

  @IBAction func openFileOrFolder(_ sender: Any?) {
    let dialog = NSOpenPanel()

    dialog.allowsMultipleSelection = false
    dialog.canChooseFiles = true
    dialog.showsHiddenFiles = true
    dialog.canCreateDirectories = true
    dialog.canChooseDirectories = true
    dialog.allowedFileTypes = ["md", "markdown"]

    guard
      dialog.runModal() == .OK,
      let result = dialog.url
    else { return }

    var isDirectory: ObjCBool = false

    // Ensure the file or folder exists
    guard FileManager.default.fileExists(
      atPath: result.path,
      isDirectory: &isDirectory
    ) else { return }

    DispatchQueue.global(qos: .userInitiated).async {
      let parent = FileSystemItem.createParents(url: result)
      let newItem = FileSystemItem(path: result.absoluteString, parent: parent)

      DispatchQueue.main.async {
        openDocuments.addDocument(newItem)

        if isDirectory.boolValue {
          // Don't have a window open
          if NSApp.keyWindow == nil {
            DocumentController.shared.newDocument(nil)
          } else {
            self.keyWindowController?.syncWindowSidebars()
          }
        } else {
          DocumentController.shared.openDocument(
            withContentsOf: result,
            display: true,
            completionHandler: { _,_,_  in }
          )
        }
      }
    }
  }

}

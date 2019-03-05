//
//  DefaultExtensionControllerView.swift
//  FSNotes iOS
//
//  Created by Oleksandr Glushchenko on 2/28/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import UIKit
import NightNight

class DefaultExtensionViewController: UITableViewController {
    private var extensions = ["md", "txt", "rtf", "markdown", "fountain", "textbundle"]
    
    override func viewDidLoad() {
        navigationController?.navigationBar.mixedTitleTextAttributes = [NNForegroundColorAttributeName: Colors.titleText]
        navigationController?.navigationBar.mixedTintColor = MixedColor(normal: 0x4d8be6, night: 0x7eeba1)
        navigationController?.navigationBar.mixedBarTintColor = Colors.Header
        
        view.mixedBackgroundColor = MixedColor(normal: 0xffffff, night: 0x2e2c32)
        
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = Buttons.getBack(target: self, selector: #selector(cancel))

        self.title = "Default Extension"
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), let label = cell.textLabel {
            UserDefaultsManagement.storageExtension = label.text!
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.mixedBackgroundColor = MixedColor(normal: 0xffffff, night: 0x2e2c32)
        cell.textLabel?.mixedTextColor = MixedColor(normal: 0x000000, night: 0xffffff)
        
        if cell.textLabel?.text == UserDefaultsManagement.storageExtension {
            cell.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extensions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = extensions[indexPath.row]
        
        let view = UIView()
        view.mixedBackgroundColor = MixedColor(normal: 0xe2e5e4, night: 0x686372)
        cell.selectedBackgroundView = view
        
        return cell
    }
}

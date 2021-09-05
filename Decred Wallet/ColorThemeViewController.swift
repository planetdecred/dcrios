//
//  ColorThemeViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 07/09/2021.
//  Copyright © 2021 Decred. All rights reserved.
//

import UIKit

enum ColorThemeOption: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case deviceDefault = "Device default"
}

@available(iOS 13.0, *)
class ColorThemeViewController: UITableViewController {
    @IBOutlet weak var deviceDefault_cell: UITableViewCell!
    @IBOutlet weak var light_cell: UITableViewCell!
    @IBOutlet weak var dark_cell: UITableViewCell!
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch Settings.colorThemeOption {
        case .deviceDefault:
            deviceDefault_cell.accessoryType = .checkmark
            deviceDefault_cell.setSelected(true, animated: true)
            light_cell.accessoryType = .none
            dark_cell.accessoryType = .none
                
        case .light:
            deviceDefault_cell.accessoryType = .none
            deviceDefault_cell.accessoryType = .none
            dark_cell.accessoryType = .none
            light_cell.accessoryType = .checkmark
            light_cell.setSelected(true, animated: true)
            
        case .dark:
            deviceDefault_cell.accessoryType = .none
            light_cell.accessoryType = .none
            dark_cell.accessoryType = .checkmark
            dark_cell.setSelected(true, animated: true)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return LocalizedStrings.colorTheme.capitalized
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let window = AppDelegate.shared.window else {
            return
        }
        
        deviceDefault_cell.accessoryType = .none
        light_cell.accessoryType = .none
        dark_cell.accessoryType = .none
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
            
        let selectedOption = ColorThemeOption.allCases[indexPath.row]
        switch selectedOption {
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        case .deviceDefault:
            window.overrideUserInterfaceStyle = .unspecified
        }
        Settings.setStringValue(selectedOption.rawValue, for: GlobalConstants.Strings.COLORTHEME)
    }
        
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
}

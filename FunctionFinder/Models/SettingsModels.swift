//
//  SettingsModels.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/15/23.
//

import Foundation
import UIKit

struct SettingsSection {
    let title: String
    let options: [SettingOption]
}

struct SettingOption {
    let title: String
    let image: UIImage?
    let color: UIColor
    let handler: (() -> Void)
}

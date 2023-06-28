//
//  AppearanceHandler.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit
import Airwallex

class AppearanceHandler {
    static func configureAppearance() {
        UINavigationBar.appearance().barTintColor = AWXTheme.shared().toolbarColor()
        UINavigationBar.appearance().tintColor = AWXTheme.shared().tintColor
        
        UIView.appearance().tintColor = AWXTheme.shared().tintColor
        UISwitch.appearance().onTintColor = AWXTheme.shared().tintColor
    }
}

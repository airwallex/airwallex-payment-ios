//
//  String+Extensions.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/9.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

extension String {
    
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

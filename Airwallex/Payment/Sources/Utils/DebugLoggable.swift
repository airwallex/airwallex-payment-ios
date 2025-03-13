//
//  DebugLoggable.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

protocol DebugLoggable {}

extension DebugLoggable {
    func debugLog(_ message: String = "",
                  file: String = #file,
                  functionName: String = #function,
                  line: Int = #line) {
        NSObject.logMesage("----Airwallex SDK----\(Date())---\n\(file)\n---\(functionName)-line: \(line)-\n---\(message)")
    }
}

extension NSObject: DebugLoggable {}

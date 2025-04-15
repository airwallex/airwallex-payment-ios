//
//  ErrorMessage.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/17.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

@_spi(AWX) public struct ErrorMessage: Error, RawRepresentable, LocalizedError {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var errorDescription: String? {
        rawValue
    }
}

@_spi(AWX) public extension String {
    func asError() -> ErrorMessage {
        ErrorMessage(rawValue: self)
    }
}

@_spi(AWX) public func debugLog(_ message: String = "",
                                file: String = #file,
                                functionName: String = #function,
                                line: Int = #line) {
    let fileName = file.split(separator: "/").map { String($0) }.last ?? file
    NSObject.logMesage("----Airwallex SDK----\(Date())---\n- \(fileName) L:\(line)\n- func: \(functionName)\n- \(message)")
}

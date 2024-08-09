//
//  NSObject+Utils.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import os

@objc
public extension NSObject {
    func logMessage(_ message: String) {
        if !Airwallex.analyticsEnabled() {
            return
        }
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let className = String(describing: type(of: self))
        let customLog = OSLog(subsystem: "com.airwallex.payment.sdk", category: "general")
        let formattedMessage =
            "----Airwallex SDK----\(formatter.string(from: now))----\(className)----\n \(message)"
        os_log("%{public}@", log: customLog, type: .default, formattedMessage)
        if Airwallex.isLocalLogFileEnabled() {
            logIntoLocalFile(formattedMessage)
        }
    }

    func logIntoLocalFile(_ msg: String) {
        let logDateKey = "AirwallexSDK_last_log_date"

        let fileManager = FileManager.default
        if let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFileUrl = documentsUrl.appendingPathComponent("AirwallexSDK.log")
            if let data = msg.data(using: .utf8) {
                let now = Date()
                let todayDate = now.timeIntervalSince1970
                let lastDate = UserDefaults.standard.double(forKey: logDateKey) as TimeInterval
                if fileManager.fileExists(atPath: logFileUrl.path),
                   todayDate - lastDate < 60.0 * 60.0 * 24.0 * 7.0
                {
                    let fileHandle = FileHandle(forWritingAtPath: logFileUrl.path)
                    fileHandle?.seekToEndOfFile()
                    fileHandle?.write(data)
                    fileHandle?.closeFile()
                } else {
                    do {
                        try fileManager.removeItem(atPath: logFileUrl.path)
                        try data.write(to: logFileUrl, options: .atomic)
                    } catch {
                        UserDefaults.standard.set(todayDate, forKey: logDateKey)
                    }
                }
            }
        }
    }
}

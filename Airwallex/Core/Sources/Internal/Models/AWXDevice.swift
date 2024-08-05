//
//  AWXDevice.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXDevice` includes the information of 3ds.
@objcMembers
@objc
public class AWXDevice: NSObject, Codable {
    public let deviceId: String?
    public var mobile: AWXMoblie

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case mobile
    }

    public init(deviceId: String?) {
        mobile = AWXMoblie()
        self.deviceId = deviceId
    }

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXDevice {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXDevice.self, from: jsonData)

            return result
        } catch {
            return AWXDevice(deviceId: nil)
        }
    }

    public func encodeToJSON() -> [String: Any] {
        return toDictionary() ?? [String: Any]()
    }
}

/// `AWXDevice` includes the information of 3ds.
@objcMembers
@objc
public class AWXMoblie: NSObject, Codable {
    public var osType: String
    public var deviceModel: String
    public var osVersion: String

    enum CodingKeys: String, CodingKey {
        case osType = "os_type"
        case deviceModel = "device_model"
        case osVersion = "os_version"
    }

    override public init() {
        osType = UIDevice.current.systemName
        deviceModel = UIDevice.current.model
        osVersion = UIDevice.current.systemVersion
    }
}

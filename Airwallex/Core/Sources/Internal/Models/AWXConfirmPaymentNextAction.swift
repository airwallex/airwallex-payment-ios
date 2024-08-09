//
//  AWXConfirmPaymentNextAction.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXConfirmPaymentNextAction` includes the parameters for next action.
@objcMembers
@objc
public class AWXConfirmPaymentNextAction: NSObject, Codable {
    /**
     Next action type.
     */
    public let type: String?

    /**
     URL.
     */
    public let url: String?

    /**
     Method.
     */
    public let method: String?

    /**
     Stage.
     */
    public let stage: String?

    /**
     Payload of next action.
     */
    public var payload: [String: String]? {
        data ?? dccData
    }

    private let data: [String: String]?
    private let dccData: [String: String]?

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case method
        case stage
        case data
        case dccData = "dcc_data"
    }

    init(type: String?, url: String?, method: String?, stage: String?, data: [String: String]?, dccData: [String: String]?) {
        self.type = type
        self.url = url
        self.method = method
        self.stage = stage
        self.data = data
        self.dccData = dccData
    }

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXConfirmPaymentNextAction {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXConfirmPaymentNextAction.self, from: jsonData)

            return result
        } catch {
            return AWXConfirmPaymentNextAction(type: nil, url: nil, method: nil, stage: nil, data: nil, dccData: nil)
        }
    }
}

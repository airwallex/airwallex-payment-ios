//
//  Codable+Utils.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

public extension Encodable {
    func toDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self)
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                as? [String: Any]
            {
                return jsonObject
            }
        } catch {
            print("Fail to encode: \(error)")
        }
        return nil
    }
}

public extension Decodable {
    static func from(_ data: Data) -> Self? {
        do {
            let object = try JSONDecoder().decode(Self.self, from: data)
            return object
        } catch {
            print("Fail to Decode: \(error)")
            return nil
        }
    }

    static func parseError(_ data: Data) -> AWXAPIErrorResponse? {
        do {
            let object = try JSONDecoder().decode(AWXAPIErrorResponse.self, from: data)
            return object
        } catch {
            print("Fail to Decode: \(error)")
            return nil
        }
    }
}

extension AWXAPIErrorResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case message
        case code
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encode(code, forKey: .code)
    }

    // MARK: - Decodable

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let message = try container.decode(String.self, forKey: .message)
        let code = try container.decode(String.self, forKey: .code)

        self.init(message: message, code: code)
    }
}

extension AWXCardBrand: Codable {}

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
            // 编码对象为 JSON 数据
            let jsonData = try encoder.encode(self)
            // 使用 JSONSerialization 将 JSON 数据转换为字典
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
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
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(Self.self, from: data)
            return object
        } catch {
            print("Fail to Decode: \(error)")
            return nil
        }
    }
}

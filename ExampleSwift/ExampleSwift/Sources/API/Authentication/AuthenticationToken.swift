//
//  AuthenticationToken.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 16/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

struct AuthenticationToken: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case expiresAt = "expires_at"
        case token
    }
    
    let expiresAt: String
    let token: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.expiresAt = try container.decode(String.self, forKey: .expiresAt)
        self.token = try container.decode(String.self, forKey: .token)
    }
}

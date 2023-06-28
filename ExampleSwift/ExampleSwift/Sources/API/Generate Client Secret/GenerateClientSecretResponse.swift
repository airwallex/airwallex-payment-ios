//
//  GenerateClientSecretResponse.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 5/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

struct GenerateClientSecretResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
    }
    
    let clientSecret: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.clientSecret = try container.decode(String.self, forKey: .clientSecret)
    }
}

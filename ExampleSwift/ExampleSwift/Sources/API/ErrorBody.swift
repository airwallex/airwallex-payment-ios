//
//  ErrorBOdy.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 27/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

class ErrorBody: Decodable {
    enum CodingKeys: String, CodingKey {
        case message
    }
    
    let message: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decode(String.self, forKey: .message)
    }
}

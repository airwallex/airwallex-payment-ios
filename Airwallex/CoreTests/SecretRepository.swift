//
//  SecretRepository.swift
//  CoreTests
//
//  Created by Hector.Huang on 2023/11/29.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

public class SecretRepository: NSObject {
    @objc static var apiKey: String = "$(API_KEY)"
    @objc static var clientId: String = "$(CLIENT_ID)"
}

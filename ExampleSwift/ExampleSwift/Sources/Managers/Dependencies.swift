//
//  Dependencies.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

class Dependencies {
    static let shared: Dependencies = Dependencies()
    
    let networkManager: NetworkManager
    let environmentManager: EnvironmentManager
    
    private init() {
        self.environmentManager = EnvironmentManager(
            userDefaults: UserDefaults.standard
        )
        
        self.networkManager = NetworkManager(
            urlSession: URLSession.shared,
            environmentManager: environmentManager
        )
    }
}

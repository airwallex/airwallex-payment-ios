//
//  InfoPListWrapper.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 28/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

@propertyWrapper
struct InfoProperty<T> {
    enum Key: String {
        case wechatID = "EXAMPLES_WECHAT_ID"
    }
    
    private let key: Key

    init(_ key: Key) {
        self.key = key
    }

    var wrappedValue: T? {
        return Bundle.main.infoDictionary?[key.rawValue] as? T
    }
}

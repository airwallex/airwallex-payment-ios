//
//  Strings.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//

import Foundation

extension String {
    func filterIllegalCharacters(in set: CharacterSet) -> String {
        let components = components(separatedBy: set)
        return components.joined()
    }
}

extension String: Error {}

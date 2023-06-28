//
//  ExamplesError.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 23/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

public enum ExamplesError: Error {
    case paymentIntentError
    case missingRequiredConfigurationError
    case missingCustomerIDError
    case clientSecretError
    case apiError(title: String, message: String)
}

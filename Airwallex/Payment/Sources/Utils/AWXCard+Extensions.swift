//
//  AWXCard.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

extension AWXCard {
    // convert this into an init method in swift
    convenience init(name: String, cardNumber: String, expiry: String, cvc: String) {
        self.init()
        self.name = name
        self.number = cardNumber.filterIllegalCharacters(in: .whitespacesAndNewlines)
        self.expiryMonth = String(expiry.prefix(2))
        self.expiryYear = "20\(expiry.suffix(2))"
        self.cvc = cvc
    }
}

//
//  AWXCard.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

extension AWXCard {
    /*
    - (AWXCard *)makeCardWithName:(NSString *)name
                           number:(NSString *)number
                           expiry:(NSString *)expiry
                              cvc:(NSString *)cvc {
        NSArray *dates = [expiry componentsSeparatedByString:@"/"];

        AWXCard *card = [AWXCard new];
        card.name = name;
        card.number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
        card.expiryYear = [NSString stringWithFormat:@"20%@", dates.lastObject];
        card.expiryMonth = dates.firstObject;
        card.cvc = cvc;

        return card;
    }
     */
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

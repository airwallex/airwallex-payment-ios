//
//  PKPaymentMethod+Request.m
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "PKPaymentMethod+Request.h"

@implementation PKPaymentMethod (Request)

- (NSString *)typeNameForRequest {
    switch (self.type) {
    case PKPaymentMethodTypeCredit:
        return @"credit";
    case PKPaymentMethodTypeDebit:
        return @"debit";
    case PKPaymentMethodTypeEMoney:
        return @"emoney";
    case PKPaymentMethodTypePrepaid:
        return @"prepaid";
    case PKPaymentMethodTypeStore:
        return @"store";
    case PKPaymentMethodTypeUnknown:
        return @"unknown";
    }
}

@end

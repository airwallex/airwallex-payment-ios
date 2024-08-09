//
//  AWXPaymentFormViewModel.m
//  Redirect
//
//  Created by Hector.Huang on 2022/7/5.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentFormViewModel.h"
#import "AWXUtils.h"
#ifdef AirwallexSDK
#import "Core/Core-Swift.h"
#else
#import "Airwallex/Airwallex-Swift.h"
#endif

@implementation AWXPaymentFormViewModel

- (instancetype)initWithSession:(AWXSession *)session paymentMethod:(AWXPaymentMethod *)paymentMethod formMapping:(AWXFormMapping *)formMapping {
    self = [super init];
    if (self) {
        _session = session;
        _pageName = @"payment_info_sheet";
        NSMutableDictionary *info = [NSMutableDictionary new];
        if (paymentMethod.type.length > 0) {
            [info setObject:paymentMethod.type forKey:@"paymentMethod"];
        }
        if (formMapping.title.length > 0) {
            [info setObject:formMapping.title forKey:@"formTitle"];
        }
        _additionalInfo = info;
    }
    return self;
}

- (nullable NSString *)phonePrefix {
    return [self phonePrefixFromCountryCode] ?: [self phonePrefixFromCurrency];
}

- (nullable NSString *)phonePrefixFromCountryCode {
    return [self loadConfigFile:@"CountryCodes"][_session.countryCode];
}

- (nullable NSString *)phonePrefixFromCurrency {
    return [self loadConfigFile:@"CurrencyCodes"][_session.currency];
}

- (nullable NSDictionary *)loadConfigFile:(NSString *)filename {
    NSString *path = [[NSBundle resourceBundle] pathForResource:filename ofType:@"json"];
    if (path) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        }
    }
    return nil;
}

@end

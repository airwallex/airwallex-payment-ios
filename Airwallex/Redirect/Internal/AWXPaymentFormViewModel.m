//
//  AWXPaymentFormViewModel.m
//  Redirect
//
//  Created by Hector.Huang on 2022/7/5.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentFormViewModel.h"
#import "AWXUtils.h"

@implementation AWXPaymentFormViewModel

- (instancetype)initWithSession:(AWXSession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (NSString *)phonePrefix {
    return [self phonePrefixFromCountryCode] ?: [self phonePrefixFromCurrency];
}

- (NSString *)phonePrefixFromCountryCode {
    return [self loadConfigFile:@"CountryCodes"][_session.countryCode];
}

- (NSString *)phonePrefixFromCurrency {
    return [self loadConfigFile:@"CurrencyCodes"][_session.currency];
}

- (NSDictionary *)loadConfigFile:(NSString *)filename {
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

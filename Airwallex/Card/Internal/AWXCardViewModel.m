//
//  AWXCardViewModel.m
//  Card
//
//  Created by Hector.Huang on 2022/9/14.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardViewModel.h"

@implementation AWXCardViewModel

- (instancetype)initWithSession:(AWXSession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)saveBillingWithPlaceDetails:(AWXPlaceDetails *)placeDetails Address:(AWXAddress *)address completionHandler:(void (^)(AWXPlaceDetails * _Nullable, NSString * _Nullable))completionHandler {
    placeDetails.address = address;
    NSString *error = [billing validate];
    if (error) {
        completionHandler(NULL, error);
    } else {
        completionHandler(address, NULL);
    }
}

- (void)saveCardWithName:(NSString *)name CardNo:(NSString *)cardNo ExpiryText:(NSString *)expiryText Cvc:(NSString *)cvc completionHandler:(void (^)(AWXCard * _Nullable, NSError * _Nullable))completionHandler {
    AWXCard *card = [AWXCard new];
    card.name = name;
    card.number = [cardNo stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *dates = [expiryText componentsSeparatedByString:@"/"];
    card.expiryYear = [NSString stringWithFormat:@"20%@", dates.lastObject];
    card.expiryMonth = dates.firstObject;
    card.cvc = cvc;

    NSString *error = [card validate];
    if (error) {
        completionHandler(NULL, error);
    } else {
        completionHandler(card, NULL);
    }
}

@end

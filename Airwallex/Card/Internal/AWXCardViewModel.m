//
//  AWXCardViewModel.m
//  Card
//
//  Created by Hector.Huang on 2022/9/14.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardViewModel.h"
#import "AWXSession.h"
#import "AWXCard.h"
#import "AWXCardProvider.h"

@interface AWXCardViewModel ()

@property (nonatomic, strong, nonnull) AWXSession *session;
@property (nonatomic, strong, nullable) AWXPlaceDetails *validatedBilling;
@property (nonatomic, strong, nullable) AWXCard *validatedCard;

@end

@implementation AWXCardViewModel

- (instancetype)initWithSession:(AWXSession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (BOOL)isBillingInformationRequired {
    return self.session.isBillingInformationRequired;
}

#pragma mark Data validation

- (void)validateSessionBillingWithError:(NSError **)error {
    [self validateBillingDetailsWithPlace:self.session.billing andAddress:self.session.billing.address error:error];
}

- (void)validateBillingDetailsWithPlace:(AWXPlaceDetails *)placeDetails
                             andAddress:(AWXAddress *)addressDetails
                                  error:(NSError **)error {
    self.validatedBilling = nil;
    
    if (!self.isBillingInformationRequired) {
        return;
    }
    
    AWXPlaceDetails *place = placeDetails.copy;
    AWXAddress *address = addressDetails.copy;
    place.address = address;
    
    *error = [place validate];
    if (error == nil) {
        self.validatedBilling = place;
    }
}

- (void)validateCardWithName:(NSString *)name
                      number:(NSString *)number
                      expiry:(NSString *)expiry
                         cvc:(NSString *)cvc
                       error:(NSError **)error {
    self.validatedBilling = nil;
    
    NSArray *dates = [expiry componentsSeparatedByString:@"/"];
    
    AWXCard *card = [AWXCard new];
    card.name = name;
    card.number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
    card.expiryYear = [NSString stringWithFormat:@"20%@", dates.lastObject];
    card.expiryMonth = dates.firstObject;
    card.cvc = cvc;
    
    *error = [card validate];
    if (error == nil) {
        self.validatedCard = card;
    }
}

#pragma mark Payment

- (AWXCardProvider *)preparedProviderWithDelegate:(id<AWXProviderDelegate>)delegate {
    return [[AWXCardProvider alloc] initWithDelegate:delegate session:self.session];
}

- (void)confirmPaymentWithProvider:(AWXCardProvider *_Nonnull)provider shouldStoreCardDetails:(BOOL)storeCard {
    if (self.validatedCard == nil) {
        return;
    }
    
    if (self.validatedBilling == nil && self.isBillingInformationRequired) {
        return;
    }
    
    [provider confirmPaymentIntentWithCard:self.validatedCard billing:self.validatedBilling saveCard:storeCard];
}

@end

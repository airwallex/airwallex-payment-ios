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

@property (nonatomic, readwrite) BOOL isReusingShippingAsBillingInformation;
@property (nonatomic, strong, nonnull) AWXSession *session;

@end

@implementation AWXCardViewModel

- (instancetype)initWithSession:(AWXSession *)session {
    self = [super init];
    if (self) {
        _session = session;
        _isReusingShippingAsBillingInformation = session.billing != nil && session.isBillingInformationRequired;
    }
    return self;
}

- (BOOL)isBillingInformationRequired {
    return self.session.isBillingInformationRequired;
}

- (void)setReusesShippingAsBillingInformation:(BOOL)reusesShippingAsBillingInformation error:(NSError **)error {
    if (reusesShippingAsBillingInformation && self.session.billing == nil) {
        *error = NSLocalizedString(@"No shipping address configured.", nil);
    } else {
        self.isReusingShippingAsBillingInformation = reusesShippingAsBillingInformation;
    }
}

#pragma mark Data creation

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

#pragma mark Data validation

- (AWXPlaceDetails *)validatedBillingDetails:(AWXPlaceDetails *)billing error:(NSError **)error {
    if (!self.isBillingInformationRequired) {
        return nil;
    }
    
    AWXPlaceDetails *validated;
    if (self.isReusingShippingAsBillingInformation) {
        validated = self.session.billing.copy;
    } else {
        validated = billing.copy;
    }
    
    *error = [validated validate];
    return (error != nil) ? nil : validated;
}

- (AWXCard *)validatedCardDetails:(AWXCard *)card error:(NSError **)error {
    AWXCard *validated = card.copy;
    
    *error = [validated validate];
    return (error != nil) ? nil : validated;
}

#pragma mark Payment

- (AWXCardProvider *)preparedProviderWithDelegate:(id<AWXProviderDelegate>)delegate {
    return [[AWXCardProvider alloc] initWithDelegate:delegate session:self.session];
}

- (void)confirmPaymentWithProvider:(AWXCardProvider *_Nonnull)provider
                           billing:(AWXPlaceDetails *)placeDetails
                              card:(AWXCard *)card
            shouldStoreCardDetails:(BOOL)storeCard
                             error:(NSError **)error {
    AWXPlaceDetails *validatedBilling = [self validatedBillingDetails:placeDetails error:error];
    if (error) {
        return;
    }
    
    AWXCard *validatedCard = [self validatedCardDetails:card error:error];
    if (error) {
        return;
    }
    
    [provider confirmPaymentIntentWithCard:validatedCard billing:validatedBilling saveCard:storeCard];
}

@end

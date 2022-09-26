//
//  AWXCardViewModel.m
//  Card
//
//  Created by Hector.Huang on 2022/9/14.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardViewModel.h"
#import "AWXCard.h"
#import "AWXCardProvider.h"
#import "AWXCountry.h"
#import "AWXSession.h"

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
        _selectedCountry = [AWXCountry countryWithCode:session.billing.address.countryCode];
    }
    return self;
}

- (BOOL)isBillingInformationRequired {
    return self.session.isBillingInformationRequired;
}

- (BOOL)isCardSavingEnabled {
    return [self.session isKindOfClass:[AWXOneOffSession class]] && self.session.customerId;
}

- (AWXPlaceDetails *)initialBilling {
    return self.session.billing;
}

- (BOOL)setReusesShippingAsBillingInformation:(BOOL)reusesShippingAsBillingInformation error:(NSString **)error {
    if (reusesShippingAsBillingInformation && self.session.billing == nil) {
        if (error != NULL) {
            *error = NSLocalizedString(@"No shipping address configured.", nil);
        }
        
        return NO;
    } else {
        self.isReusingShippingAsBillingInformation = reusesShippingAsBillingInformation;
        
        return YES;
    }
}

#pragma mark Data creation

- (AWXPlaceDetails *)makeBillingWithFirstName:(NSString *)firstName
                                     lastName:(NSString *)lastName
                                        email:(NSString *)email
                                  phoneNumber:(NSString *)phoneNumber
                                        state:(NSString *)state
                                         city:(NSString *)city
                                       street:(NSString *)street
                                     postcode:(NSString *)postcode {
    AWXPlaceDetails *place = [AWXPlaceDetails new];
    place.firstName = firstName;
    place.lastName = lastName;
    place.email = email;
    place.phoneNumber = phoneNumber;

    AWXAddress *address = [AWXAddress new];
    address.countryCode = self.selectedCountry.countryCode;
    address.state = state;
    address.city = city;
    address.street = street;
    address.postcode = postcode;

    place.address = address;
    return place;
}

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

- (AWXPlaceDetails *)validatedBillingDetails:(AWXPlaceDetails *)billing error:(NSString **)error {
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
    return (*error != nil) ? nil : validated;
}

- (AWXCard *)validatedCardDetails:(AWXCard *)card error:(NSString **)error {
    *error = [card validate];
    return (*error != nil) ? nil : card;
}

#pragma mark Payment

- (AWXCardProvider *)preparedProviderWithDelegate:(id<AWXProviderDelegate>)delegate {
    return [[AWXCardProvider alloc] initWithDelegate:delegate session:self.session];
}

- (AWXDefaultActionProvider *)actionProviderForNextAction:(AWXConfirmPaymentNextAction *)nextAction
                                             withDelegate:(id<AWXProviderDelegate> _Nullable)delegate {
    Class class = ClassToHandleNextActionForType(nextAction);
    if (class == nil) {
        return nil;
    }

    AWXDefaultActionProvider *actionProvider = [[class alloc] initWithDelegate:delegate session:self.session];
    return actionProvider;
}

- (void)confirmPaymentWithProvider:(AWXCardProvider *_Nonnull)provider
                           billing:(AWXPlaceDetails *)placeDetails
                              card:(AWXCard *)card
            shouldStoreCardDetails:(BOOL)storeCard
                             error:(NSString **)error {
    AWXPlaceDetails *validatedBilling = [self validatedBillingDetails:placeDetails error:error];
    if (*error) {
        return;
    }

    AWXCard *validatedCard = [self validatedCardDetails:card error:error];
    if (*error) {
        return;
    }

    [provider confirmPaymentIntentWithCard:validatedCard billing:validatedBilling saveCard:storeCard];
}

- (void)updatePaymentIntentId:(NSString *)paymentIntentId {
    [self.session updateInitialPaymentIntentId:paymentIntentId];
}

@end

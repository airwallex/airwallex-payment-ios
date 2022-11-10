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
#import "AWXCardValidator.h"
#import "AWXCountry.h"
#import "AWXSession.h"

@interface AWXCardViewModel ()

@property (nonatomic, readwrite) BOOL isReusingShippingAsBillingInformation;
@property (nonatomic, strong, nonnull) AWXSession *session;

@end

@implementation AWXCardViewModel

- (instancetype)initWithSession:(AWXSession *)session supportedCardSchemes:(NSArray<AWXCardScheme *> *)cardSchemes {
    self = [super init];
    if (self) {
        _session = session;
        _isReusingShippingAsBillingInformation = session.billing != nil && session.isBillingInformationRequired;
        _selectedCountry = [AWXCountry countryWithCode:session.billing.address.countryCode];
        _supportedCardSchemes = cardSchemes;
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
    if (self.isReusingShippingAsBillingInformation) {
        return self.session.billing.copy;
    }

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

- (NSArray *)makeDisplayedCardBrands {
    NSMutableArray *cardBrands = [NSMutableArray new];
    for (id brand in AWXCardSupportedBrands()) {
        for (AWXCardScheme *cardScheme in _supportedCardSchemes) {
            if ([self cardBrandFromCardScheme:cardScheme] == [brand intValue]) {
                [cardBrands addObject:brand];
            }
        }
    }
    return cardBrands;
}

#pragma mark Data validation

- (AWXPlaceDetails *)validatedBillingDetails:(AWXPlaceDetails *)billing error:(NSString **)error {
    AWXPlaceDetails *validated = billing.copy;
    NSString *validationError = [validated validate];
    if (validationError != nil) {
        if (error != NULL) {
            *error = validationError;
        }

        return nil;
    } else {
        return validated;
    }
}

- (AWXCard *)validatedCardDetails:(AWXCard *)card error:(NSString **)error {
    NSString *validationError = [card validate];
    if (validationError != nil) {
        if (error != NULL) {
            *error = validationError;
        }

        return nil;
    } else {
        return card;
    }
}

- (NSString *)validationMessageFromCardNumber:(NSString *)cardNumber {
    if (cardNumber.length > 0) {
        if ([AWXCardValidator.sharedCardValidator isValidCardLength:cardNumber]) {
            NSString *cardName = [AWXCardValidator.sharedCardValidator brandForCardNumber:cardNumber].name;
            for (AWXCardScheme *cardScheme in _supportedCardSchemes) {
                if ([cardScheme.name isEqualToString:cardName.lowercaseString]) {
                    return NULL;
                }
            }
            return NSLocalizedString(@"Card not supported for payment", nil);
        }
        return NSLocalizedString(@"Card number is invalid", nil);
    }
    return NSLocalizedString(@"Card number is required", nil);
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

- (BOOL)confirmPaymentWithProvider:(AWXCardProvider *_Nonnull)provider
                           billing:(AWXPlaceDetails *)placeDetails
                              card:(AWXCard *)card
            shouldStoreCardDetails:(BOOL)storeCard
                             error:(NSString **)error {
    AWXPlaceDetails *validatedBilling;
    if (self.isBillingInformationRequired && placeDetails == nil) {
        if (error != NULL) {
            *error = NSLocalizedString(@"No billing address provided.", nil);
        }

        return NO;
    } else if (self.isBillingInformationRequired) {
        NSString *billingValidationError;
        validatedBilling = [self validatedBillingDetails:placeDetails error:&billingValidationError];
        if (validatedBilling == nil) {
            if (error != NULL && billingValidationError != nil) {
                *error = billingValidationError;
            }

            return NO;
        }
    }

    NSString *cardValidationError;
    AWXCard *validatedCard = [self validatedCardDetails:card error:&cardValidationError];
    if (validatedCard == nil) {
        if (error != NULL && cardValidationError != nil) {
            *error = cardValidationError;
        }

        return NO;
    }

    [provider confirmPaymentIntentWithCard:validatedCard billing:validatedBilling saveCard:storeCard];

    return YES;
}

- (void)updatePaymentIntentId:(NSString *)paymentIntentId {
    [self.session updateInitialPaymentIntentId:paymentIntentId];
}

#pragma mark Private helper

- (AWXBrandType)cardBrandFromCardScheme:(AWXCardScheme *)cardScheme {
    NSString *cardName = cardScheme.name;
    if ([cardName isEqualToString:@"amex"]) {
        return AWXBrandTypeAmex;
    } else if ([cardName isEqualToString:@"mastercard"]) {
        return AWXBrandTypeMastercard;
    } else if ([cardName isEqualToString:@"visa"]) {
        return AWXBrandTypeVisa;
    } else {
        return AWXBrandTypeUnknown;
    }
}

@end

//
//  AWXCardViewModel.h
//  Card
//
//  Created by Hector.Huang on 2022/9/14.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardScheme.h"
#import <Foundation/Foundation.h>

@class AWXCard;
@class AWXSession;
@class AWXAddress;
@class AWXPlaceDetails;
@class AWXCardProvider;
@class AWXConfirmPaymentNextAction;
@class AWXCountry;
@class AWXDefaultActionProvider;

@protocol AWXProviderDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface AWXCardViewModel : NSObject

@property (nonatomic, readonly) BOOL isReusingShippingAsBillingInformation;
@property (nonatomic, readonly) BOOL isBillingInformationRequired;
@property (nonatomic, readonly) BOOL isCardSavingEnabled;
@property (nonatomic, strong, readonly) AWXPlaceDetails *initialBilling;
@property (nonatomic, strong) AWXCountry *selectedCountry;
@property (nonatomic, copy, readonly) NSArray<AWXCardScheme *> *supportedCardSchemes;

- (instancetype)initWithSession:(AWXSession *)session supportedCardSchemes:(NSArray<AWXCardScheme *> *)cardSchemes;

- (BOOL)setReusesShippingAsBillingInformation:(BOOL)reusesShippingAsBillingInformation error:(NSString *_Nullable *_Nullable)error;

#pragma mark Data creation

- (AWXPlaceDetails *_Nullable)makeBillingWithFirstName:(NSString *_Nullable)firstName
                                              lastName:(NSString *_Nullable)lastName
                                                 email:(NSString *_Nullable)email
                                           phoneNumber:(NSString *_Nullable)phoneNumber
                                                 state:(NSString *_Nullable)state
                                                  city:(NSString *_Nullable)city
                                                street:(NSString *_Nullable)street
                                              postcode:(NSString *_Nullable)postcode;

- (AWXCard *)makeCardWithName:(NSString *)name
                       number:(NSString *)number
                       expiry:(NSString *)expiry
                          cvc:(NSString *)cvc;

- (NSArray *)makeDisplayedCardBrands;

- (NSString *)validationMessageFromCardNumber:(NSString *)cardNumber;

#pragma mark Payment

- (AWXCardProvider *)preparedProviderWithDelegate:(id<AWXProviderDelegate> _Nullable)delegate;
- (AWXDefaultActionProvider *)actionProviderForNextAction:(AWXConfirmPaymentNextAction *)nextAction
                                             withDelegate:(id<AWXProviderDelegate> _Nullable)delegate;

- (BOOL)confirmPaymentWithProvider:(AWXCardProvider *)provider
                           billing:(AWXPlaceDetails *_Nullable)placeDetails
                              card:(AWXCard *)card
            shouldStoreCardDetails:(BOOL)storeCard
                             error:(NSString *_Nullable *_Nullable)error;

- (void)updatePaymentIntentId:(NSString *)paymentIntentId;

@end

NS_ASSUME_NONNULL_END

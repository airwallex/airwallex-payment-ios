//
//  AWXCardViewModel.h
//  Card
//
//  Created by Hector.Huang on 2022/9/14.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardProvider.h"
#import "AWXCardScheme.h"
#import "AWXDefaultActionProvider.h"
#import "AWXUtils.h"

@class AWXCountry;
@protocol AWXProviderDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface AWXCardViewModel : NSObject

@property (nonatomic, copy, readonly) NSString *ctaTitle;
@property (nonatomic, copy, readonly) NSString *pageName;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *additionalInfo;
@property (nonatomic, readonly) BOOL isReusingShippingAsBillingInformation;
@property (nonatomic, readonly) BOOL isBillingInformationRequired;
@property (nonatomic, readonly) BOOL isCardSavingEnabled;
@property (nonatomic, strong, readonly) AWXPlaceDetails *initialBilling;
@property (nonatomic, strong, nullable) AWXCountry *selectedCountry;

/**
 Whether card payment is launched directly via public API or payment methods list has been skipped.
 */
@property (nonatomic, readonly) BOOL isLaunchedDirectly;

- (instancetype)initWithSession:(AWXSession *)session supportedCardSchemes:(NSArray<AWXCardScheme *> *_Nullable)cardSchemes launchDirectly:(BOOL)launchDirectly;

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

- (nullable NSString *)validationMessageFromCardNumber:(NSString *)cardNumber;

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

//
//  AWXCardViewModel.h
//  Card
//
//  Created by Hector.Huang on 2022/9/14.
//  Copyright © 2022 Airwallex. All rights reserved.
//

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

- (instancetype)initWithSession:(AWXSession *_Nonnull)session;

- (void)setReusesShippingAsBillingInformation:(BOOL)reusesShippingAsBillingInformation error:(NSString *_Nonnull *_Nonnull)error;

#pragma mark Data creation

- (AWXPlaceDetails *)makeBillingWithFirstName:(NSString *)firstName
                                     lastName:(NSString *)lastName
                                        email:(NSString *)email
                                  phoneNumber:(NSString *)phoneNumber
                                        state:(NSString *)state
                                         city:(NSString *)city
                                       street:(NSString *)street
                                     postcode:(NSString *)postcode;

- (AWXCard *)makeCardWithName:(NSString *)name
                       number:(NSString *)number
                       expiry:(NSString *)expiry
                          cvc:(NSString *)cvc;

#pragma mark Payment

- (AWXCardProvider *)preparedProviderWithDelegate:(id<AWXProviderDelegate> _Nullable)delegate;
- (AWXDefaultActionProvider *)actionProviderForNextAction:(AWXConfirmPaymentNextAction *)nextAction
                                             withDelegate:(id<AWXProviderDelegate> _Nullable)delegate;

- (BOOL)confirmPaymentWithProvider:(AWXCardProvider *_Nonnull)provider
                           billing:(AWXPlaceDetails *)placeDetails
                              card:(AWXCard *)card
            shouldStoreCardDetails:(BOOL)storeCard
                             error:(NSString *_Nonnull *_Nonnull)error;

- (void)updatePaymentIntentId:(NSString *)paymentIntentId;

@end

NS_ASSUME_NONNULL_END

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

@protocol AWXProviderDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface AWXCardViewModel : NSObject

@property (nonatomic, readonly) BOOL isReusingShippingAsBillingInformation;
@property (nonatomic, readonly) BOOL isBillingInformationRequired;

- (instancetype)initWithSession:(AWXSession *_Nonnull)session;

- (void)setReusesShippingAsBillingInformation:(BOOL)reusesShippingAsBillingInformation error:(NSError **)error;

#pragma mark Data creation

- (AWXCard *)makeCardWithName:(NSString *)name
                       number:(NSString *)number
                       expiry:(NSString *)expiry
                          cvc:(NSString *)cvc;

#pragma mark Payment

- (AWXCardProvider *)preparedProviderWithDelegate:(id<AWXProviderDelegate> _Nullable)delegate;
- (void)confirmPaymentWithProvider:(AWXCardProvider *_Nonnull)provider
                           billing:(AWXPlaceDetails *)placeDetails
                              card:(AWXCard *)card
            shouldStoreCardDetails:(BOOL)storeCard
                             error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

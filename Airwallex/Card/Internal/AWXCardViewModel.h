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

@property (nonatomic, readonly) BOOL isBillingInformationRequired;

- (instancetype)initWithSession:(AWXSession *_Nonnull)session;

#pragma mark Data validation

- (void)validateSessionBillingWithError:(NSError *_Nullable*)error;
- (void)validateBillingDetailsWithPlace:(AWXPlaceDetails *_Nonnull)placeDetails
                             andAddress:(AWXAddress *_Nonnull)addressDetails
                                  error:(NSError *_Nullable*)error;

- (void)validateCardWithName:(NSString *)name
                      number:(NSString *)number
                      expiry:(NSString *)expiry
                         cvc:(NSString *)cvc
                       error:(NSError **)error;

#pragma mark Payment

- (AWXCardProvider *)preparedProviderWithDelegate:(id<AWXProviderDelegate> _Nullable)delegate;
- (void)confirmPaymentWithProvider:(AWXCardProvider *_Nonnull)provider shouldStoreCardDetails:(BOOL)storeCard;

@end

NS_ASSUME_NONNULL_END

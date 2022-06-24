//
//  AirwallexExamplesKeys.h
//  Examples
//
//  Created by Victor Zhu on 2021/7/1.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Airwallex/Core.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kCachedEnvironment = @"kCachedEnvironment";
static NSString *const kCachedCheckoutMode = @"kCachedCheckoutMode";
static NSString *const kCachedNextTriggerBy = @"kCachedNextTriggerBy";
static NSString *const kCachedRequiresCVC = @"kCachedRequiresCVC";
static NSString *const kCachedAutoCapture = @"kCachedAutoCapture";
static NSString *const kCachedCustomerID = @"kCachedCustomerID";
static NSString *const kCachedApiKey = @"kCachedApiKey";
static NSString *const kCachedClientId = @"kCachedClientId";
static NSString *const kCachedAmount = @"kCachedAmount";
static NSString *const kCachedCurrency = @"kCachedCurrency";
static NSString *const kCachedCountryCode = @"kCachedCountryCode";
static NSString *const kCachedReturnURL = @"kCachedReturnURL";

typedef NS_ENUM(NSInteger, AirwallexCheckoutMode) {
    AirwallexCheckoutOneOffMode,
    AirwallexCheckoutRecurringMode,
    AirwallexCheckoutRecurringWithIntentMode
};

@interface AirwallexExamplesKeys : NSObject

@property (nonatomic) AirwallexSDKMode environment;
@property (nonatomic) AirwallexCheckoutMode checkoutMode;
@property (nonatomic) AirwallexNextTriggerByType nextTriggerByType;
@property (nonatomic) BOOL requireCVC;
@property (nonatomic) BOOL autoCapture;
@property (nonatomic, strong, nullable) NSString *customerId;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *returnUrl;

+ (instancetype)shared;
- (void)syncKeys;
- (void)resetKeys;

@end

NS_ASSUME_NONNULL_END

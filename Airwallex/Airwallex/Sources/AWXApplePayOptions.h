//
//  AWXApplePayOptions.h
//  Airwallex
//
//  Created by Jin Wang on 24/2/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PassKit;

NS_ASSUME_NONNULL_BEGIN

@interface AWXApplePayOptions : NSObject

/**
 Apple Pay merchant identifier. Must be one in the entitlement file.
 */
@property (nonatomic, copy) NSString *merchantIdentifier;

/**
 Apple Pay merchant capabilities. Default to 3DS, EMV, Credit and Debit.
 */
@property (nonatomic, assign) PKMerchantCapability merchantCapabilities;

@property (nonatomic, assign) PKShippingType shippingType;

@property (nonatomic, strong) NSSet <PKContactField> *requiredBillingContactFields;

@property (nonatomic, copy, nullable) NSString *totalPriceLabel;

@property (nonatomic, copy, nullable) NSSet <NSString *> *supportedCountries;

@property (nonatomic, strong, nullable) NSArray <PKShippingMethod *> *shippingMethods;

@property (nonatomic, strong, nullable) PKContact *shippingContact;

@property (nonatomic, strong, nullable) PKContact *billingContact;

- (instancetype)initWithMerchantIdentifier:(NSString *)merchantIdentifier;

@end

NS_ASSUME_NONNULL_END

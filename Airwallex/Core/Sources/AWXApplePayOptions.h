//
//  AWXApplePayOptions.h
//  Core
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXApplePayOptions : NSObject

/**
 Apple Pay merchant identifier.
 */
@property (nonatomic, copy) NSString *merchantIdentifier;

/**
 Apple Pay merchant capabilities. Default value includes 3DS, EMV, Credit and Debit.
 */
@property (nonatomic, assign) PKMerchantCapability merchantCapabilities;

/**
 How the item are to be shipped. Default value is PKShippingTypeShipping.
 */
@property (nonatomic, assign) PKShippingType shippingType;

/**
 The billing information that you require from the user in order to process the transaction. Default value is empty set.
 */
@property (nonatomic, strong) NSSet <PKContactField> *requiredBillingContactFields;

/**
 The shipping information that you require from the user in order to fulfill the order. Default value is empty set.
 */
@property (nonatomic, strong) NSSet <PKContactField> *requiredShippingContactFields;

/**
 Description of the total price. Default value is nil.
 */
@property (nonatomic, copy, nullable) NSString *totalPriceLabel;

/**
 A list of ISO 3166 country codes for limiting payments to cards from specific countries. Default value is null, meaning all countries are allowed.
 */
@property (nonatomic, copy, nullable) NSSet <NSString *> *supportedCountries;

/**
 A set of shipping method objects that describe the available shipping methods. Default value is nil.
 */
@property (nonatomic, strong, nullable) NSArray <PKShippingMethod *> *shippingMethods;

/**
 Shipping contact information for the user. Default value is nil.
 */
@property (nonatomic, strong, nullable) PKContact *shippingContact;

/**
 Billing contact information for the user. Default value is nil.
 */
@property (nonatomic, strong, nullable) PKContact *billingContact;

- (instancetype)initWithMerchantIdentifier:(NSString *)merchantIdentifier;

@end

NS_ASSUME_NONNULL_END

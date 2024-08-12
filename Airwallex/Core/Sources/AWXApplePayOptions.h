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

/**
 Object used to construct PKPaymentRequest for Apple Pay.
 */
@interface AWXApplePayOptions : NSObject

/**
 Apple Pay merchant identifier.
 */
@property (nonatomic, copy) NSString *merchantIdentifier;

/**
 The payment networks supported by the merchant, for example @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard].
 This property constrains payment cards that may fund the payment. Default value includes Visa, Mastercard, UnionPay, Amex, Discover and JCB.
 */
@property (nonatomic, copy) NSArray<PKPaymentNetwork> *supportedNetworks;

/**
 An additional array of payment summary item objects that summarize the amount of the payment. Default value is nil.

 The SDK will automatically construct a PKPaymentSummaryItem with the total amount from the session object and
 the label defined with the totalPriceLabel property. Please make sure the sum of all the items in the array equals the total amount
 you set on the session object.
 */
@property (nonatomic, copy, nullable) NSArray<PKPaymentSummaryItem *> *additionalPaymentSummaryItems;

/**
 Apple Pay merchant capabilities. Default value includes 3DS, EMV, Credit and Debit.
 */
@property (nonatomic, assign) PKMerchantCapability merchantCapabilities;

/**
 The billing information that you require from the user in order to process the transaction. Default value is empty set.
 */
@property (nonatomic, strong) NSSet<PKContactField> *requiredBillingContactFields;

/**
 A list of ISO 3166 country codes for limiting payments to cards from specific countries. Default value is null, meaning all countries are allowed.
 */
@property (nonatomic, copy, nullable) NSSet<NSString *> *supportedCountries;

/**
 Description of the total price. Default value is nil.
 */
@property (nonatomic, copy, nullable) NSString *totalPriceLabel;

- (instancetype)initWithMerchantIdentifier:(NSString *)merchantIdentifier;

@end

NS_ASSUME_NONNULL_END

//
//  AWXConstantsTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXConstants.h"
#import "AWXApplePayProvider.h"
#import "AWXCardProvider.h"
#import "AWXDefaultProvider.h"
#import "AWXPaymentMethod.h"
#import "AWXSchemaProvider.h"
#import <XCTest/XCTest.h>

#pragma mark - Sample providers for test purposes

@interface AWXConstantsTest : XCTestCase

@end

@implementation AWXConstantsTest

- (void)testFormatMerchantTriggerReason {
    XCTAssertNil(FormatMerchantTriggerReason(AirwallexMerchantTriggerReasonUndefined));
    XCTAssertEqualObjects(FormatMerchantTriggerReason(AirwallexMerchantTriggerReasonScheduled), @"scheduled");
    XCTAssertEqualObjects(FormatMerchantTriggerReason(AirwallexMerchantTriggerReasonUnscheduled), @"unscheduled");
}

- (void)testApplePayKey {
    XCTAssertEqualObjects(AWXApplePayKey, @"applepay");
}

- (void)testApplePaySupportedNetworks {
    XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkVisa]);
    XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkMasterCard]);
    XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkChinaUnionPay]);
    if (@available(iOS 12.0, *)) {
        XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkMaestro]);
    }
    XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkJCB]);
    XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkAmex]);
    XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkDiscover]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeApplePay {
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    type.name = @"applepay";

    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXApplePayProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeCard {
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    type.name = @"card";

    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXCardProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeSchema {
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    type.name = @"wechatpay";
    AWXResources *resources = [AWXResources new];
    resources.hasSchema = YES;
    type.resources = resources;

    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXSchemaProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeDefault {
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    type.name = @"somethingelse";
    AWXResources *resources = [AWXResources new];
    resources.hasSchema = NO;
    type.resources = resources;

    XCTAssertNil(ClassToHandleFlowForPaymentMethodType(type));
}

- (void)testCardBrands {
    XCTAssertEqualObjects(AWXCardBrandVisa, @"visa");
    XCTAssertEqualObjects(AWXCardBrandAmex, @"amex");
    XCTAssertEqualObjects(AWXCardBrandMastercard, @"mastercard");
    XCTAssertEqualObjects(AWXCardBrandDiscover, @"discover");
    XCTAssertEqualObjects(AWXCardBrandJCB, @"jcb");
    XCTAssertEqualObjects(AWXCardBrandDinersClub, @"diners");
    XCTAssertEqualObjects(AWXCardBrandUnionPay, @"unionpay");
}

@end

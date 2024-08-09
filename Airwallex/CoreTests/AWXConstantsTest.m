//
//  AWXConstantsTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXConstants.h"
#import "AWXDefaultProvider.h"
#import "AWXPaymentMethod.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#pragma mark - Sample providers for test purposes

@interface AWXApplePayProvider : AWXDefaultProvider
@end

@implementation AWXApplePayProvider
@end

@interface AWXCardProvider : AWXDefaultProvider
@end

@implementation AWXCardProvider
@end

@interface AWXSchemaProvider : AWXDefaultProvider
@end

@implementation AWXSchemaProvider
@end

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
}

- (void)testClassToHandleFlowForPaymentMethodTypeApplePay {
    AWXPaymentMethodType *type = [[AWXPaymentMethodType alloc] initWithName:@"applepay" displayName:nil transactionMode:nil flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil];

    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXApplePayProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeCard {
    AWXPaymentMethodType *type = [[AWXPaymentMethodType alloc] initWithName:@"card" displayName:nil transactionMode:nil flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil];

    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXCardProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeSchema {
    AWXResources *resources = [AWXResources new];
    resources.hasSchema = YES;
    AWXPaymentMethodType *type = [[AWXPaymentMethodType alloc] initWithName:@"wechatpay" displayName:nil transactionMode:nil flows:nil transactionCurrencies:nil active:NO resources:resources cardSchemes:nil];

    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXSchemaProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeDefault {
    AWXResources *resources = [AWXResources new];
    resources.hasSchema = NO;
    AWXPaymentMethodType *type = [[AWXPaymentMethodType alloc] initWithName:@"somethingelse" displayName:nil transactionMode:nil flows:nil transactionCurrencies:nil active:NO resources:resources cardSchemes:nil];

    XCTAssertNil(ClassToHandleFlowForPaymentMethodType(type));
}

@end

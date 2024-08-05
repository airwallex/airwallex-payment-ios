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
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    id mockType = OCMPartialMock(type);
    OCMStub([mockType name]).andReturn(@"applepay");

    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(mockType), [AWXApplePayProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeCard {
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    [type setValue:@"card" forKey:@"name"];

    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXCardProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeSchema {
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    [type setValue:@"wechatpay" forKey:@"name"];
    AWXResources *resources = [AWXResources new];
    resources.hasSchema = YES;
    [type setValue:resources forKey:@"resources"];

    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXSchemaProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeDefault {
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    [type setValue:@"somethingelse" forKey:@"name"];
    AWXResources *resources = [AWXResources new];
    resources.hasSchema = NO;
    [type setValue:resources forKey:@"resources"];

    XCTAssertNil(ClassToHandleFlowForPaymentMethodType(type));
}

@end

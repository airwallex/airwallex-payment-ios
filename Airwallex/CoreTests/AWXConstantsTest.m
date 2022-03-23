//
//  AWXConstantsTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXConstants.h"
#import "AWXPaymentMethod.h"
#import "AWXDefaultProvider.h"

# pragma mark - Sample providers for test purposes

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

- (void)testClassToHandleFlowForPaymentMethodTypeApplePay
{
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    type.name = @"applepay";
    
    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXApplePayProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeCard
{
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    type.name = @"card";
    
    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXCardProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeSchema
{
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    type.name = @"wechatpay";
    AWXResources *resources = [AWXResources new];
    resources.hasSchema = YES;
    type.resources = resources;
    
    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXSchemaProvider class]);
}

- (void)testClassToHandleFlowForPaymentMethodTypeDefault
{
    AWXPaymentMethodType *type = [AWXPaymentMethodType new];
    type.name = @"somethingelse";
    AWXResources *resources = [AWXResources new];
    resources.hasSchema = NO;
    type.resources = resources;
    
    XCTAssertEqualObjects(ClassToHandleFlowForPaymentMethodType(type), [AWXDefaultProvider class]);
}

@end

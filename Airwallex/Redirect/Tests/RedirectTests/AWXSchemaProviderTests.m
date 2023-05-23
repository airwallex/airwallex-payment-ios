//
//  AWXSchemaProviderTests.m
//  RedirectTests
//
//  Created by Hector.Huang on 2023/6/13.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXFormMapping.h"
#import "AWXPaymentFormViewController.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXSchemaProvider.h"
#import "AWXSession.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXSchemaProviderTests : XCTestCase

@property (nonatomic, weak) id<AWXProviderDelegate> delegate;

@end

@implementation AWXSchemaProviderTests

- (void)setUp {
    id spy = OCMClassMock([AWXProviderDelegateSpy class]);
    self.delegate = spy;
}

- (void)testHandleFlowWhenBankListEmpty {
    AWXSchemaProvider *provider = [self createProvider:NO];
    [provider handleFlow];
    OCMVerify(times(1), [_delegate provider:provider shouldPresentViewController:[OCMArg isKindOfClass:[AWXPaymentFormViewController class]] forceToDismiss:NO withAnimation:NO]);
}

- (void)testHandleFlowWhenBankListNotEmpty {
    AWXSchemaProvider *provider = [self createProvider:YES];
    [provider handleFlow];
    OCMVerify(times(1), [_delegate provider:provider
                            shouldPresentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                                AWXPaymentFormViewController *controller = (AWXPaymentFormViewController *)obj;
                                XCTAssertEqualObjects(controller.formMapping.title, @"Select your bank");
                                return true;
                            }]
                                         forceToDismiss:NO
                                          withAnimation:NO]);
}

- (AWXSchemaProvider *)createProvider:(BOOL)hasBanks {
    AWXSession *session = [AWXSession new];
    AWXPaymentMethodType *paymentMethod = [AWXPaymentMethodType new];
    AWXSchemaProvider *provider = [[AWXSchemaProvider alloc] initWithDelegate:_delegate session:session paymentMethodType:paymentMethod];

    id apiClientMock = OCMClassMock([AWXAPIClient class]);
    OCMStub([apiClientMock initWithConfiguration:[OCMArg any]]).andReturn(apiClientMock);
    OCMStub([apiClientMock alloc]).andReturn(apiClientMock);

    AWXField *textField = [AWXField new];
    textField.uiType = @"text";
    AWXField *banksField = [AWXField new];
    banksField.type = @"banks";
    banksField.uiType = @"logo_list";
    AWXSchema *schema = [AWXSchema new];
    schema.transactionMode = @"oneoff";
    schema.fields = @[banksField, textField];

    AWXGetPaymentMethodTypeResponse *response = [AWXGetPaymentMethodTypeResponse new];
    response.schemas = @[schema];
    OCMStub([apiClientMock send:[OCMArg isKindOfClass:[AWXGetPaymentMethodTypeRequest class]] handler:([OCMArg invokeBlockWithArgs:response, [NSNull null], nil])]);

    AWXResponse *banksResponse;
    if (hasBanks) {
        NSDictionary *dictionary = @{
            @"items": @[@{@"bank_name": @"CBA"}]
        };
        NSData *bankData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
        banksResponse = [AWXGetAvailableBanksResponse parse:bankData];
    } else {
        banksResponse = [AWXGetAvailableBanksResponse new];
    }
    OCMStub([apiClientMock send:[OCMArg isKindOfClass:[AWXGetAvailableBanksRequest class]] handler:([OCMArg invokeBlockWithArgs:banksResponse, [NSNull null], nil])]);
    return provider;
}

@end

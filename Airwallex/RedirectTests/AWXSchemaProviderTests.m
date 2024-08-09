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

- (void)testHandleFlowWhenFailed {
    AWXSchemaProvider *provider = [self createProvider:NO];

    id apiClientMock = OCMClassMock([AWXAPIClient class]);
    OCMStub([apiClientMock initWithConfiguration:[OCMArg any]]).andReturn(apiClientMock);
    OCMStub([apiClientMock alloc]).andReturn(apiClientMock);

    AWXGetPaymentMethodTypeResponse *response = [AWXGetPaymentMethodTypeResponse new];

    NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"error."}];
    OCMStub([apiClientMock send:[OCMArg isKindOfClass:[AWXGetPaymentMethodTypeRequest class]] handler:([OCMArg invokeBlockWithArgs:response, error, nil])]);

    [provider handleFlow];

    OCMVerify(times(1), [_delegate providerDidEndRequest:provider]);
    OCMVerify(times(1), [_delegate provider:provider didCompleteWithStatus:AirwallexPaymentStatusFailure error:error]);
}

- (void)testHandleFlowWhenSchemasIsEmpty {
    AWXSchemaProvider *provider = [self createProvider:NO];

    id apiClientMock = OCMClassMock([AWXAPIClient class]);
    OCMStub([apiClientMock initWithConfiguration:[OCMArg any]]).andReturn(apiClientMock);
    OCMStub([apiClientMock alloc]).andReturn(apiClientMock);

    AWXGetPaymentMethodTypeResponse *response = [AWXGetPaymentMethodTypeResponse new];
    response.schemas = @[];

    OCMStub([apiClientMock send:[OCMArg isKindOfClass:[AWXGetPaymentMethodTypeRequest class]] handler:([OCMArg invokeBlockWithArgs:response, [NSNull null], nil])]);

    [provider handleFlow];

    OCMVerify(times(1), [_delegate providerDidEndRequest:provider]);
    OCMVerify(times(1), [_delegate provider:provider didCompleteWithStatus:AirwallexPaymentStatusFailure error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid schema.", nil)}]]);
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

- (void)testHandleFlowWhenBankListEmptyUIFieldsNotEmpty {
    AWXSchemaProvider *provider = [self createProvider:YES];
    [provider handleFlow];
    AWXField *textField = [AWXField new];
    textField.uiType = @"text";
    AWXSchema *schema = [AWXSchema new];
    schema.transactionMode = @"oneoff";
    schema.fields = @[textField];

    AWXGetPaymentMethodTypeResponse *response = [AWXGetPaymentMethodTypeResponse new];
    response.schemas = @[schema];

    OCMVerify(times(1), [_delegate providerDidEndRequest:provider]);
}

- (AWXSchemaProvider *)createProvider:(BOOL)hasBanks {
    AWXSession *session = [AWXSession new];
    AWXPaymentMethodType *paymentMethod = [[AWXPaymentMethodType alloc] initWithName:nil displayName:nil transactionMode:nil flows:nil transactionCurrencies:nil active:NO resources:nil cardSchemes:nil];
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

//
//  AWXPaymentMethodListViewModelTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2023/12/14.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodListViewModel.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXTestUtils.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXPaymentMethodListViewModelTest : XCTestCase

@property (nonatomic, strong) AWXAPIClient *mockClient;

@end

@implementation AWXPaymentMethodListViewModelTest

- (void)testFetchAvailablePaymentMethodsAndConsents {
    AWXPaymentMethodListViewModel *viewModel = [self mockViewModel];
    NSData *methodsData = [NSJSONSerialization dataWithJSONObject:[AWXTestUtils jsonNamed:@"PaymentMethodTypes"] options:0 error:nil];
    NSData *consentsData = [NSJSONSerialization dataWithJSONObject:[AWXTestUtils jsonNamed:@"PaymentConsents"] options:0 error:nil];
    AWXResponse *methodsResponse = [AWXGetPaymentMethodTypesResponse parse:methodsData];
    AWXResponse *consentsResponse = [AWXGetPaymentConsentsResponse parse:consentsData];

    OCMStub([_mockClient send:[OCMArg isKindOfClass:[AWXGetPaymentMethodTypesRequest class]] handler:([OCMArg invokeBlockWithArgs:methodsResponse, [NSNull null], nil])]);
    OCMStub([_mockClient send:[OCMArg isKindOfClass:[AWXGetPaymentConsentsRequest class]] handler:([OCMArg invokeBlockWithArgs:consentsResponse, [NSNull null], nil])]);

    [viewModel fetchAvailablePaymentMethodsAndConsentsWithCompletionHandler:^(NSArray<AWXPaymentMethodType *> *_Nonnull methods, NSArray<AWXPaymentConsent *> *_Nonnull consents, NSError *_Nullable error) {
        XCTAssertEqual(methods.count, 5);
        XCTAssertEqualObjects(methods.firstObject.name, @"card");
        XCTAssertEqualObjects(methods.lastObject.name, @"klarna");
        XCTAssertEqual(consents.count, 1);
        XCTAssertEqualObjects(consents.firstObject.paymentMethod.card.numberType, @"PAN");
    }];
}

- (void)testFetchAvailablePaymentMethodsAndConsentsWhenMethodsError {
    AWXPaymentMethodListViewModel *viewModel = [self mockViewModel];
    NSError *error = [[NSError alloc] initWithDomain:@"airwallex" code:100 userInfo:@{@"message": @"something"}];
    OCMStub([_mockClient send:[OCMArg isKindOfClass:[AWXGetPaymentMethodTypesRequest class]] handler:([OCMArg invokeBlockWithArgs:[NSNull null], error, nil])]);

    [viewModel fetchAvailablePaymentMethodsAndConsentsWithCompletionHandler:^(NSArray<AWXPaymentMethodType *> *_Nonnull methods, NSArray<AWXPaymentConsent *> *_Nonnull consents, NSError *_Nullable responseError) {
        XCTAssertEqual(responseError, error);
    }];
}

- (void)testFetchAvailablePaymentMethodsAndConsentsWhenConsentsError {
    AWXPaymentMethodListViewModel *viewModel = [self mockViewModel];
    NSError *error = [[NSError alloc] initWithDomain:@"airwallex" code:100 userInfo:@{@"message": @"something"}];
    OCMStub([_mockClient send:[OCMArg isKindOfClass:[AWXGetPaymentConsentsRequest class]] handler:([OCMArg invokeBlockWithArgs:[NSNull null], error, nil])]);

    [viewModel fetchAvailablePaymentMethodsAndConsentsWithCompletionHandler:^(NSArray<AWXPaymentMethodType *> *_Nonnull methods, NSArray<AWXPaymentConsent *> *_Nonnull consents, NSError *_Nullable responseError) {
        XCTAssertEqual(responseError, error);
    }];
}

- (AWXPaymentMethodListViewModel *)mockViewModel {
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    session.paymentIntent = intent;
    intent.customerId = @"customerId";
    self.mockClient = OCMClassMock([AWXAPIClient class]);

    return [[AWXPaymentMethodListViewModel alloc] initWithSession:session APIClient:_mockClient];
}

@end

//
//  AWXPaymentFormViewModelTest.m
//  RedirectTests
//
//  Created by Hector.Huang on 2022/7/5.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentFormViewModel.h"
#import "AWXSession.h"
#import <XCTest/XCTest.h>

@interface AWXPaymentFormViewModelTests : XCTestCase

@end

@implementation AWXPaymentFormViewModelTests

- (void)testPrefixWithCountryCodeAndCurrency {
    AWXPaymentIntent *intent = [self dummyPaymentIntent];

    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"HK";
    session.paymentIntent = intent;

    AWXPaymentFormViewModel *viewModel = [[AWXPaymentFormViewModel alloc] initWithSession:session];
    XCTAssertEqualObjects(viewModel.phonePrefix, @"+852");
}

- (void)testPrefixWithCurrency {
    AWXPaymentIntent *intent = [self dummyPaymentIntent];
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.paymentIntent = intent;

    AWXPaymentFormViewModel *viewModel = [[AWXPaymentFormViewModel alloc] initWithSession:session];
    XCTAssertEqualObjects(viewModel.phonePrefix, @"+65");
}

- (void)testPrefixWithCountryCode {
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"TH";

    AWXPaymentFormViewModel *viewModel = [[AWXPaymentFormViewModel alloc] initWithSession:session];
    XCTAssertEqualObjects(viewModel.phonePrefix, @"+66");
}

- (void)testPrefixWithInvalidCountryCode {
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"ABC";

    AWXPaymentFormViewModel *viewModel = [[AWXPaymentFormViewModel alloc] initWithSession:session];
    XCTAssertNil(viewModel.phonePrefix);
}

- (void)testPrefixWithoutCountryCodeAndCurrency {
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXPaymentFormViewModel *viewModel = [[AWXPaymentFormViewModel alloc] initWithSession:session];
    XCTAssertNil(viewModel.phonePrefix);
}

- (AWXPaymentIntent *)dummyPaymentIntent {
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    intent.currency = @"SGD";
    return intent;
}

@end

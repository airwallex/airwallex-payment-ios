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

    AWXPaymentFormViewModel *viewModel = [self viewModelWithSession:session];
    XCTAssertEqualObjects(viewModel.phonePrefix, @"+852");
}

- (void)testPrefixWithCurrency {
    AWXPaymentIntent *intent = [self dummyPaymentIntent];
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.paymentIntent = intent;

    AWXPaymentFormViewModel *viewModel = [self viewModelWithSession:session];
    XCTAssertEqualObjects(viewModel.phonePrefix, @"+65");
}

- (void)testPrefixWithCountryCode {
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"TH";

    AWXPaymentFormViewModel *viewModel = [self viewModelWithSession:session];
    XCTAssertEqualObjects(viewModel.phonePrefix, @"+66");
}

- (void)testPrefixWithInvalidCountryCode {
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"ABC";

    AWXPaymentFormViewModel *viewModel = [self viewModelWithSession:session];
    XCTAssertNil(viewModel.phonePrefix);
}

- (void)testPrefixWithoutCountryCodeAndCurrency {
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXPaymentFormViewModel *viewModel = [self viewModelWithSession:session];
    XCTAssertNil(viewModel.phonePrefix);
}

- (void)testPageViewTracking {
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = @"card";
    AWXFormMapping *formMapping = [AWXFormMapping new];
    formMapping.title = @"bank list";
    AWXPaymentFormViewModel *viewModel = [[AWXPaymentFormViewModel alloc] initWithSession:[AWXOneOffSession new] paymentMethod:paymentMethod formMapping:formMapping];
    NSDictionary *dict = @{@"formTitle": @"bank list", @"paymentMethod": @"card"};
    XCTAssertEqualObjects(viewModel.pageName, @"payment_info_sheet");
    XCTAssertEqualObjects(viewModel.additionalInfo, dict);
}

- (AWXPaymentIntent *)dummyPaymentIntent {
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    intent.currency = @"SGD";
    return intent;
}

- (AWXPaymentFormViewModel *)viewModelWithSession:(AWXSession *)session {
    return [[AWXPaymentFormViewModel alloc] initWithSession:session paymentMethod:[AWXPaymentMethod new] formMapping:[AWXFormMapping new]];
}

@end

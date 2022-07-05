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

@interface AWXPaymentFormViewModelTest : XCTestCase

@end

@implementation AWXPaymentFormViewModelTest

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

- (AWXPaymentIntent *)dummyPaymentIntent {
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    intent.currency = @"SGD";
    return intent;
}

@end

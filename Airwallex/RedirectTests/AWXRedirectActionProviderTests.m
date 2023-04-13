//
//  AWXRedirectActionProviderTests.m
//  RedirectTests
//
//  Created by Hector.Huang on 2023/3/21.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXAnalyticsLogger.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXRedirectActionProvider.h"
#import "AWXSession.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXRedirectActionProviderTests : XCTestCase

@property (nonatomic, strong) id logger;
@property (nonatomic, strong) id app;

@end

@implementation AWXRedirectActionProviderTests

- (void)setUp {
    id mockLogger = OCMClassMock([AWXAnalyticsLogger class]);
    self.logger = mockLogger;
    OCMStub([mockLogger shared]).andReturn(mockLogger);

    id mockApp = OCMClassMock([UIApplication class]);
    self.app = mockApp;
    OCMStub([mockApp sharedApplication]).andReturn(mockApp);
}

- (void)testPageViewTracking {
    OCMStub([_app openURL:[OCMArg any] options:[OCMArg any] completionHandler:([OCMArg invokeBlockWithArgs:@YES, nil])]);

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXRedirectActionProvider *provider = [[AWXRedirectActionProvider alloc] initWithDelegate:delegate session:[AWXOneOffSession new]];
    AWXConfirmPaymentNextAction *nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:[self testDictionary]];

    [provider handleNextAction:nextAction];
    OCMVerify(times(1), [_logger logPageViewWithName:@"payment_redirect" additionalInfo:[self testDictionary]]);
}

- (void)testErrorLogging {
    OCMStub([_app openURL:[OCMArg any] options:[OCMArg any] completionHandler:([OCMArg invokeBlockWithArgs:@NO, nil])]);

    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    AWXRedirectActionProvider *provider = [[AWXRedirectActionProvider alloc] initWithDelegate:delegate session:[AWXOneOffSession new]];
    AWXConfirmPaymentNextAction *nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:[self testDictionary]];

    [provider handleNextAction:nextAction];
    OCMVerify(times(1), [_logger logErrorWithName:@"payment_redirect" additionalInfo:[self testDictionary]]);
}

- (NSDictionary *)testDictionary {
    return @{@"url": @"http://abc.net"};
}

@end

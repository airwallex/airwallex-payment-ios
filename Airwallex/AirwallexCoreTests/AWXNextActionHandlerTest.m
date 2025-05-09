//
//  AWXNextActionHandlerTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2024/3/29.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "AWXNextActionHandler.h"
#import "AWXDefaultActionProvider.h"
#import "AWXProviderDelegateSpy.h"
#import "AWXSession.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXNextActionHandlerTest : XCTestCase

@end

@implementation AWXNextActionHandlerTest

- (void)testHandleNextActionWhenHasActionProvider {
    id mockProvider = OCMClassMock([AWXDefaultActionProvider class]);

    OCMStub([mockProvider initWithDelegate:[OCMArg any] session:[OCMArg any]]).andReturn(mockProvider);
    OCMStub([mockProvider alloc]).andReturn(mockProvider);

    AWXProviderDelegateSpy *spy = [AWXProviderDelegateSpy new];
    AWXOneOffSession *session = [AWXOneOffSession new];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"next", @"type", nil];
    AWXConfirmPaymentNextAction *nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:dict];

    AWXNextActionHandler *handler = [[AWXNextActionHandler alloc] initWithDelegate:spy session:session];
    [handler handleNextAction:nextAction];
    OCMVerify(times(1), [mockProvider handleNextAction:nextAction]);
}

- (void)testHandleNextActionWhenNoActionProvider {
    AWXProviderDelegateSpy *delegate = [AWXProviderDelegateSpy new];
    id mockViewController = OCMClassMock([UIViewController class]);
    delegate.hostVC = mockViewController;
    AWXOneOffSession *session = [AWXOneOffSession new];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"call_sdk", @"type", nil];
    AWXConfirmPaymentNextAction *nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:dict];

    AWXNextActionHandler *handler = [[AWXNextActionHandler alloc] initWithDelegate:delegate session:session];
    [handler handleNextAction:nextAction];
    XCTAssertEqual(delegate.providerDidCompleteWithStatusCount, 1);
    XCTAssertEqual(delegate.lastStatus, AirwallexPaymentStatusFailure);
    XCTAssertNotNil(delegate.lastStatusError);
}

@end

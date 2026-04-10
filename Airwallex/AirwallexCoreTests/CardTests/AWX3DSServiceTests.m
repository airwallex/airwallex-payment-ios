//
//  AWX3DSServiceTests.m
//  AirwallexCoreTests
//
//  Created by Weiping Li on 2026/4/2.
//  Copyright © 2026 Airwallex. All rights reserved.
//

#import "AWX3DSService.h"
#import "AWXConstants.h"
#import "AWXPaymentIntentResponse.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWX3DSService (Testing)
- (void)confirmWithAcsResponse:(NSString *)acsResponse;
@end

@interface AWX3DSServiceTests : XCTestCase

@property (nonatomic, strong) AWX3DSService *service;
@property (nonatomic, strong) id mockDelegate;

@end

@implementation AWX3DSServiceTests

- (void)setUp {
    [super setUp];
    self.service = [AWX3DSService new];
    self.mockDelegate = OCMStrictProtocolMock(@protocol(AWX3DSServiceDelegate));
    self.service.delegate = self.mockDelegate;
}

- (void)tearDown {
    self.service = nil;
    self.mockDelegate = nil;
    [super tearDown];
}

#pragma mark - handleWebResponsePayload:error:

- (void)testHandleWebResponse_withPayload_confirmsAcsResponse {
    // When payload is non-nil, confirmWithAcsResponse: should be called.
    // Since confirmWithAcsResponse: makes a network request, we use a partial mock
    // to verify it's called without actually sending the request.
    id partialMock = OCMPartialMock(self.service);
    OCMExpect([partialMock confirmWithAcsResponse:@"test_payload"]);

    [self.service handleWebResponsePayload:@"test_payload" error:nil];

    OCMVerifyAll(partialMock);
    [partialMock stopMocking];
}

- (void)testHandleWebResponse_withCancelError_callsDidCancel {
    NSError *cancelError = [NSError errorWithDomain:AWXSDKErrorDomain
                                               code:AWXSDKErrorCodeUserCancelled
                                           userInfo:@{NSLocalizedDescriptionKey: @"3DS has been cancelled by user."}];

    OCMExpect([self.mockDelegate threeDSServiceDidCancel:self.service]);

    [self.service handleWebResponsePayload:nil error:cancelError];

    OCMVerifyAll(self.mockDelegate);
}

- (void)testHandleWebResponse_withOtherError_callsDidFinishWithError {
    NSError *otherError = [NSError errorWithDomain:AWXSDKErrorDomain
                                              code:-1
                                          userInfo:@{NSLocalizedDescriptionKey: @"Unknown issue."}];

    OCMExpect([self.mockDelegate threeDSService:self.service didFinishWithResponse:nil error:otherError]);

    [self.service handleWebResponsePayload:nil error:otherError];

    OCMVerifyAll(self.mockDelegate);
}

- (void)testHandleWebResponse_withNilPayloadAndNilError_callsDidFinishWithNilError {
    OCMExpect([self.mockDelegate threeDSService:self.service didFinishWithResponse:nil error:nil]);

    [self.service handleWebResponsePayload:nil error:nil];

    OCMVerifyAll(self.mockDelegate);
}

- (void)testHandleWebResponse_withNonAirwallexDomainCancelCode_callsDidFinishWithError {
    // Cancel error code but wrong domain — should NOT be treated as cancel
    NSError *wrongDomainError = [NSError errorWithDomain:@"com.other.domain"
                                                    code:AWXSDKErrorCodeUserCancelled
                                                userInfo:@{NSLocalizedDescriptionKey: @"Not our cancel"}];

    OCMExpect([self.mockDelegate threeDSService:self.service didFinishWithResponse:nil error:wrongDomainError]);

    [self.service handleWebResponsePayload:nil error:wrongDomainError];

    OCMVerifyAll(self.mockDelegate);
}

@end

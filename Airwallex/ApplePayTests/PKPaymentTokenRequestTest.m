//
//  PKPaymentTokenRequestTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "PKPaymentMethod+Request.h"
#import "PKPaymentToken+Request.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface PKPaymentTokenRequestTest : XCTestCase

@end

@implementation PKPaymentTokenRequestTest

- (void)testPayloadForRequest {
    PKPaymentToken *token = [PKPaymentToken new];
    id tokenMock = OCMPartialMock(token);

    NSString *ephemeralPublicKey = @"ephemeralPublicKey";
    NSString *publicKeyHash = @"publicKeyHash";
    NSString *transactionID = @"transactionId";
    NSString *data = @"data";
    NSString *version = @"version";
    NSString *signature = @"signature";

    NSDictionary *dictionary = @{
        @"header": @{
            @"ephemeralPublicKey": ephemeralPublicKey,
            @"publicKeyHash": publicKeyHash,
            @"transactionId": transactionID
        },
        @"data": data,
        @"version": version,
        @"signature": signature
    };

    NSData *paymentData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];

    OCMStub([tokenMock paymentData]).andReturn(paymentData);

    PKPaymentMethod *method = OCMClassMock([PKPaymentMethod class]);

    NSString *network = @"visa";
    NSString *type = @"debit";

    OCMStub([tokenMock paymentMethod]).andReturn(method);
    OCMStub([method network]).andReturn(network);
    OCMStub([method typeNameForRequest]).andReturn(type);

    NSDictionary *payload = [token payloadForRequestWithBilling:nil orError:nil];

    NSDictionary *expectedPayload = @{
        @"card_brand": network,
        @"card_type": type,
        @"data": data,
        @"ephemeral_public_key": ephemeralPublicKey,
        @"public_key_hash": publicKeyHash,
        @"transaction_id": transactionID,
        @"signature": signature,
        @"version": version
    };

    XCTAssertEqualObjects(payload, expectedPayload);

    NSDictionary *billingPayload = @{@"key": @"value"};
    NSDictionary *payloadWithBilling = [token payloadForRequestWithBilling:billingPayload orError:nil];

    NSMutableDictionary *expectedPayloadWithBilling = [NSMutableDictionary dictionaryWithDictionary:expectedPayload];
    expectedPayloadWithBilling[@"billing"] = billingPayload;

    XCTAssertEqualObjects(payloadWithBilling, expectedPayloadWithBilling);
}

- (void)testPayloadForRequestWithError {
    PKPaymentToken *token = [PKPaymentToken new];
    id tokenMock = OCMPartialMock(token);

    NSData *paymentData = [@"invalidJSON" dataUsingEncoding:NSUTF8StringEncoding];
    OCMStub([tokenMock paymentData]).andReturn(paymentData);

    NSError *error;
    NSDictionary *payload = [token payloadForRequestWithBilling:nil orError:&error];

    XCTAssertNil(payload);
    XCTAssertNotNil(error);
}

@end

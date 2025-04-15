//
//  PKContactRequestTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 13/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "PKContact+Request.h"
#import <PassKit/PassKit.h>
#import <XCTest/XCTest.h>

@interface PKContactRequestTest : XCTestCase

@end

@implementation PKContactRequestTest

- (void)testPayloadForRequest {
    PKContact *contact = [PKContact new];
    contact.emailAddress = @"email@address.com";

    NSPersonNameComponents *nameComponents = [NSPersonNameComponents new];
    nameComponents.givenName = @"firstName";
    nameComponents.familyName = @"lastName";
    contact.name = nameComponents;
    contact.phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:@"12345678"];

    CNMutablePostalAddress *address = [CNMutablePostalAddress new];
    address.ISOCountryCode = @"AU";
    address.city = @"Melbourne";
    address.postalCode = @"3008";
    address.state = @"VIC";
    address.street = @"Name St.";

    contact.postalAddress = address;

    NSDictionary *payload = [contact payloadForRequest];
    NSDictionary *expected = @{
        @"email": @"email@address.com",
        @"first_name": @"firstName",
        @"last_name": @"lastName",
        @"phone_number": @"12345678",
        @"address": @{
            @"country_code": @"AU",
            @"city": @"Melbourne",
            @"postcode": @"3008",
            @"state": @"VIC",
            @"street": @"Name St."
        }
    };

    XCTAssertEqualObjects(payload, expected);
}

- (void)testPayloadForRequestWithPartialNilValues {
    PKContact *contact = [PKContact new];

    NSPersonNameComponents *nameComponents = [NSPersonNameComponents new];
    nameComponents.givenName = nil;
    nameComponents.familyName = @"lastName";
    contact.name = nameComponents;

    CNMutablePostalAddress *address = [CNMutablePostalAddress new];
    address.ISOCountryCode = @"";
    address.city = @"";
    address.postalCode = @"";
    address.state = @"";
    address.street = @"";

    contact.postalAddress = address;

    NSDictionary *payload = [contact payloadForRequest];
    NSDictionary *expected = @{
        @"last_name": @"lastName",
        @"address": @{
            @"country_code": @"",
            @"city": @"",
            @"postcode": @"",
            @"state": @"",
            @"street": @""
        }
    };

    XCTAssertEqualObjects(payload, expected);
}

- (void)testPayloadForRequestWithAllNilValues {
    PKContact *contact = [PKContact new];
    NSDictionary *payload = [contact payloadForRequest];
    NSDictionary *expected = @{};

    XCTAssertEqualObjects(payload, expected);
}

@end

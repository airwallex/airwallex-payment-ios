//
//  AWXPlaceDetailsPKContactTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 13/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "PassKit/PKContact.h"
#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <ApplePay/ApplePay-Swift.h>
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXPlaceDetailsPKContactTest : XCTestCase

@end

@implementation AWXPlaceDetailsPKContactTest

- (void)testConvertToPaymentContact {
    AWXAddress *address = [[AWXAddress alloc] initWithCountryCode:@"AU" city:@"Melbourne" street:@"Name St." state:@"VIC" postcode:@"3000"];
    AWXPlaceDetails *details = [[AWXPlaceDetails alloc] initWithFirstName:@"firstName" lastName:@"lastName" email:nil dateOfBirth:nil phoneNumber:nil address:address];

    PKContact *contact = [details convertToPaymentContact];

    XCTAssertEqual(contact.name.givenName, @"firstName");
    XCTAssertEqual(contact.name.familyName, @"lastName");
    XCTAssertEqual(contact.postalAddress.ISOCountryCode, @"AU");
    XCTAssertEqual(contact.postalAddress.city, @"Melbourne");
    XCTAssertEqual(contact.postalAddress.street, @"Name St.");
    XCTAssertEqualObjects(contact.postalAddress.state, @"VIC");
    XCTAssertEqualObjects(contact.postalAddress.postalCode, @"3000");
    XCTAssertNil(contact.emailAddress);
    XCTAssertNil(contact.phoneNumber);
}

@end

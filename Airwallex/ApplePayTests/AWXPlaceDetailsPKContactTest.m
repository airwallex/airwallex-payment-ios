//
//  AWXPlaceDetailsPKContactTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 13/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXPlaceDetails+PKContact.h"

@interface AWXPlaceDetailsPKContactTest : XCTestCase

@end

@implementation AWXPlaceDetailsPKContactTest

- (void)testConvertToPaymentContact {
    AWXPlaceDetails *details = [AWXPlaceDetails new];
    details.firstName = @"firstName";
    details.lastName = @"lastName";
    
    details.email = nil;
    details.phoneNumber = nil;
    
    AWXAddress *address = [AWXAddress new];
    address.countryCode = @"AU";
    address.city = @"Melbourne";
    address.street = @"Name St.";
    address.state = @"VIC";
    address.postcode = @"3000";
    
    details.address = address;
    
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

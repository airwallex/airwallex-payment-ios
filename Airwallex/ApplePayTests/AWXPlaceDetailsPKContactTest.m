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
    
    details.address = address;
    
    PKContact *contact = [details convertToPaymentContact];
    
    XCTAssertEqual(contact.name.givenName, details.firstName);
    XCTAssertEqual(contact.name.familyName, details.lastName);
    XCTAssertEqual(contact.postalAddress.ISOCountryCode, address.countryCode);
    XCTAssertEqual(contact.postalAddress.city, address.city);
    XCTAssertEqual(contact.postalAddress.street, address.street);
    XCTAssertEqualObjects(contact.postalAddress.state, @"");
    XCTAssertEqualObjects(contact.postalAddress.postalCode, @"");
    XCTAssertNil(contact.emailAddress);
    XCTAssertNil(contact.phoneNumber);
}

@end

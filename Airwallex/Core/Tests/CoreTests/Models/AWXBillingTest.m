//
//  AWXPlaceDetailsTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPlaceDetails.h"
#import "AWXTestUtils.h"
#import <XCTest/XCTest.h>

@interface AWXPlaceDetailsTest : XCTestCase

@end

@implementation AWXPlaceDetailsTest

- (void)testBilling {
    NSData *data = [AWXTestUtils dataFromJsonFile:@"Billing"];
    AWXPlaceDetails *billing = [AWXPlaceDetails decodeFromJSONData:data];
    XCTAssertNotNil(billing);
    XCTAssertNotNil(billing.firstName);
    XCTAssertNotNil(billing.lastName);
    XCTAssertNotNil(billing.email);
    XCTAssertNotNil(billing.phoneNumber);
    XCTAssertNotNil(billing.dateOfBirth);
    XCTAssertNotNil(billing.address);
}

- (void)testInstantiation {
    NSString *firstName = @"First";
    NSString *lastName = @"Last";
    NSString *email = @"email@email.com";
    NSString *dateOfBirth = @"01/01/1980";
    NSString *phoneNumber = @"123456678";
    NSString *street = @"123 Main St";
    NSString *city = @"City";
    NSString *state = @"State";
    NSString *postcode = @"1234";
    NSString *countryCode = @"AU";

    AWXAddress *address = [[AWXAddress alloc] initWithStreet:street
                                                        city:city
                                                       state:state
                                                    postcode:postcode
                                                 countryCode:countryCode];

    AWXPlaceDetails *details = [[AWXPlaceDetails alloc] initWithFirstName:firstName
                                                                 lastName:lastName
                                                                    email:email
                                                              dateOfBirth:dateOfBirth
                                                              phoneNumber:phoneNumber
                                                                  address:address];

    XCTAssertEqual(details.firstName, firstName);
    XCTAssertEqual(details.lastName, lastName);
    XCTAssertEqual(details.email, email);
    XCTAssertEqual(details.dateOfBirth, dateOfBirth);
    XCTAssertEqual(details.phoneNumber, phoneNumber);

    XCTAssertEqual(address.street, street);
    XCTAssertEqual(address.city, city);
    XCTAssertEqual(address.state, state);
    XCTAssertEqual(address.postcode, postcode);
    XCTAssertEqual(address.countryCode, countryCode);
}

@end

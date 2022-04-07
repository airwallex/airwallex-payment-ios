//
//  AWXPlaceDetails+PKContact.m
//  ApplePay
//
//  Created by Jin Wang on 13/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPlaceDetails+PKContact.h"

@implementation AWXPlaceDetails (PKContact)

- (PKContact *)convertToPaymentContact
{
    PKContact *contact = [PKContact new];
    
    NSPersonNameComponents *nameComponents = [NSPersonNameComponents new];
    nameComponents.givenName = self.firstName;
    nameComponents.familyName = self.lastName;
    
    CNMutablePostalAddress *address = [CNMutablePostalAddress new];
    address.ISOCountryCode = self.address.countryCode;
    address.city = self.address.city;
    address.street = self.address.street;
    
    if (self.address.state) {
        address.state = self.address.state;
    }
    
    if (self.address.postcode) {
        address.postalCode = self.address.postcode;
    }
    
    contact.name = nameComponents;
    contact.emailAddress = self.email;
    contact.phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:self.phoneNumber];
    contact.postalAddress = address;
    
    return contact;
}

@end

//
//  AWXPlaceDetails+PKContact.h
//  ApplePay
//
//  Created by Jin Wang on 13/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPlaceDetails.h"
#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXPlaceDetails (PKContact)

- (PKContact *)convertToPaymentContact;

@end

NS_ASSUME_NONNULL_END

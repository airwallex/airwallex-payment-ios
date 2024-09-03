//
//  AWXProviderDelegateSpy.h
//  ApplePayTests
//
//  Created by Jin Wang on 29/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXProviderDelegateSpy : NSObject<AWXProviderDelegate>

@property (nonatomic) int providerDidStartRequestCount;
@property (nonatomic) int providerDidEndRequestCount;
@property (nonatomic) int providerDidCompleteWithStatusCount;
@property (nonatomic, assign) AirwallexPaymentStatus lastStatus;
@property (nonatomic, strong, nullable) NSError *lastStatusError;
@property (nonatomic, strong, nullable) XCTestExpectation *statusExpectation;
@property (nonatomic, strong, nullable) UIViewController *hostVC;

@end

NS_ASSUME_NONNULL_END

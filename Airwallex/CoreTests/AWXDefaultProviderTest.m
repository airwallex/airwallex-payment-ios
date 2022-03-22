//
//  AWXDefaultProviderTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXDefaultProvider.h"
#import "AWXSession.h"

@interface AWXDefaultProviderTest : XCTestCase

@end

@implementation AWXDefaultProviderTest

- (void)testCanHandleSessionDefaultImplementation {
    AWXSession *session = [AWXSession new];
    XCTAssertTrue([AWXDefaultProvider canHandleSession:session]);
}

@end

//
//  AWXAPIErrorResponse+Update.m
//  Core
//
//  Created by Hector.Huang on 2023/3/21.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXAPIErrorResponse+Update.h"

@implementation AWXAPIErrorResponse (Update)

- (AWXAPIErrorResponse *)updatedResponseWithStatusCode:(NSInteger)statusCode Error:(NSError *)error {
    NSString *updatedCode = [@(statusCode) stringValue];
    NSString *updatedMessage = error.localizedDescription;
    if (self.code.length > 0) {
        updatedCode = self.code;
    }
    if (self.message.length > 0) {
        updatedMessage = self.message;
    }
    return [[AWXAPIErrorResponse alloc] initWithMessage:updatedMessage code:updatedCode];
}

@end

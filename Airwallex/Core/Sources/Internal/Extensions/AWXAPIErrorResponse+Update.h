//
//  AWXAPIErrorResponse+Update.h
//  Core
//
//  Created by Hector.Huang on 2023/3/21.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXAPIResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXAPIErrorResponse (Update)

- (AWXAPIErrorResponse *)updatedResponseWithStatusCode:(NSInteger)statusCode Error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END

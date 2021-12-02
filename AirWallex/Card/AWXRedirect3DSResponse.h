//
//  AWXRedirect3DSResponse.h
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXRedirect3DSResponse` includes the parameters for three ds redirection.
 */
@interface AWXRedirect3DSResponse : NSObject <AWXJSONDecodable>

/**
 JWT token
 */
@property (nonatomic, readonly) NSString *jwt;

/**
 Bin
 */
@property (nonatomic, readonly) NSString *bin;

@end

NS_ASSUME_NONNULL_END

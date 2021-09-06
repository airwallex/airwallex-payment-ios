//
//  AWXRedirectThreeDSResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXRedirectThreeDSResponse` includes the parameters for three ds redirection.
 */
@interface AWXRedirectThreeDSResponse : NSObject <AWXJSONDecodable>

/**
 JWT token
 */
@property (nonatomic, readonly) NSString *jwt;

/**
 Stage
 */
@property (nonatomic, readonly) NSString *stage;

/**
 ACS
 */
@property (nonatomic, readonly, nullable) NSString *acs;

/**
 Xid
 */
@property (nonatomic, readonly, nullable) NSString *xid;

/**
 Req
 */
@property (nonatomic, readonly, nullable) NSString *req;

@end

NS_ASSUME_NONNULL_END

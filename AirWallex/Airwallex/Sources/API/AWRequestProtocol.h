//
//  AWRequestProtocol.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#ifndef AWRequestProtocol_h
#define AWRequestProtocol_h

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AWHTTPMethodGET,
    AWHTTPMethodPOST,
} AWHTTPMethod;

@protocol AWRequestProtocol <NSObject>

- (NSString *)path;
- (AWHTTPMethod)method;

@optional
- (nullable NSDictionary *)parameters;
- (Class)responseClass;
- (NSDictionary *)headers;

@end

NS_ASSUME_NONNULL_END

#endif /* AWRequestProtocol_h */

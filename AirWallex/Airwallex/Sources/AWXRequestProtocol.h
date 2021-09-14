//
//  AWXRequestProtocol.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#ifndef AWXRequestProtocol_h
#define AWXRequestProtocol_h

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AWXHTTPMethodGET,
    AWXHTTPMethodPOST,
} AWXHTTPMethod;

@protocol AWXRequestProtocol <NSObject>

- (NSString *)path;
- (AWXHTTPMethod)method;

@optional
- (nullable NSDictionary *)parameters;
- (Class)responseClass;
- (NSDictionary *)headers;

@end

NS_ASSUME_NONNULL_END

#endif /* AWXRequestProtocol_h */

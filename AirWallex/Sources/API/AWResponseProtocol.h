//
//  AWResponseProtocol.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#ifndef AWResponseProtocol_h
#define AWResponseProtocol_h

NS_ASSUME_NONNULL_BEGIN

@protocol AWResponseProtocol <NSObject>

@optional
+ (id <AWResponseProtocol>)parse:(NSData *)data;
+ (nullable id <AWResponseProtocol>)parseError:(NSData *)data;

@end

NS_ASSUME_NONNULL_END

#endif /* AWResponseProtocol_h */

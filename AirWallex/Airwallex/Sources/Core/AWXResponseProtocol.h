//
//  AWXResponseProtocol.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#ifndef AWXResponseProtocol_h
#define AWXResponseProtocol_h

NS_ASSUME_NONNULL_BEGIN

@protocol AWXResponseProtocol <NSObject>

@optional
+ (id <AWXResponseProtocol>)parse:(NSData *)data;
+ (nullable id <AWXResponseProtocol>)parseError:(NSData *)data;

@end

NS_ASSUME_NONNULL_END

#endif /* AWXResponseProtocol_h */

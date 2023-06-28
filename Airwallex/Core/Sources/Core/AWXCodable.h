//
//  AWXCodable.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/7.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef AWXCodable_h
#define AWXCodable_h

@protocol AWXJSONDecodable<NSObject>

+ (nullable instancetype)decodeFromJSON:(nonnull NSDictionary *)json;
+ (nullable instancetype)decodeFromJSONData:(nonnull NSData *)data;

@end

@protocol AWXJSONEncodable<NSObject>

- (nonnull NSDictionary *)encodeToJSON;

@end

#endif /* AWXCodable_h */

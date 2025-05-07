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

NS_ASSUME_NONNULL_BEGIN

@protocol AWXJSONDecodable<NSObject>

+ (id)decodeFromJSON:(NSDictionary *_Nullable)json;

@end

@protocol AWXJSONEncodable<NSObject>

- (NSDictionary *)encodeToJSON;

@end

NS_ASSUME_NONNULL_END

#endif /* AWXCodable_h */

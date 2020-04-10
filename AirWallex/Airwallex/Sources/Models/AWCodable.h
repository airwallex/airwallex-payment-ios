//
//  AWCodable.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/7.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#ifndef AWCodable_h
#define AWCodable_h

@protocol AWJSONDecodable <NSObject>

+ (id)decodeFromJSON:(NSDictionary *)json;

@end

@protocol AWJSONEncodable <NSObject>

- (NSDictionary *)encodeToJSON;

@end

#endif /* AWCodable_h */

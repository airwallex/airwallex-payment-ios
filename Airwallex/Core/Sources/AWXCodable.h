//
//  AWXCodable.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/7.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#ifndef AWXCodable_h
#define AWXCodable_h

@protocol AWXJSONDecodable<NSObject>

+ (id)decodeFromJSON:(NSDictionary *)json;

@end

@protocol AWXJSONEncodable<NSObject>

- (NSDictionary *)encodeToJSON;

@end

#endif /* AWXCodable_h */

//
//  AWParseable.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#ifndef AWParseable_h
#define AWParseable_h

@protocol AWParseable <NSObject>

+ (id)parseFromJsonDictionary:(NSDictionary *)json;

@end

#endif /* AWParseable_h */

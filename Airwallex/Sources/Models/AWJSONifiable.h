//
//  AWJSONifiable.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#ifndef AWJSONifiable_h
#define AWJSONifiable_h

@protocol AWJSONifiable <NSObject>

- (NSDictionary *)toJSONDictionary;

@end

#endif /* AWJSONifiable_h */

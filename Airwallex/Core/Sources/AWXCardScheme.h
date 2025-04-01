//
//  AWXCardScheme.h
//  Core
//
//  Created by Hector.Huang on 2022/11/9.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCodable.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXCardScheme : NSObject<AWXJSONDecodable>

@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END

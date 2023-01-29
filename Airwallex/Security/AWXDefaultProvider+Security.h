//
//  AWXDefaultProvider+Security.h
//  Airwallex
//
//  Created by Hector.Huang on 2023/1/29.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXDefaultProvider (Security)

- (void)setDevice:(void (^)(AWXDevice *_Nonnull))completion;

@end

NS_ASSUME_NONNULL_END

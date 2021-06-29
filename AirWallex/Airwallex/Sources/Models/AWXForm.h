//
//  AWXForm.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/29.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXForm : NSObject

@property (nonatomic) AWXFormType type;
@property (nonatomic, strong) NSString *title;

+ (instancetype)formWithTitle:(NSString *)title type:(AWXFormType)type;

@end

NS_ASSUME_NONNULL_END

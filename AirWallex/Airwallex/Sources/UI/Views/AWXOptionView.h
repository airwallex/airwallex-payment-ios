//
//  AWXOptionView.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/29.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWXWidgets.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXOptionView : AWXView

@property (nonatomic, readonly) NSString *placeholder;

- (instancetype)initWithKey:(NSString *)key formLabel:(NSString *)formLabelText placeholder:(NSString *)placeholder logo:(NSString *)logo;
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END

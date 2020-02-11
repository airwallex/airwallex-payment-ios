//
//  UIButton+Utils.h
//  Examples
//
//  Created by Victor Zhu on 2020/2/11.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Utils)

- (void)setImageAndTitleVerticalAlignmentCenter:(float)spacing imageSize:(CGSize)imageSize;
- (void)setImageAndTitleHorizontalAlignmentCenter:(float)spacing;

@end

NS_ASSUME_NONNULL_END

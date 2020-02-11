//
//  UIButton+Utils.m
//  Examples
//
//  Created by Victor Zhu on 2020/2/11.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "UIButton+Utils.h"

@implementation UIButton (Utils)

- (void)setImageAndTitleVerticalAlignmentCenter:(float)spacing imageSize:(CGSize)imageSize
{
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0f, 0.0f, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, - imageSize.width, - (imageSize.height + spacing), 0.0f);
}

- (void)setImageAndTitleHorizontalAlignmentCenter:(float)spacing
{
    self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
}

@end

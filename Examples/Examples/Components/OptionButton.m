//
//  OptionButton.m
//  Examples
//
//  Created by Jarrod Robins on 23/6/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "OptionButton.h"
#import "AWXTheme.h"
#import "AWXWidgets.h"

@implementation OptionButton

- (void)awakeFromNib {
    [super awakeFromNib];

    self.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;

    self.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);

    self.layer.cornerRadius = 4.0;

    if (@available(iOS 13.0, *)) {
        [self awx_setBackgroundColor:UIColor.tertiarySystemFillColor forState:UIControlStateNormal];
    } else {
        [self awx_setBackgroundColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    }
}

@end

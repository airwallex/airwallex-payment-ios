//
//  CardInfoView.h
//  Examples
//
//  Created by Tony He (CTR) on 2024/8/8.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import <Airwallex/Core.h>
#import <UIKit/UIKit.h>

@class AWXCard;

NS_ASSUME_NONNULL_BEGIN

@interface CardInfoView : UIView

@property (strong, nonatomic) AWXCard *card;
@property (nonatomic) BOOL isEditEnabled;
@property (strong, nonatomic) UIButton *pay;

@end

NS_ASSUME_NONNULL_END

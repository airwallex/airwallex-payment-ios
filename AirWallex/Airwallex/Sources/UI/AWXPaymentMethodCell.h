//
//  AWXPaymentMethodCell.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXPaymentMethodCell` is the cell of paymetn method info
 */
@interface AWXPaymentMethodCell : UITableViewCell

/**
 Image view for displaying payment method logo
 */
@property (strong, nonatomic) UIImageView *logoImageView;

/**
 Label for displaying payment method name
 */
@property (strong, nonatomic) UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END

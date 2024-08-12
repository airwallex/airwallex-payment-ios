//
//  PaymentMethodCell.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 `PaymentMethodCell` is the cell of paymetn method info
 */
@interface PaymentMethodCell : UITableViewCell

/**
 Image view for displaying payment method logo
 */
@property (strong, nonatomic, nonnull) UIImageView *logoImageView;

/**
 Label for displaying payment method name
 */
@property (strong, nonatomic, nonnull) UILabel *titleLabel;

@end

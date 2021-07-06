//
//  TotalCell.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TotalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@property (strong, nonatomic) NSDecimalNumber *subtotal, *shipping, *total;

@end

NS_ASSUME_NONNULL_END

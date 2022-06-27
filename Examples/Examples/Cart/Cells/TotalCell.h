//
//  TotalCell.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TotalCell : UITableViewCell

@property (strong, nonatomic, nonnull) IBOutlet UILabel *subtotalTitleLabel;
@property (strong, nonatomic, nonnull) IBOutlet UILabel *subtotalLabel;

@property (strong, nonatomic, nonnull) IBOutlet UILabel *totalTitleLabel;
@property (strong, nonatomic, nonnull) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic, nonnull) IBOutletCollection(UIView) NSArray<UIView *> *separators;

@property (strong, nonatomic, nonnull) NSDecimalNumber *subtotal;
@property (strong, nonatomic, nonnull) NSDecimalNumber *shipping;
@property (strong, nonatomic, nonnull) NSDecimalNumber *total;

@end

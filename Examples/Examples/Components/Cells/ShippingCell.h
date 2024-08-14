//
//  ShippingCell.h
//  Examples
//
//  Created by Victor Zhu on 2020/5/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Airwallex/Core.h>
#import <UIKit/UIKit.h>

@interface ShippingCell : UITableViewCell

@property (strong, nonatomic, nonnull) IBOutlet UILabel *shippingTitleLabel;

@property (strong, nonatomic, nonnull) IBOutlet UILabel *shippingLabel;

@property (strong, nonatomic, nonnull) IBOutlet UIView *separator;
@property (strong, nonatomic, nonnull) IBOutlet UIImageView *disclosureIndicator;
@property (strong, nonatomic, nonnull) AWXPlaceDetails *shipping;

@end

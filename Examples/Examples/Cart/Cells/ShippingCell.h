//
//  ShippingCell.h
//  Examples
//
//  Created by Victor Zhu on 2020/5/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Airwallex/Core.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShippingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *shippingLabel;

@property (strong, nonatomic) AWXPlaceDetails *shipping;

@end

NS_ASSUME_NONNULL_END

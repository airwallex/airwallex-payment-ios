//
//  ShippingCell.h
//  Examples
//
//  Created by Victor Zhu on 2020/5/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Airwallex/Airwallex.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShippingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *shippingLabel;

@property (strong, nonatomic) AWPlaceDetails *shipping;

@end

NS_ASSUME_NONNULL_END

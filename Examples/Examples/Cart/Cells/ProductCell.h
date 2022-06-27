//
//  ProductCell.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "Product.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ProductCellRemovalHandler)(Product *product);

@interface ProductCell : UITableViewCell

@property (strong, nonatomic, nonnull) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic, nonnull) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic, nonnull) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic, nonnull) IBOutlet UIButton *removeButton;
@property (strong, nonatomic, nonnull) IBOutlet UIView *separator;

@property (strong, nonatomic, nonnull) Product *product;
@property (strong, nonatomic, nonnull) ProductCellRemovalHandler handler;

@end

NS_ASSUME_NONNULL_END

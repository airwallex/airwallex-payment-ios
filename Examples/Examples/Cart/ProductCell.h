//
//  ProductCell.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Product : NSObject

@property (nonatomic, strong) NSString *name, *detail;
@property (nonatomic, strong) NSDecimalNumber *price;

- (instancetype)initWithName:(NSString *)name detail:(NSString *)detail price:(NSDecimalNumber *)price;

@end

typedef void(^ProductCellRemovalHandler)(Product *product);

@interface ProductCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) ProductCellRemovalHandler handler;

@end

NS_ASSUME_NONNULL_END

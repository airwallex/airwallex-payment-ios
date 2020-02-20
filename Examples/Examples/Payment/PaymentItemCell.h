//
//  PaymentItemCell.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaymentItemCell;

NS_ASSUME_NONNULL_BEGIN

@protocol PaymentItemCellDelegate <NSObject>

- (void)paymentItemCell:(PaymentItemCell *)cell didEnterCVC:(NSString *)cvc;

@end

@interface PaymentItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectionLabel;
@property (weak, nonatomic) IBOutlet UIView *cvcView;
@property (weak, nonatomic) IBOutlet UITextField *cvcField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineTopConstraint;
@property (nonatomic) BOOL isLastCell, cvcHidden;
@property (weak, nonatomic) id <PaymentItemCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

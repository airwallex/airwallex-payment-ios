//
//  AWXPaymentMethodCell.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWXPaymentMethod.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^PayClosure)(NSDictionary * data);
@interface AWXPaymentMethodCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tickView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineRightConstraint;
@property (nonatomic) BOOL isLastCell;

@end

@interface AWXPaymentMethodExtensionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIStackView *extensionView;
@property (weak, nonatomic) IBOutlet UIImageView *tickView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineRightConstraint;
@property (nonatomic) BOOL isLastCell;
@property (nonatomic) BOOL isExtension;
@property (nonatomic, strong) AWXPaymentMethod *method;

@property (nonatomic, copy) PayClosure toPay;
@end

@interface AWXNoCardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineRightConstraint;
@property (nonatomic) BOOL isLastCell;

@end

NS_ASSUME_NONNULL_END

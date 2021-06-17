//
//  AWXPaymentMethodCell.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodCell.h"
#import "AWXWidgets.h"
#import "AWXConstants.h"
#import "AWXAPIClient.h"

@implementation AWXPaymentMethodCell

- (void)setIsLastCell:(BOOL)isLastCell
{
    _isLastCell = isLastCell;
    CGFloat constant = isLastCell ? 0 : 16;
    self.lineLeftConstraint.constant = constant;
    self.lineRightConstraint.constant = constant;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.tickView.hidden = !selected;
}

@end

@interface AWXPaymentMethodExtensionCell ()
@property(nonatomic,strong) NSMutableDictionary *itemData;
@property(nonatomic,strong) AWXButton *payButton;
@end

@implementation AWXPaymentMethodExtensionCell

- (void)setIsLastCell:(BOOL)isLastCell
{
    _isLastCell = isLastCell;
    CGFloat constant = isLastCell ? 0 : 16;
    self.lineLeftConstraint.constant = constant;
    self.lineRightConstraint.constant = constant;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.tickView.hidden = !selected;
}
-(void)setIsExtension:(BOOL)isExtension{
    _isExtension = isExtension;
    [self.extensionView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (isExtension && [Airwallex.supportedExtensionNonCardTypes containsObject:self.method.type]) {
        for (NSNumber * item in [self itemsArray]) {
            AWXPayExtensionView * itemView = [[AWXPayExtensionView alloc]init];
            itemView.type = item.intValue;
            itemView.textFieldEdit = ^(NSString * _Nonnull text) {
                self.payButton.enabled = [self checkFullData];
                if (self.payButton.enabled) {
                    [self.payButton setBackgroundColor:[UIColor colorWithRed:97.0f/255.0f green:47.0f/255.0f blue:255.0f/255.0f alpha:1]];
                } else {
                    [self.payButton setBackgroundColor:[UIColor colorWithRed:232.0f/255.0f green:234.0f/255.0f blue:237.0f/255.0f alpha:1]];
                }
            };
            [self.extensionView addArrangedSubview:itemView];
        }
        AWXPayButtonView *btnView = [[AWXPayButtonView alloc]init];
        [btnView.payButton addTarget:self action:@selector(payClick) forControlEvents:(UIControlEventTouchUpInside)];
        btnView.payButton.enabled = NO;
        [self.extensionView addArrangedSubview:btnView];
        self.payButton = btnView.payButton;
    }
}

-(BOOL)checkFullData{
    self.itemData = @{}.mutableCopy;
    BOOL allFill = YES;
    for (UIView *view in  self.extensionView.arrangedSubviews) {
        if ([view isKindOfClass:[AWXPayExtensionView class]]) {
            AWXPayExtensionView * item = (AWXPayExtensionView *)view;
            if (item.inputText.length && item.title.length) {
                self.itemData[item.title] = item.inputText;
            } else {
                allFill = NO;
                break;
            }
        }
    }
    return  allFill;
}
-(void) payClick {
    if ([self checkFullData]) {
        if (self.toPay) {
            self.toPay(self.itemData.copy);
        }
    }
}

- (NSArray *)itemsArray {
    if ([Airwallex.supportedExtensionNonCardTypes containsObject:self.method.type]) {
        if ([self.method.type isEqualToString: AWXPoli]) {
            return @[@(AWXPayMethodExtensionTypeName)];
        } else if ([self.method.type isEqualToString: AWXFpx]) {
            return @[@(AWXPayMethodExtensionTypeName), @(AWXPayMethodExtensionTypeEmail), @(AWXPayMethodExtensionTypePhone)];
        } else if ([self.method.type isEqualToString: AWXBankTransfer]) {
            return @[@(AWXPayMethodExtensionTypeBank), @(AWXPayMethodExtensionTypeName), @(AWXPayMethodExtensionTypeEmail), @(AWXPayMethodExtensionTypePhone)];
        }
    }
    return @[];
}
-(void)setMethod:(AWXPaymentMethod *)method {
    _method = method;
}

@end
@implementation AWXNoCardCell

- (void)setIsLastCell:(BOOL)isLastCell
{
    _isLastCell = isLastCell;
    CGFloat constant = isLastCell ? 0 : 16;
    self.lineLeftConstraint.constant = constant;
    self.lineRightConstraint.constant = constant;
}

@end

//
//  WechatPayViewController.m
//  Examples
//
//  Created by roger on 2021/5/27.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "WechatPayViewController.h"
#import <Airwallex/Core.h>
#import <WechatOpenSDK/WXApi.h>

@interface WechatPayViewController ()

@property (strong, nonatomic, nonnull) IBOutletCollection(UILabel) NSArray<UILabel *> *titleLabels;

@property (strong, nonatomic, nonnull) IBOutletCollection(UITextField) NSArray<UITextField *> *textFields;

@property (strong, nonatomic, nonnull) IBOutlet UITextField *appIdTextField;
@property (strong, nonatomic, nonnull) IBOutlet UITextField *nonceStrTextField;
@property (strong, nonatomic, nonnull) IBOutlet UITextField *packageTextField;
@property (strong, nonatomic, nonnull) IBOutlet UITextField *partnerIdTextField;
@property (strong, nonatomic, nonnull) IBOutlet UITextField *prepayIdTextField;
@property (strong, nonatomic, nonnull) IBOutlet UITextField *signTextField;
@property (strong, nonatomic, nonnull) IBOutlet UITextField *timestampTextField;
@property (strong, nonatomic, nonnull) IBOutlet AWXActionButton *submitButton;

@end

@implementation WechatPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];
}

- (void)setupViews {
    self.view.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;

    for (UILabel *label in _titleLabels) {
        label.textColor = [AWXTheme sharedTheme].primaryTextColor;
        label.font = [UIFont subhead2Font];
    }

    for (UITextField *textField in _textFields) {
        textField.font = [UIFont bodyFont];
    }

    [self.submitButton awx_setBackgroundColor:[AWXTheme sharedTheme].tintColor forState:UIControlStateNormal];
    [self.submitButton awx_setBackgroundColor:[AWXTheme sharedTheme].disabledButtonColor forState:UIControlStateDisabled];
}

- (IBAction)checkOutTap:(id)sender {
    NSString *appId = self.appIdTextField.text;
    NSString *nonceStr = self.nonceStrTextField.text;
    NSString *package = self.packageTextField.text;
    NSString *partnerId = self.partnerIdTextField.text;
    NSString *prepayId = self.prepayIdTextField.text;
    NSString *sign = self.signTextField.text;
    NSString *timeStamp = self.timestampTextField.text;
    if (!(appId.length && nonceStr.length && package.length && partnerId.length && prepayId.length && sign.length && timeStamp.length)) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please fill in all the fields" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Sure" style:(UIAlertActionStyleDefault)handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    PayReq *request = [[PayReq alloc] init];
    request.partnerId = partnerId;
    request.prepayId = prepayId;
    request.package = package;
    request.nonceStr = nonceStr;
    request.timeStamp = timeStamp.doubleValue;
    request.sign = sign;

    [WXApi sendReq:request
        completion:^(BOOL success) {
            if (!success) {
                // Failed to call WeChat Pay
                return;
            }
            // Succeed to pay
        }];
}

@end

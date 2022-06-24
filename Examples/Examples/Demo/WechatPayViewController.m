//
//  WechatPayViewController.m
//  Examples
//
//  Created by roger on 2021/5/27.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "WechatPayViewController.h"
#import <WechatOpenSDK/WXApi.h>

@interface WechatPayViewController ()
@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *nonceStrTextField;
@property (weak, nonatomic) IBOutlet UITextField *packageTextField;
@property (weak, nonatomic) IBOutlet UITextField *partnerIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *prepayIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *signTextField;
@property (weak, nonatomic) IBOutlet UITextField *timestampTextField;
@end

@implementation WechatPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

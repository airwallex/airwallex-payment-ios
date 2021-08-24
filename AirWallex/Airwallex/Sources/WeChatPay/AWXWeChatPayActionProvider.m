//
//  AWXWeChatPayActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXWeChatPayActionProvider.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXWeChatPaySDKResponse.h"
#import <WechatOpenSDK/WXApi.h>

@implementation AWXWeChatPayActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
    AWXWeChatPaySDKResponse *response = [AWXWeChatPaySDKResponse decodeFromJSON:nextAction.payload[@"data"]];
    
    /**
     To mock the wechat payment flow, we use an url to call instead wechat callback.
     */
    NSURL *url = [NSURL URLWithString:response.prepayId];
    if (url.scheme && url.host) {
        [self.delegate providerDidStartRequest:self];
        
        __weak __typeof(self)weakSelf = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.delegate providerDidEndRequest:strongSelf];
                [strongSelf.delegate provider:strongSelf didCompleteWithError:error];
            });
        }] resume];
        return;
    }
    
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = response.partnerId;
    request.prepayId = response.prepayId;
    request.package = response.package;
    request.nonceStr = response.nonceStr;
    request.timeStamp = response.timeStamp.doubleValue;
    request.sign = response.sign;
    
    [WXApi sendReq:request completion:^(BOOL success) {
        if (!success) {
            // Failed to call WeChat app
            return;
        }
        // Succeed to call WeChat app
    }];
    
    [self.delegate provider:self shouldPresentViewController:nil forceToDismiss:YES];
}

@end

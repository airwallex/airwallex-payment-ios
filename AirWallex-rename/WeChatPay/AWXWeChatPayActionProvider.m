//
//  AWXWeChatPayActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXWeChatPayActionProvider.h"
#import "AWXSession.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXWeChatPaySDKResponse.h"
#import <WechatOpenSDK/WXApi.h>

@implementation AWXWeChatPayActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
    AWXWeChatPaySDKResponse *response = [AWXWeChatPaySDKResponse decodeFromJSON:nextAction.payload];
    
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
                [strongSelf.delegate provider:strongSelf didCompleteWithStatus:error != nil ? AirwallexPaymentStatusFailure : AirwallexPaymentStatusSuccess error:error];
            });
        }] resume];
        return;
    }
    
    [WXApi registerApp:response.appId universalLink:self.session.returnURL];
    
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = response.partnerId;
    request.prepayId = response.prepayId;
    request.package = response.package;
    request.nonceStr = response.nonceStr;
    request.timeStamp = response.timeStamp.doubleValue;
    request.sign = response.sign;
    
    [WXApi sendReq:request completion:^(BOOL success) {
        if (!success) {
            [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusInProgress error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to request WeChat service.", nil)}]];
            return;
        }
        [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusInProgress error:nil];
    }];
}

@end

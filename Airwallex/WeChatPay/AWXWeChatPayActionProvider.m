//
//  AWXWeChatPayActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXWeChatPayActionProvider.h"
#import "AWXAnalyticsLogger.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXSession.h"
#import "AWXWeChatPaySDKResponse.h"
#import "NSObject+Logging.h"
#import <WechatOpenSDK/WXApi.h>

@implementation AWXWeChatPayActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    AWXWeChatPaySDKResponse *response = [AWXWeChatPaySDKResponse decodeFromJSON:nextAction.payload];

    /**
     To mock the wechat payment flow, we use an url to call instead wechat callback.
     */
    NSURL *url = [NSURL URLWithString:response.prepayId];
    if (url.scheme && url.host) {
        [self.delegate providerDidStartRequest:self];
        [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];

        __weak __typeof(self) weakSelf = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                         completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                             __strong __typeof(weakSelf) strongSelf = weakSelf;
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [strongSelf.delegate providerDidEndRequest:strongSelf];
                                                 [strongSelf log:@"Delegate: %@, providerDidEndRequest:", self.delegate.class];
                                                 [strongSelf.delegate provider:strongSelf didCompleteWithStatus:error != nil ? AirwallexPaymentStatusFailure : AirwallexPaymentStatusSuccess error:error];
                                                 [strongSelf log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu  %@", strongSelf.delegate.class, (unsigned long)(error != nil ? AirwallexPaymentStatusFailure : AirwallexPaymentStatusSuccess), error.localizedDescription];
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

    [WXApi sendReq:request
        completion:^(BOOL success) {
            if (!success) {
                if (request.description.length > 0) {
                    [[AWXAnalyticsLogger shared] logErrorWithName:@"wechat_redirect" additionalInfo:@{@"message": request.description}];
                }

                [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to request WeChat service.", nil)}]];
                [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu  %@", self.delegate.class, (unsigned long)AirwallexPaymentStatusFailure, @"Failed to request WeChat service."];
                return;
            }
            [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusInProgress error:nil];
            [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu", self.delegate.class, (unsigned long)AirwallexPaymentStatusInProgress];
            [[AWXAnalyticsLogger shared] logPageViewWithName:@"wechat_redirect"];
        }];
}

@end

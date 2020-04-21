//
//  AW3DSService.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AW3DSService.h"
#import <CardinalMobile/CardinalMobile.h>
#import "AWUtils.h"
#import "AWPaymentIntentRequest.h"
#import "AWPaymentIntentResponse.h"
#import "AWPaymentMethodOptions.h"
#import "AWAPIClient.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface AW3DSService ()

@property (strong, nonatomic) CardinalSession *session;

@end

@implementation AW3DSService

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.session = [CardinalSession new];

        CardinalSessionConfiguration *config = [CardinalSessionConfiguration new];
        config.deploymentEnvironment = CardinalSessionEnvironmentStaging;
        config.requestTimeout = CardinalSessionTimeoutStandard;
        config.challengeTimeout = 8;
        config.uiType = CardinalSessionUITypeBoth;
        CardinalSessionRenderTypeArray *renderType = [[CardinalSessionRenderTypeArray alloc] initWithObjects:
                                                      CardinalSessionRenderTypeOTP,
                                                      CardinalSessionRenderTypeHTML,
                                                      CardinalSessionRenderTypeOOB,
                                                      CardinalSessionRenderTypeSingleSelect,
                                                      CardinalSessionRenderTypeMultiSelect,
                                                      nil];
        config.renderType = renderType;

        [self.session configure:config];
    }
    return self;
}

- (void)present3DSFlowWithRedirectResponse:(AWRedirectResponse *)response
{
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD show];
    [self.session setupWithJWT:response.jwt didComplete:^(NSString * _Nonnull consumerSessionId) {
        [SVProgressHUD dismiss];
        NSLog(@"cardinal setup complete");
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf confirmWithConsumerSessionId:consumerSessionId];
    } didValidate:^(CardinalResponse * _Nonnull validateResponse) {
        [SVProgressHUD dismiss];
        NSLog(@"cardinal setup failed");
        NSDictionary *errorJson = @{NSLocalizedDescriptionKey: validateResponse.errorDescription ?: @""};
//        completion([errorJson convertToNSErrorWithCode:@(validateResponse.errorNumber)]);
    }];
}

- (void)confirmWithConsumerSessionId:(NSString *)consumerSessionId
{
    if (consumerSessionId) {
        AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
        AWConfirmPaymentIntentRequest *request = [AWConfirmPaymentIntentRequest new];
        request.intentId = self.intentId;
        request.requestId = NSUUID.UUID.UUIDString;
        request.customerId = self.customerId;
        request.paymentMethod = self.paymentMethod;

        AWThreeDs *threeDs = [AWThreeDs new];
        threeDs.deviceDataCollectionRes = consumerSessionId;
        threeDs.returnURL = @"http://requestbin.net/r/1il2qkm1";

        AWCardOptions *cardOptions = [AWCardOptions new];
        cardOptions.threeDs = threeDs;

        AWPaymentMethodOptions *options = [AWPaymentMethodOptions new];
        options.cardOptions = cardOptions;

        request.options = options;

        [SVProgressHUD show];
        __weak typeof(self) weakSelf = self;
        [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            [SVProgressHUD dismiss];


        }];
    }
}

@end

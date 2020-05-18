//
//  AW3DSService.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AW3DSService.h"
#import "AWConstants.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <CardinalMobile/CardinalMobile.h>
#import "AWPaymentIntentRequest.h"
#import "AWPaymentIntentResponse.h"
#import "AWPaymentMethodOptions.h"
#import "AWAPIClient.h"
#import "AWUtils.h"
#import "AWDevice.h"

@interface AW3DSService () <CardinalValidationDelegate>

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

        UiCustomization *customUI = [UiCustomization new];
        config.uiCustomization = customUI;

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
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (consumerSessionId) {
            [strongSelf confirmWithConsumerSessionId:consumerSessionId];
        } else {
            [self.delegate threeDSServiceDidFailWithError:[NSError errorWithDomain:AWSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Missing consumer seesion id."}]];
        }
    } didValidate:^(CardinalResponse * _Nonnull validateResponse) {
        [SVProgressHUD dismiss];
        [self.delegate threeDSServiceDidFailWithError:[NSError errorWithDomain:AWSDKErrorDomain code:validateResponse.errorNumber userInfo:@{NSLocalizedDescriptionKey: validateResponse.errorDescription}]];
    }];
}

- (AWConfirmPaymentIntentRequest *)confirmPaymentIntentRequestWithThreeDs:(AWThreeDs *)threeDs
{
    AWConfirmPaymentIntentRequest *request = [AWConfirmPaymentIntentRequest new];
    request.intentId = self.intentId;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;
    request.paymentMethod = self.paymentMethod;

    AWCardOptions *cardOptions = [AWCardOptions new];
    cardOptions.threeDs = threeDs;

    AWPaymentMethodOptions *options = [AWPaymentMethodOptions new];
    options.cardOptions = cardOptions;

    request.options = options;
    request.device = self.device;
    return request;
}

- (void)confirmWithConsumerSessionId:(NSString *)consumerSessionId
{
    AWThreeDs *threeDs = [AWThreeDs new];
    threeDs.deviceDataCollectionRes = consumerSessionId;
    threeDs.returnURL = AWThreeDSReturnURL;

    AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
    AWConfirmPaymentIntentRequest *request = [self confirmPaymentIntentRequestWithThreeDs:threeDs];

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            [strongSelf.delegate threeDSServiceDidFailWithError:error];
            return;
        }

        AWConfirmPaymentIntentResponse *result = (AWConfirmPaymentIntentResponse *)response;
        AWAuthenticationData *authenticationData = result.latestPaymentAttempt.authenticationData;
        AWRedirectResponse *redirectResponse = result.nextAction.redirectResponse;
        if (authenticationData.isThreeDSVersion2) {
            if (redirectResponse.xid && redirectResponse.req) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.session continueWithTransactionId:redirectResponse.xid payload:redirectResponse.req didValidateDelegate:self];
                });
            } else {
                [self.delegate threeDSServiceDidFailWithError:[NSError errorWithDomain:AWSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Missing transaction id or payload."}]];
            }
        } else {
            
        }
    }];
}

- (void)cardinalSession:(CardinalSession *)session stepUpDidValidateWithResponse:(CardinalResponse *)validateResponse serverJWT:(NSString *)serverJWT
{
    if (serverJWT) {
        [self confirmWithServerJWT:serverJWT];
    } else if (validateResponse) {
        [self.delegate threeDSServiceDidFailWithError:[NSError errorWithDomain:AWSDKErrorDomain code:validateResponse.errorNumber userInfo:@{NSLocalizedDescriptionKey: validateResponse.errorDescription}]];
    }
}

- (void)confirmWithServerJWT:(NSString *)serverJWT
{
    AWThreeDs *threeDs = [AWThreeDs new];
    threeDs.dsTransactionId = serverJWT;
    threeDs.returnURL = AWThreeDSReturnURL;

    AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
    AWConfirmPaymentIntentRequest *request = [self confirmPaymentIntentRequestWithThreeDs:threeDs];

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            [strongSelf.delegate threeDSServiceDidFailWithError:error];
            return;
        }

        AWConfirmPaymentIntentResponse *result = (AWConfirmPaymentIntentResponse *)response;
        // Todo: handle the response
    }];
}

@end

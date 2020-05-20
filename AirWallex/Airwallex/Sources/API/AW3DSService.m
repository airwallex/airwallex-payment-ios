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
#import "AWWebViewController.h"

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
    // Step 1: Request `referenceId` with `serverJwt` by Cardinal SDK
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

    // Step 2: Request 3DS lookup response by `confirmPaymentIntent` with `referenceId`
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
        if ([result.status isEqualToString:@"REQUIRES_CAPTURE"] || result.nextAction == nil) {
            [strongSelf.delegate threeDSServiceDidFinish];
            return;
        }

        // Step 3: Show 3DS UI, then wait user input. After user input, will receive `processorTransactionId`
        AWAuthenticationData *authenticationData = result.latestPaymentAttempt.authenticationData;
        AWRedirectResponse *redirectResponse = result.nextAction.redirectResponse;
        if (authenticationData.isThreeDSVersion2) {
            // 3DS v2.x flow
            if (redirectResponse.xid && redirectResponse.req) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.session continueWithTransactionId:redirectResponse.xid payload:redirectResponse.req didValidateDelegate:self];
                });
            } else {
                [strongSelf.delegate threeDSServiceDidFailWithError:[NSError errorWithDomain:AWSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Missing transaction id or payload."}]];
            }
        } else if (redirectResponse.acs && redirectResponse.req) {
            // 3DS v1.x flow
            NSMutableCharacterSet *set = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
            [set removeCharactersInString:@"&+=?"];
            NSString *reqEncoding = [redirectResponse.req stringByAddingPercentEncodingWithAllowedCharacters:set];
            NSString *termUrlEncoding = [AWThreeDSReturnURL stringByAddingPercentEncodingWithAllowedCharacters:set];
            NSString *body = [NSString stringWithFormat:@"&PaReq=%@&TermUrl=%@", reqEncoding, termUrlEncoding];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:redirectResponse.acs]];
            urlRequest.HTTPMethod = @"POST";
            urlRequest.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
            [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            AWWebViewController *webViewController = [[AWWebViewController alloc] initWithURLRequest:urlRequest webHandler:^(NSString * _Nullable payload, NSError * _Nullable error) {
                // Todo: get payload
            }];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
            [strongSelf.presentingViewController presentViewController:navigationController animated:YES completion:nil];
        } else {
            [strongSelf.delegate threeDSServiceDidFailWithError:[NSError errorWithDomain:AWSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to determine the challenge is 1.x or 2.x."}]];
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

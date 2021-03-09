//
//  AWXThreeDSService.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXThreeDSService.h"
#import "AWXConstants.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <CardinalMobile/CardinalMobile.h>
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXAPIClient.h"
#import "AWXUtils.h"
#import "AWXDevice.h"
#import "AWXWebViewController.h"

@interface AWXThreeDSService () <CardinalValidationDelegate>

@property (strong, nonatomic) CardinalSession *session;
@property (strong, nonatomic) NSString *transactionId;

@end

@implementation AWXThreeDSService

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.session = [CardinalSession new];

        CardinalSessionConfiguration *config = [CardinalSessionConfiguration new];
        config.deploymentEnvironment = [Airwallex mode] == AirwallexSDKLiveMode ? CardinalSessionEnvironmentProduction : CardinalSessionEnvironmentStaging;
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

- (void)presentThreeDSFlowWithServerJwt:(NSString *)serverJwt
{
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD show];
    // Step 1: Request `referenceId` with `serverJwt` by Cardinal SDK
    [self.session setupWithJWT:serverJwt didComplete:^(NSString * _Nonnull consumerSessionId) {
        [SVProgressHUD dismiss];
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (consumerSessionId) {
            [strongSelf confirmWithReferenceId:consumerSessionId];
        } else {
            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Missing consumer seesion id."}]];
        }
    } didValidate:^(CardinalResponse * _Nonnull validateResponse) {
        [SVProgressHUD dismiss];
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:[NSError errorWithDomain:AWXSDKErrorDomain code:validateResponse.errorNumber userInfo:@{NSLocalizedDescriptionKey: validateResponse.errorDescription}]];
    }];
}

- (AWXConfirmPaymentIntentRequest *)confirmPaymentIntentRequestWithThreeDs:(AWXThreeDs *)threeDs
{
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = self.intentId;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;

    AWXCardOptions *cardOptions = [AWXCardOptions new];
    cardOptions.threeDs = threeDs;

    AWXPaymentMethodOptions *options = [AWXPaymentMethodOptions new];
    options.cardOptions = cardOptions;

    request.options = options;
    request.device = self.device;
    return request;
}

- (void)confirmWithReferenceId:(NSString *)referenceId
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];

    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = self.intentId;
    request.type = AWXThreeDSCheckEnrollment;
    request.deviceDataCollectionRes = referenceId;
    request.device = self.device;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    // Step 2: Request 3DS lookup response by `confirmPaymentIntent` with `referenceId`
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:error];
            return;
        }

        AWXConfirmPaymentIntentResponse *result = (AWXConfirmPaymentIntentResponse *)response;
        if ([result.status isEqualToString:@"REQUIRES_CAPTURE"] || result.nextAction == nil) {
            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:result error:nil];
            return;
        }

        // Step 3: Show 3DS UI, then wait user input. After user input, will receive `processorTransactionId`
        AWXAuthenticationData *authenticationData = result.latestPaymentAttempt.authenticationData;
        AWXRedirectResponse *redirectResponse = result.nextAction.redirectResponse;
        if (authenticationData.isThreeDSVersion2) {
            // 3DS v2.x flow
            if (redirectResponse.xid && redirectResponse.req) {
                strongSelf.transactionId = redirectResponse.xid;
                [strongSelf.session continueWithTransactionId:redirectResponse.xid payload:redirectResponse.req didValidateDelegate:self];
            } else {
                [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Missing transaction id or payload."}]];
            }
        } else if (redirectResponse.acs && redirectResponse.req) {
            // 3DS v1.x flow
            NSURL *url = [NSURL URLWithString:redirectResponse.acs];
            NSString *reqEncoding = [redirectResponse.req stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet allURLQueryAllowedCharacterSet]];
            NSString *termUrlEncoding = [[NSString stringWithFormat:@"%@pa/webhook/cybs/pares/callback", [Airwallex cybsURL]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet allURLQueryAllowedCharacterSet]];
            NSString *body = [NSString stringWithFormat:@"&PaReq=%@&TermUrl=%@", reqEncoding, termUrlEncoding];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            urlRequest.HTTPMethod = @"POST";
            urlRequest.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
            [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            __weak __typeof(self)weakSelf = self;
            AWXWebViewController *webViewController = [[AWXWebViewController alloc] initWithURLRequest:urlRequest webHandler:^(NSString * _Nullable paResId, NSError * _Nullable error) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (paResId) {
                    __weak __typeof(self)_weakSelf = strongSelf;
                    [strongSelf getPaRes:paResId completion:^(AWXGetPaResResponse *paResResponse) {
                        __strong __typeof(weakSelf)_strongSelf = _weakSelf;
                        [_strongSelf confirmWithTransactionId:paResResponse.paRes];
                    }];
                } else {
                    [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:error];
                }
            }];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
            navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
            [strongSelf.presentingViewController presentViewController:navigationController animated:YES completion:nil];
        } else {
            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to determine the challenge is 1.x or 2.x."}]];
        }
    }];
}

- (void)cardinalSession:(CardinalSession *)session stepUpDidValidateWithResponse:(CardinalResponse *)validateResponse serverJWT:(NSString *)serverJWT
{
    if (validateResponse) {
        if (validateResponse.actionCode == CardinalResponseActionCodeCancel) {
            [self.delegate threeDSService:self didFinishWithResponse:nil error:[NSError errorWithDomain:AWXSDKErrorDomain code:validateResponse.errorNumber userInfo:@{NSLocalizedDescriptionKey: @"User cancelled."}]];
        } else if ([validateResponse.errorDescription.uppercaseString isEqualToString:@"SUCCESS"]) {
            [self confirmWithTransactionId:validateResponse.payment.processorTransactionId];
        } else {
            [self.delegate threeDSService:self didFinishWithResponse:nil error:[NSError errorWithDomain:AWXSDKErrorDomain code:validateResponse.errorNumber userInfo:@{NSLocalizedDescriptionKey: validateResponse.errorDescription}]];
        }
    } else if (self.transactionId) {
        [self confirmWithTransactionId:self.transactionId];
    } else {
        [self.delegate threeDSService:self didFinishWithResponse:nil error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Missing transaction id."}]];
    }
}

- (void)confirmWithTransactionId:(NSString *)transactionId
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];

    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = self.intentId;
    request.type = AWXThreeDSValidate;
    request.dsTransactionId = transactionId;
    request.device = self.device;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    // Step 4: Request 3DS JWT validation response by `confirmPaymentIntent` with `transactionId`
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:error];
            return;
        }

        [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:response error:error];
    }];
}

- (void)getPaRes:(NSString *)Id completion:(void(^)(AWXGetPaResResponse *))completion;
{
    AWXAPIClientConfiguration *configuration = [[AWXAPIClientConfiguration alloc] init];
    configuration.baseURL = [NSURL URLWithString:[Airwallex cybsURL]];
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:configuration];

    AWXGetPaResRequest *request = [AWXGetPaResRequest new];
    request.paResId = Id;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:error];
            return;
        }

        completion(response);
    }];
}

@end

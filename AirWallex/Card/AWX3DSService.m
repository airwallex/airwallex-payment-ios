//
//  AWX3DSService.m
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWX3DSService.h"
#import "AWXAPIClient.h"
#import "AWX3DSRequest.h"
#import "AWX3DSViewController.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"

@interface AWX3DSService ()

@property (strong, nonatomic) AWXAPIClient *client;
@property (strong, nonatomic) NSString *transactionId;

@end

@implementation AWX3DSService

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)presentThreeDSFlowWithServerJwt:(NSString *)serverJwt bin:(NSString *)bin url:(NSURL *)url
{
    //    AWXAPIClientConfiguration *configuration = [AWXAPIClientConfiguration new];
    //    configuration.baseURL = url;
    //    self.client = [[AWXAPIClient alloc] initWithConfiguration:configuration];
    //
    //    AWX3DSCollectDeviceDataRequest *request = [AWX3DSCollectDeviceDataRequest new];
    //    request.jwt = serverJwt;
    //    request.bin = bin;
    //    [self.client send:request handler:^(AWXResponse * _Nullable response, NSError * _Nullable error) {
    //
    //    }];
    
    NSString *template = @"\
     <html>\
     <body>\
       <form id='collectionForm' name='devicedata' method='POST' action='https://centinelapistag.cardinalcommerce.com/V1/Cruise/Collect'>\
         <input type='hidden' name='Bin' value='${BIN}' />\
         <input type='hidden' name='JWT' value='${JWT}' />\
         <input type='submit' name='continue' value='Continue' />\
       </form>\
     </body>\
     </html>";
    NSString *HTMLString = [template stringByReplacingOccurrencesOfString:@"${BIN}" withString:bin];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"${JWT}" withString:serverJwt];
    
    __weak __typeof(self)weakSelf = self;
    AWX3DSViewController *webViewController = [[AWX3DSViewController alloc] initWithHTMLString:HTMLString webHandler:^(NSString * _Nullable payload, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (payload) {
            [strongSelf confirmWithAcsResponse:payload];
        } else {
            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:error];
        }
    }];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.delegate threeDSService:self shouldPresentViewController:navigationController];
}

- (void)confirmWithAcsResponse:(NSString *)acsResponse
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    
    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = self.intentId;
    request.type = AWXThreeDSContinue;
    request.acsResponse = acsResponse;
    request.returnURL = AWXThreeDSReturnURL;
    request.device = self.device;
    
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(AWXResponse * _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error) {
            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:error];
            return;
        }
        
        AWXConfirmPaymentIntentResponse *result = (AWXConfirmPaymentIntentResponse *)response;
        if ([result.status isEqualToString:@"REQUIRES_CAPTURE"] || result.nextAction == nil) {
            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:result error:nil];
            return;
        }
//
//        // Step 3: Show 3DS UI, then wait user input. After user input, will receive `processorTransactionId`
//        AWXAuthenticationData *authenticationData = result.latestPaymentAttempt.authenticationData;
//        AWXRedirectThreeDSResponse *redirectResponse = [AWXRedirectThreeDSResponse decodeFromJSON:result.nextAction.payload[@"data"]];
//        if (authenticationData.isThreeDSVersion2) {
//            // 3DS v2.x flow
//            if (redirectResponse.xid && redirectResponse.req) {
//                strongSelf.transactionId = redirectResponse.xid;
//                [strongSelf.session continueWithTransactionId:redirectResponse.xid payload:redirectResponse.req didValidateDelegate:self];
//            } else {
//                [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Missing transaction id or payload.", nil)}]];
//            }
//        } else if (redirectResponse.acs && redirectResponse.req) {
//            // 3DS v1.x flow
//            NSURL *url = [NSURL URLWithString:redirectResponse.acs];
//            NSString *reqEncoding = [redirectResponse.req stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet allURLQueryAllowedCharacterSet]];
//            NSString *termUrlEncoding = [[NSString stringWithFormat:@"%@pa/webhook/cybs/pares/callback", [Airwallex defaultBaseURL]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet allURLQueryAllowedCharacterSet]];
//            NSString *body = [NSString stringWithFormat:@"&PaReq=%@&TermUrl=%@", reqEncoding, termUrlEncoding];
//            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
//            urlRequest.HTTPMethod = @"POST";
//            urlRequest.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
//            [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//            [urlRequest setValue:@"Airwallex-iOS-SDK" forHTTPHeaderField:@"User-Agent"];
//            __weak __typeof(self)weakSelf = self;
//            AWXWebViewController *webViewController = [[AWXWebViewController alloc] initWithURLRequest:urlRequest webHandler:^(NSString * _Nullable paResId, NSError * _Nullable error) {
//                __strong __typeof(weakSelf)strongSelf = weakSelf;
//                if (paResId) {
//                    __weak __typeof(self)_weakSelf = strongSelf;
//                    [strongSelf getPaRes:paResId completion:^(AWXGetPaResResponse *paResResponse) {
//                        __strong __typeof(weakSelf)_strongSelf = _weakSelf;
//                        [_strongSelf confirmWithTransactionId:paResResponse.paRes];
//                    }];
//                } else {
//                    [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:error];
//                }
//            }];
//            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
//            navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
//            [strongSelf.delegate threeDSService:strongSelf shouldPresentViewController:navigationController];
//        } else {
//            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to determine the challenge is 1.x or 2.x.", nil)}]];
//        }
    }];
}

@end

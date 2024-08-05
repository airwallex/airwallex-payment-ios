//
//  AWX3DSService.m
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWX3DSService.h"
#import "AWX3DSViewController.h"
#import "AWXAPIClient.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXUtils.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWX3DSService ()

@property (strong, nonatomic) AWXAPIClient *client;
@property (strong, nonatomic) NSString *transactionId;

@end

@implementation AWX3DSService

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)present3DSFlowWithNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    NSString *stage = nextAction.stage;
    NSString *method = nextAction.method;
    NSString *action = nextAction.url;

    NSMutableArray *inputs = [NSMutableArray array];
    NSDictionary *payload = nextAction.payload;
    for (NSString *key in payload.keyEnumerator) {
        [inputs addObject:[NSString stringWithFormat:@"<input type='hidden' name='%@' value='%@' />", key, payload[key]]];
    }
    NSString *inputsText = [inputs componentsJoinedByString:@""];

    NSString *template = @"\
     <html>\
     <body>\
       <form id='collectionForm' name='devicedata' method='${METHOD}' action='${ACTION}'>\
         ${INPUT}\
         <input type='submit' name='continue' value='Continue' />\
       </form>\
     <script>\
        window.onload = function(){\
            var form = document.getElementById('collectionForm');\
            var formAction = form.getAttribute('action');\
            if(formAction !== undefined && formAction.length > 0 && formAction !== 'null'){\
                form.submit();\
            }\
        };\
     </script>\
     </body>\
     </html>";

    NSString *HTMLString = [template stringByReplacingOccurrencesOfString:@"${METHOD}" withString:method];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"${ACTION}" withString:action];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"${INPUT}" withString:inputsText];

    __weak __typeof(self) weakSelf = self;
    AWX3DSViewController *webViewController = [[AWX3DSViewController alloc] initWithHTMLString:HTMLString
                                                                                         stage:stage
                                                                                    webHandler:^(NSString *_Nullable payload, NSError *_Nullable error) {
                                                                                        __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                        if (payload) {
                                                                                            [strongSelf confirmWithAcsResponse:payload];
                                                                                        } else {
                                                                                            [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:error];
                                                                                        }
                                                                                    }];

    if ([stage isEqualToString:AWXThreeDSWatingDeviceDataCollection]) {
        [self.delegate threeDSService:self shouldInsertViewController:webViewController];
    } else if ([stage isEqualToString:AWXThreeDSWaitingUserInfoInput]) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
        [self.delegate threeDSService:self.delegate shouldPresentViewController:navigationController];
    } else {
        [self.delegate threeDSService:self didFinishWithResponse:nil error:[NSError errorForAirwallexSDKWith:NSLocalizedString(@"Invalid stage.", nil)]];
    }
}

- (void)confirmWithAcsResponse:(NSString *)acsResponse {
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];

    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = self.intentId;
    request.type = AWXThreeDSContinue;
    request.acsResponse = acsResponse;
    request.returnURL = AWXThreeDSReturnURL;
    request.device = self.device;

    __weak __typeof(self) weakSelf = self;
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             __strong __typeof(weakSelf) strongSelf = weakSelf;
             if (error) {
                 [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:nil error:error];
                 return;
             }

             AWXConfirmPaymentIntentResponse *result = (AWXConfirmPaymentIntentResponse *)response;
             if (result.nextAction == nil) {
                 [strongSelf.delegate threeDSService:strongSelf didFinishWithResponse:result error:nil];
                 return;
             }

             [strongSelf present3DSFlowWithNextAction:result.nextAction];
         }];
}

@end

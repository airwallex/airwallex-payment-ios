//
//  MockViewController.m
//  Examples
//
//  Created by Weiping Li on 2025/4/17.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#import "MockViewController.h"

#if __has_include("Airwallex.h")
@import Airwallex;
#else
@import AirwallexPaymentSheet;
@import AirwallexPayment;
@import AirwallexCore;
#endif

@interface MockViewController ()<AWXPaymentResultDelegate>

@end

@implementation MockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)testObjcAPIVisibility {
    Session *session = [[Session alloc] initWithCountryCode:@"AU"
                                              paymentIntent:AWXPaymentIntent.new
                                                  returnURL:@""
                                            applePayOptions:nil
                                                autoCapture:true
                              autoSaveCardForFuturePayments:true
                                                    billing:nil
                                        hidePaymentConsents:false
                                                       lang:nil
                                             paymentMethods:nil
                                           recurringOptions:nil
                               requiredBillingContactFields:AWXRequiredBillingContactFieldName];
    [AWXUIContext launchPaymentFrom:self session:session filterBy:nil launchStyle:LaunchStylePush layout:PaymentLayoutTab];
    [AWXUIContext launchPaymentFrom:self session:session paymentResultDelegate:self filterBy:nil launchStyle:LaunchStylePresent layout:PaymentLayoutAccordion];
    [AWXUIContext launchCardPaymentFrom:self session:session supportedBrands:@[] launchStyle:LaunchStylePush];
    [AWXUIContext launchCardPaymentFrom:self session:session paymentResultDelegate:self supportedBrands:@[] launchStyle:LaunchStylePush];
    [AWXUIContext launchPaymentWithName:@"foo" from:self session:session paymentResultDelegate:self supportedBrands:@[] launchStyle:LaunchStylePresent];

    AWXCard *card = [[AWXCard alloc] init];
    AWXPlaceDetails *billing = [AWXPlaceDetails new];
    AWXPaymentConsent *consent = [AWXPaymentConsent new];
    PaymentSessionHandler *handler = [[PaymentSessionHandler alloc] initWithSession:session viewController:self paymentResultDelegate:self methodType:nil];
    handler = [[PaymentSessionHandler alloc] initWithSession:session viewController:self methodType:nil];
    [handler startApplePay];
    [handler startCardPaymentWith:card billing:billing saveCard:false];
    [handler startConsentPaymentWith:consent];
    [handler startConsentPaymentWithId:@"id"];
    [handler startRedirectPaymentWith:@"paypal" additionalInfo:@{}];
}

// AWXPaymentResultDelegate

- (void)paymentViewController:(UIViewController *_Nullable)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
}

- (void)paymentViewController:(UIViewController *)controller didCompleteWithPaymentConsentId:(NSString *)paymentConsentId {
}

@end

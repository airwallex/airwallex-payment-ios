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

@interface MockViewController ()<AWXPaymentResultDelegate, PaymentIntentProvider>

@end

@implementation MockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)testObjcAPIVisibility {
    TermsOfUse *termsOfUse = [[TermsOfUse alloc] initWithBillingCycleChargeDay:3 endDate:NSDate.date firstPaymentAmount:nil fixedPaymentAmount:nil maxPaymentAmount:nil minPaymentAmount:nil paymentAmountType:PaymentAmountTypeFixed paymentCurrency:nil paymentSchedule:[[PaymentSchedule alloc] initWithPeriod:1 periodUnit:PeriodUnitDay] startDate:nil totalBillingCycles:1];
    PaymentConsentOptions *options = [[PaymentConsentOptions alloc] initWithNextTriggeredBy:AirwallexNextTriggerByMerchantType merchantTriggerReason:AirwallexMerchantTriggerReasonScheduled termsOfUse:termsOfUse];
    Session *session = [[Session alloc] initWithPaymentIntent:AWXPaymentIntent.new
                                                  countryCode:@"AU"
                                              applePayOptions:nil
                                                  autoCapture:true
                                autoSaveCardForFuturePayments:true
                                                      billing:nil
                                          hidePaymentConsents:false
                                                         lang:nil
                                               paymentMethods:nil
                                        paymentConsentOptions:options
                                 requiredBillingContactFields:AWXRequiredBillingContactFieldName
                                                    returnURL:@""];
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

    do {
        Session *session = [[Session alloc] initWithPaymentIntentProvider:self
                                                              countryCode:@"AU"
                                                          applePayOptions:nil
                                                              autoCapture:true
                                            autoSaveCardForFuturePayments:true
                                                                  billing:nil
                                                      hidePaymentConsents:false
                                                                     lang:nil
                                                           paymentMethods:nil
                                                    paymentConsentOptions:options
                                             requiredBillingContactFields:AWXRequiredBillingContactFieldName
                                                                returnURL:@""];

        PaymentSessionHandler *handler = [[PaymentSessionHandler alloc] initWithSession:session viewController:self methodType:nil];
        handler.showIndicator = false;
    } while (0);
}

// AWXPaymentResultDelegate

- (void)paymentViewController:(UIViewController *_Nullable)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
}

- (void)paymentViewController:(UIViewController *)controller didCompleteWithPaymentConsentId:(NSString *)paymentConsentId {
}

// PaymentIntentProvider

- (NSDecimalNumber *)amount {
    return [NSDecimalNumber decimalNumberWithString:@"100"];
}

- (NSString *)currency {
    return @"AUD";
}

- (NSString *)customerId {
    return @"mock_customer_id";
}

- (void)createPaymentIntentWithCompletionHandler:(void (^)(AWXPaymentIntent *_Nullable, NSError *_Nullable))completionHandler {
    AWXPaymentIntent *intent = [[AWXPaymentIntent alloc] init];
    intent.amount = self.amount;
    intent.currency = self.currency;
    intent.customerId = self.customerId;
    intent.Id = [NSString stringWithFormat:@"mock_intent_%@", [[NSUUID UUID] UUIDString]];
    intent.clientSecret = [NSString stringWithFormat:@"mock_secret_%@", [[NSUUID UUID] UUIDString]];
    completionHandler(intent, nil);
}

@end

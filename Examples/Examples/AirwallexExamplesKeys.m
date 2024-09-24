//
//  AirwallexExamplesKeys.m
//  Examples
//
//  Created by Victor Zhu on 2021/7/1.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AirwallexExamplesKeys.h"

@interface AirwallexExamplesKeys ()

@property (nonatomic, strong) NSDictionary *configJson;

@end

@implementation AirwallexExamplesKeys

+ (instancetype)shared {
    static AirwallexExamplesKeys *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = [self new];
    });
    return keys;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.configJson = [self loadConfigFile:@"Keys"];
        [self syncKeys];
    }
    return self;
}

- (NSDictionary *)loadConfigFile:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json" inDirectory:@"Keys"];
    if (path) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        if (data) {
            return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        }
    }
    return nil;
}

- (void)resetKeys {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedEnvironment];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCheckoutMode];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedNextTriggerBy];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedRequiresCVC];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedForce3DS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedApiKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedClientId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCurrency];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCountryCode];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedReturnURL];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCachedAutoCapture];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCachedApplePayMethodOnly];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCachedRedirectPayOnly];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCachedCardMethodOnly];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self syncKeys];
}

- (void)syncKeys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.environment = [userDefaults integerForKey:kCachedEnvironment];
    self.checkoutMode = [userDefaults integerForKey:kCachedCheckoutMode];
    self.nextTriggerByType = [userDefaults integerForKey:kCachedNextTriggerBy];
    self.requireCVC = [userDefaults boolForKey:kCachedRequiresCVC];
    self.force3DS = [userDefaults boolForKey:kCachedForce3DS];
    self.autoCapture = [userDefaults boolForKey:kCachedAutoCapture];
    self.applePayMethodOnly = [userDefaults boolForKey:kCachedApplePayMethodOnly];
    self.redirectPayOnly = [userDefaults boolForKey:kCachedRedirectPayOnly];
    self.cardMethodOnly = [userDefaults boolForKey:kCachedCardMethodOnly];
    self.customerId = [userDefaults stringForKey:kCachedCustomerID];

    NSString *cachedApiKey = [userDefaults stringForKey:kCachedApiKey];

    self.apiKey = cachedApiKey ?: self.configJson[@"api_key"];
    self.clientId = [userDefaults stringForKey:kCachedClientId] ?: self.configJson[@"client_id"];
    self.amount = [userDefaults stringForKey:kCachedAmount] ?: self.configJson[@"amount"] ?
                                                                                          : @"0";
    self.currency = [userDefaults stringForKey:kCachedCurrency] ?: self.configJson[@"currency"];
    self.countryCode = [userDefaults stringForKey:kCachedCountryCode] ?: self.configJson[@"country_code"];
    self.returnUrl = [userDefaults stringForKey:kCachedReturnURL] ?: self.configJson[@"return_url"];
}

- (void)setEnvironment:(AirwallexSDKMode)environment {
    _environment = environment;
    [[NSUserDefaults standardUserDefaults] setInteger:environment forKey:kCachedEnvironment];
}

- (void)setCheckoutMode:(AirwallexCheckoutMode)checkoutMode {
    _checkoutMode = checkoutMode;
    [[NSUserDefaults standardUserDefaults] setInteger:checkoutMode forKey:kCachedCheckoutMode];
}

- (void)setNextTriggerByType:(AirwallexNextTriggerByType)nextTriggerByType {
    _nextTriggerByType = nextTriggerByType;
    [[NSUserDefaults standardUserDefaults] setInteger:nextTriggerByType forKey:kCachedNextTriggerBy];
}

- (void)setRequireCVC:(BOOL)requireCVC {
    _requireCVC = requireCVC;
    [[NSUserDefaults standardUserDefaults] setBool:requireCVC forKey:kCachedRequiresCVC];
}

- (void)setForce3DS:(BOOL)force3DS {
    _force3DS = force3DS;
    [[NSUserDefaults standardUserDefaults] setBool:force3DS forKey:kCachedForce3DS];
}

- (void)setAutoCapture:(BOOL)autoCapture {
    _autoCapture = autoCapture;
    [[NSUserDefaults standardUserDefaults] setBool:autoCapture forKey:kCachedAutoCapture];
}

- (void)setApplePayMethodOnly:(BOOL)applePayMethodOnly {
    _applePayMethodOnly = applePayMethodOnly;
    [[NSUserDefaults standardUserDefaults] setBool:applePayMethodOnly forKey:kCachedApplePayMethodOnly];
}

- (void)setRedirectPayOnly:(BOOL)redirectPayOnly {
    _redirectPayOnly = redirectPayOnly;
    [[NSUserDefaults standardUserDefaults] setBool:redirectPayOnly forKey:kCachedRedirectPayOnly];
}

- (void)setCardMethodOnly:(BOOL)cardMethodOnly {
    _cardMethodOnly = cardMethodOnly;
    [[NSUserDefaults standardUserDefaults] setBool:cardMethodOnly forKey:kCachedCardMethodOnly];
}

- (void)setCustomerId:(nullable NSString *)customerId {
    _customerId = customerId;
    if (customerId) {
        [[NSUserDefaults standardUserDefaults] setObject:customerId forKey:kCachedCustomerID];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedCustomerID];
    }
}

- (void)setApiKey:(NSString *)apiKey {
    _apiKey = apiKey;
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:kCachedApiKey];
}

- (void)setClientId:(NSString *)clientId {
    _clientId = clientId;
    [[NSUserDefaults standardUserDefaults] setObject:clientId forKey:kCachedClientId];
}

- (void)setAmount:(NSString *)amount {
    _amount = amount;
    [[NSUserDefaults standardUserDefaults] setObject:amount forKey:kCachedAmount];
}

- (void)setCurrency:(NSString *)currency {
    _currency = currency;
    [[NSUserDefaults standardUserDefaults] setObject:currency forKey:kCachedCurrency];
}

- (void)setCountryCode:(NSString *)countryCode {
    _countryCode = countryCode;
    [[NSUserDefaults standardUserDefaults] setObject:countryCode forKey:kCachedCountryCode];
}

- (void)setReturnUrl:(NSString *)returnUrl {
    _returnUrl = returnUrl;
    [[NSUserDefaults standardUserDefaults] setObject:returnUrl forKey:kCachedReturnURL];
}

@end

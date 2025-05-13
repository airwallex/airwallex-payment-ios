//
//  AWXAPIClient.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXAPIErrorResponse+Update.h"
#import "AWXAPIResponse.h"
#import "AWXAnalyticsLogger.h"
#import "AWXLogger.h"
#import "AWXUtils.h"
#import "NSData+Base64.h"
#import "NSObject+Logging.h"
#import <AirwallexRisk/AirwallexRisk-Swift.h>

static NSString *const AWXAPIDemoBaseURL = @"https://api-demo.airwallex.com/";
static NSString *const AWXAPIStagingBaseURL = @"https://api-staging.airwallex.com/";
static NSString *const AWXAPIProductionBaseURL = @"https://api.airwallex.com/";

@implementation Airwallex

static NSURL *_defaultBaseURL;

static AirwallexSDKMode _mode = AirwallexSDKProductionMode;

static BOOL _analyticsEnabled = YES;

static BOOL _localLogFileEnabled = NO;

+ (void)setDefaultBaseURL:(NSURL *)baseURL {
    _defaultBaseURL = [baseURL URLByAppendingPathComponent:@""];
}

+ (NSURL *)defaultBaseURL {
    if (_defaultBaseURL) {
        return _defaultBaseURL;
    }

    switch (_mode) {
    case AirwallexSDKProductionMode:
        return [NSURL URLWithString:AWXAPIProductionBaseURL];
    case AirwallexSDKStagingMode:
        return [NSURL URLWithString:AWXAPIStagingBaseURL];
    case AirwallexSDKDemoMode:
        return [NSURL URLWithString:AWXAPIDemoBaseURL];
    }
}

+ (void)setMode:(AirwallexSDKMode)mode {
    _mode = mode;
}

+ (AirwallexSDKMode)mode {
    return _mode;
}

+ (void)disableAnalytics {
    _analyticsEnabled = NO;
}

+ (void)enableAnalytics {
    _analyticsEnabled = YES;
}

+ (BOOL)analyticsEnabled {
    return _analyticsEnabled;
}

+ (void)enableLocalLogFile {
    _localLogFileEnabled = YES;
}

+ (void)disableLocalLogFile {
    _localLogFileEnabled = NO;
}

+ (BOOL)isLocalLogFileEnabled {
    return _localLogFileEnabled;
}

@end

@implementation AWXAPIClientConfiguration

+ (instancetype)sharedConfiguration {
    static AWXAPIClientConfiguration *sharedConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfiguration = [self new];
        [AWXRisk startWithAccountID:nil with:[[AirwallexRiskConfiguration alloc] initWithEnvironment:[self riskEnvironmentForMode:Airwallex.mode] tenant:TenantPa bufferTimeInterval:5]];
    });
    return sharedConfiguration;
}

+ (AirwallexRiskEnvironment)riskEnvironmentForMode:(AirwallexSDKMode)mode {
    switch (mode) {
    case AirwallexSDKProductionMode:
        return AirwallexRiskEnvironmentProduction;
    case AirwallexSDKStagingMode:
        return AirwallexRiskEnvironmentStaging;
    case AirwallexSDKDemoMode:
        return AirwallexRiskEnvironmentDemo;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    AWXAPIClientConfiguration *copy = [[AWXAPIClientConfiguration allocWithZone:zone] init];
    copy.clientSecret = [self.clientSecret copyWithZone:zone];
    return copy;
}

- (NSURL *)baseURL {
    return Airwallex.defaultBaseURL;
}

- (void)setClientSecret:(NSString *)clientSecret {
    _clientSecret = [clientSecret copy];
    [AWXRisk setWithAccountID:self.accountID];
}

- (NSString *)accountID {
    NSArray<NSString *> *splitedClientSecret = [self.clientSecret componentsSeparatedByString:@"."];
    NSString *encodedSecret;
    if (splitedClientSecret.count > 1) {
        encodedSecret = splitedClientSecret[1];
    }
    NSData *decodedData = [NSData initWithBase64NoPaddingString:encodedSecret];
    NSString *accountId;
    if (decodedData != nil) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:decodedData options:0 error:nil];
        accountId = [dict objectForKey:@"account_id"];
    }
    return accountId;
}

@end

@implementation AWXRequest

- (NSString *)requestId {
    if (!_requestId) {
        _requestId = NSUUID.UUID.UUIDString;
    }
    return _requestId;
}

- (NSString *)path {
    [[AWXLogger sharedLogger] logException:@"path required"];
    return nil;
}

- (AWXHTTPMethod)method {
    return AWXHTTPMethodGET;
}

- (NSDictionary *)headers {
    return @{@"Content-Type": @"application/json", @"x-api-version": AIRWALLEX_API_VERSION};
}

- (nullable NSDictionary *)parameters {
    return nil;
}

- (nullable NSData *)postData {
    return nil;
}

- (Class)responseClass {
    [[AWXLogger sharedLogger] logEvent:@"responseClass is not overridden, but is not required"];
    return nil;
}

/**
 - Note:
 This event name is automatically retreived from the request class name based on the assumption that the naming follows `AWX****Request` convention,
 e.g. `AWXGetPaymentMethodsRequest` corresponds to the event name `get_payment_methods`.
 If we change the naming rules for these request classes, this method also needs to be updated.
*/
- (NSString *)eventName {
    NSString *requestName = NSStringFromClass([self class]);
    NSString *truncatedName = [[requestName stringByReplacingOccurrencesOfString:@"AWX" withString:@""] stringByReplacingOccurrencesOfString:@"Request" withString:@""];
    return [[truncatedName stringByInsertingBetweenWordsWithString:@"_"] lowercaseString];
}

@end

@implementation AWXResponse

+ (AWXResponse *)parse:(NSData *)data {
    [[AWXLogger sharedLogger] logException:@"parse method require override"];
    return nil;
}

+ (nullable AWXResponse *)parseError:(NSData *)data {
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (json == nil) {
        return nil;
    }
    NSString *message = json[@"message"];
    NSString *code = json[@"code"];
    return [[AWXAPIErrorResponse alloc] initWithMessage:message code:code];
}

@end

@interface AWXAPIClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation AWXAPIClient

- (instancetype)init {
    return [self initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
}

- (instancetype)initWithConfiguration:(AWXAPIClientConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;
        if (configuration.sessionConfiguration) {
            _session = [NSURLSession sessionWithConfiguration:configuration.sessionConfiguration];
        } else {
            _session = [NSURLSession sharedSession];
        }
        [self log:@"Current connected domain:%@", Airwallex.defaultBaseURL];
    }
    return self;
}

- (void)send:(AWXRequest *)request withCompletionHandler:(AWXRequestHandler)handler {
    NSString *method = @"POST";
    NSURL *url = [NSURL URLWithString:request.path relativeToURL:self.configuration.baseURL];

    if (request.method == AWXHTTPMethodGET) {
        method = @"GET";
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", url.absoluteString, request.parameters ? [request.parameters queryURLEncoding] : @""]];
    }
    [self log:@"URL request: %@   Class:%@", url.absoluteString, request.class];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = method;

    NSDictionary *headers = request.headers;
    for (NSString *key in headers) {
        [urlRequest setValue:headers[key] forHTTPHeaderField:key];
    }
    if (self.configuration.clientSecret) {
        [urlRequest setValue:self.configuration.clientSecret forHTTPHeaderField:@"client-secret"];
    } else {
        [self log:@"Client secret is not set!"];
    }
    [urlRequest setValue:@"Airwallex-iOS-SDK" forHTTPHeaderField:@"User-Agent"];
    if (request.parameters && [NSJSONSerialization isValidJSONObject:request.parameters] && request.method == AWXHTTPMethodPOST) {
        urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:request.parameters options:NSJSONWritingPrettyPrinted error:nil];
    }
    if (request.postData) {
        urlRequest.HTTPBody = request.postData;
    }

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest
                                                 completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                     if (handler) {
                                                         NSHTTPURLResponse *result = (NSHTTPURLResponse *)response;
                                                         if (data && request.responseClass != nil) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 if (result.statusCode >= 200 && result.statusCode < 300 && [request.responseClass respondsToSelector:@selector(parse:)]) {
                                                                     id response = [request.responseClass performSelector:@selector(parse:) withObject:data];
                                                                     handler(response, error);
                                                                 } else {
                                                                     AWXAPIErrorResponse *errorResponse = [request.responseClass performSelector:@selector(parseError:) withObject:data];
                                                                     if (errorResponse) {
                                                                         [[AWXAnalyticsLogger shared] logErrorWithName:[request eventName] url:urlRequest.URL response:[errorResponse updatedResponseWithStatusCode:result.statusCode Error:error] additionalInfo:@{@"request_id": request.requestId}];
                                                                         handler(nil, errorResponse.error);
                                                                     } else {
                                                                         handler(nil, [NSError errorWithDomain:AWXSDKErrorDomain code:result.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Couldn't parse response."}]);
                                                                     }
                                                                 }
                                                             });
                                                         } else {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 handler(nil, error);
                                                             });
                                                         }
                                                     }
                                                 }];
    [task resume];
}

@end

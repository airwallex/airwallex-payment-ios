//
//  AWXAPIClient.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXProtocol.h"
#import "AWXRequestProtocol.h"
#import "AWXResponseProtocol.h"
#import "AWXLogger.h"
#import "AWXAPIResponse.h"
#import "AWXUtils.h"

static NSString * const AWXAPIBaseTestURL = @"https://staging-pci-api.airwallex.com/";
static NSString * const AWXAPIBaseLiveURL = @"https://pci-api.airwallex.com/";

@implementation Airwallex

static NSURL *_defaultBaseURL;
static AirwallexSDKMode _mode = AirwallexSDKTestMode;

+ (void)setDefaultBaseURL:(NSURL *)baseURL
{
    _defaultBaseURL = [baseURL URLByAppendingPathComponent:@""];
}

+ (NSURL *)defaultBaseURL
{
    return _defaultBaseURL ?: (_mode == AirwallexSDKLiveMode ? [NSURL URLWithString:AWXAPIBaseLiveURL] : [NSURL URLWithString:AWXAPIBaseTestURL]);
}

+ (void)setMode:(AirwallexSDKMode)mode
{
    _mode = mode;
}

+ (AirwallexSDKMode)mode
{
    return _mode;
}

@end

@implementation AWXAPIClientConfiguration

+ (instancetype)sharedConfiguration
{
    static AWXAPIClientConfiguration *sharedConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfiguration = [self new];
    });
    return sharedConfiguration;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.baseURL = [Airwallex defaultBaseURL];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    AWXAPIClientConfiguration *copy = [[AWXAPIClientConfiguration allocWithZone:zone] init];
    copy.baseURL = [self.baseURL copyWithZone:zone];
    copy.clientSecret = [self.clientSecret copyWithZone:zone];
    return copy;
}

@end

@implementation AWXCustomerAPIClientConfiguration

+ (instancetype)sharedConfiguration
{
    static AWXCustomerAPIClientConfiguration *sharedConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfiguration = [self new];
    });
    return sharedConfiguration;
}

@end

@defs(AWXRequestProtocol)

- (NSString *)path
{
    [[AWXLogger sharedLogger] logException:@"path required"];
    return nil;
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodGET;
}

- (NSDictionary *)headers
{
    return @{@"Content-Type": @"application/json", @"x-api-version": AIRWALLEX_API_VERSION};
}

- (nullable NSDictionary *)parameters
{
    return nil;
}

- (Class)responseClass
{
    [[AWXLogger sharedLogger] logEvent:@"responseClass is not overridden, but is not required"];
    return nil;
}

@end

@defs(AWXResponseProtocol)

+ (id <AWXResponseProtocol>)parse:(NSData *)data
{
    [[AWXLogger sharedLogger] logException:@"parse method require override"];
    return nil;
}

+ (nullable id <AWXResponseProtocol>)parseError:(NSData *)data
{
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

@implementation AWXAPIClient

+ (instancetype)sharedClient
{
    static AWXAPIClient *sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [self new];
    });
    return sharedClient;
}

- (instancetype)init
{
    return [self initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
}

- (instancetype)initWithConfiguration:(AWXAPIClientConfiguration *)configuration
{
    self = [super init];
    if (self) {
        _configuration = configuration;
    }
    return self;
}

- (void)send:(id <AWXRequestProtocol>)request handler:(AWXRequestHandler)handler
{
    NSString *method = @"POST";
    NSURL *url = [NSURL URLWithString:request.path relativeToURL:self.configuration.baseURL];
    
    if (request.method == AWXHTTPMethodGET) {
        method = @"GET";
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", url.absoluteString, request.parameters ? [request.parameters queryURLEncoding] : @""]];
    }

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = method;

    NSDictionary *headers = request.headers;
    for (NSString *key in headers) {
        [urlRequest setValue:headers[key] forHTTPHeaderField:key];
    }
    if (self.configuration.clientSecret) {
        [urlRequest setValue:self.configuration.clientSecret forHTTPHeaderField:@"client-secret"];
    }

    if (request.parameters && [NSJSONSerialization isValidJSONObject:request.parameters] && request.method == AWXHTTPMethodPOST) {
        urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:request.parameters options:NSJSONWritingPrettyPrinted error:nil];
    }

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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

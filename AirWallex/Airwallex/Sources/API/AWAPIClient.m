//
//  AWAPIClient.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWAPIClient.h"
#import "AWProtocol.h"
#import "AWRequestProtocol.h"
#import "AWResponseProtocol.h"
#import "AWLogger.h"
#import "AWAPIResponse.h"
#import "AWUtils.h"

static NSString * const AWAPIBaseURL = @"https://pci-api.ariwallex.com/";

@implementation Airwallex

static NSURL *_defaultBaseURL;

+ (void)setDefaultBaseURL:(NSURL *)baseURL
{
    _defaultBaseURL = [baseURL URLByAppendingPathComponent:@""];
}

+ (NSURL *)defaultBaseURL
{
    return _defaultBaseURL ?: [NSURL URLWithString:AWAPIBaseURL];
}

@end

@implementation AWAPIClientConfiguration

+ (instancetype)sharedConfiguration
{
    static AWAPIClientConfiguration *sharedConfiguration;
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
    AWAPIClientConfiguration *copy = [[AWAPIClientConfiguration allocWithZone:zone] init];
    copy.baseURL = [self.baseURL copyWithZone:zone];
    copy.clientSecret = [self.clientSecret copyWithZone:zone];
    return copy;
}

@end

@defs(AWRequestProtocol)

- (NSString *)path
{
    [[AWLogger sharedLogger] logException:@"path required"];
    return nil;
}

- (AWHTTPMethod)method
{
    return AWHTTPMethodGET;
}

- (NSDictionary *)headers
{
    return @{@"Content-Type": @"application/json"};
}

- (nullable NSDictionary *)parameters
{
    return nil;
}

- (Class)responseClass
{
    [[AWLogger sharedLogger] logEvent:@"responseClass is not overridden, but is not required"];
    return nil;
}

@end

@defs(AWResponseProtocol)

+ (id <AWResponseProtocol>)parse:(NSData *)data
{
    [[AWLogger sharedLogger] logException:@"parse method require override"];
    return nil;
}

+ (nullable id <AWResponseProtocol>)parseError:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (responseObject == nil) {
        return nil;
    }
    NSString *message = [responseObject valueForKey:@"message"];
    NSString *code = [responseObject valueForKey:@"code"];
    NSString *type = [responseObject valueForKey:@"type"];
    NSNumber *statusCode = [responseObject valueForKey:@"status_code"];
    return [[AWAPIErrorResponse alloc] initWithMessage:message code:code type:type statusCode:statusCode];
}

@end

@implementation AWAPIClient

+ (instancetype)sharedClient
{
    static AWAPIClient *sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [self new];
    });
    return sharedClient;
}

- (instancetype)init
{
    return [self initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
}

- (instancetype)initWithConfiguration:(AWAPIClientConfiguration *)configuration
{
    self = [super init];
    if (self) {
        _configuration = configuration;
    }
    return self;
}

- (void)send:(id <AWRequestProtocol>)request handler:(AWRequestHandler)handler
{
    NSString *method = @"POST";
    NSURL *url = [NSURL URLWithString:request.path relativeToURL:self.configuration.baseURL];
    
    if (request.method == AWHTTPMethodGET) {
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

    if (request.parameters && [NSJSONSerialization isValidJSONObject:request.parameters] && request.method == AWHTTPMethodPOST) {
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
                        AWAPIErrorResponse *errorResponse = [request.responseClass performSelector:@selector(parseError:) withObject:data];
                        if (errorResponse) {
                            NSDictionary *errorJson = @{NSLocalizedDescriptionKey: errorResponse.message ?: @""};
                            handler(nil, [errorJson convertToNSErrorWithCode:@(errorResponse.code.integerValue)]);
                        } else {
                            handler(nil, [@{NSLocalizedDescriptionKey: @"Couldn't parse response."} convertToNSErrorWithCode:@(result.statusCode)]);
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

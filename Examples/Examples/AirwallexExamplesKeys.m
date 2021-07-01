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

+ (instancetype)shared
{
    static AirwallexExamplesKeys *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = [self new];
    });
    return keys;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
#ifdef DEMO
        self.configJson = [self loadConfigFile:@"Demo"];
#else
        self.configJson = [self loadConfigFile:@"Production"];
#endif
    }
    return self;
}

- (NSDictionary *)loadConfigFile:(NSString *)filename
{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    if (path) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        if (data) {
            return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        }
    }
    return nil;
}

- (NSString *)apiKey
{
    return self.configJson[@"api_key"];
}

- (NSString *)clientId
{
    return self.configJson[@"client_id"];
}

- (NSString *)baseUrl
{
    return self.configJson[@"base_url"];
}

- (NSString *)weChatAppId
{
    return self.configJson[@"we_chat_app_id"];
}

- (NSString *)amount
{
    return self.configJson[@"amount"] ?: @"0";
}

- (NSString *)currency
{
    return self.configJson[@"currency"];
}

@end

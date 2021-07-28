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
#elif STAGING
        self.configJson = [self loadConfigFile:@"Staging"];
#else
        self.configJson = [self loadConfigFile:@"Production"];
#endif
        [self resetKeys];
    }
    return self;
}

- (NSDictionary *)loadConfigFile:(NSString *)filename
{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json" inDirectory:@"Keys"];
    if (path) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        if (data) {
            return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        }
    }
    return nil;
}

- (void)resetKeys
{
    self.apiKey = self.configJson[@"api_key"];
    self.clientId = self.configJson[@"client_id"];
    self.baseUrl = self.configJson[@"base_url"];
    self.amount = self.configJson[@"amount"] ?: @"0";
    self.currency = self.configJson[@"currency"];
}

@end

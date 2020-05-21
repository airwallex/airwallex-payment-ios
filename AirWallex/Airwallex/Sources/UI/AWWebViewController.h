//
//  AWWebViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/5/18.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Airwallex/Airwallex.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AWWebHandler)(NSString * _Nullable payload, NSError * _Nullable error);

@interface AWWebViewController : AWViewController

//- (instancetype)initWithURL:(NSURL *)URL webHandler:(AWWebHandler)webHandler;
- (instancetype)initWithURLRequest:(NSURLRequest *)urlRequest webHandler:(AWWebHandler)webHandler;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

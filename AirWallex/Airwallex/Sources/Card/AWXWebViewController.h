//
//  AWXWebViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/5/18.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Airwallex/Airwallex.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AWXWebHandler)(NSString * _Nullable payload, NSError * _Nullable error);

@interface AWXWebViewController : AWXViewController

- (instancetype)initWithURLRequest:(NSURLRequest *)urlRequest webHandler:(AWXWebHandler)webHandler;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

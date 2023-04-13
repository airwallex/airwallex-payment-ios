//
//  AWX3DSViewController.h
//  Card
//
//  Created by Victor Zhu on 2022/1/5.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPageViewTrackable.h"
#import "AWXViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^AWXWebHandler)(NSString *_Nullable payload, NSError *_Nullable error);

@interface AWX3DSViewController : AWXViewController<AWXPageViewTrackable>

- (instancetype)initWithHTMLString:(NSString *)HTMLString stage:(NSString *)stage webHandler:(AWXWebHandler)webHandler;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

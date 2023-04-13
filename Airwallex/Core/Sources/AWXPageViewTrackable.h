//
//  AWXPageViewTrackable.h
//  Airwallex
//
//  Created by Hector.Huang on 2023/3/17.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AWXPageViewTrackable

@property (nonatomic, readonly) NSString *pageName;

@optional
@property (nonatomic, readonly) NSDictionary<NSString *, id> *additionalInfo;

@end

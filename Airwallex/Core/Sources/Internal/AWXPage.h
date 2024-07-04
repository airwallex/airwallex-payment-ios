//
//  AWXPage.h
//  Airwallex
//
//  Created by Hector.Huang on 2023/12/12.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AWXPage

@property (nonatomic, readonly) BOOL hasMore;

@property (nonatomic, readonly) NSArray *items;
;

@end

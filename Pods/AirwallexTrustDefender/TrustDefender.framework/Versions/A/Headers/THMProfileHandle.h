/*!
//  Profile.h
//  TrustDefender
//
//  Created by Samin Pour
//  Copyright © 2017 ThreatMetrix. All rights reserved.
//
*/

#ifndef TrustDefender_THMProfileHandle_h
#define TrustDefender_THMProfileHandle_h

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

@interface THMProfileHandle : NSObject

/*! Session ID used for profiling. */
@property(nonatomic, readonly) NSString *sessionID;

/*!
 * Cancels profiling if running, if profiling is finished just returns.
 */
-(void) cancel;

@end

#endif

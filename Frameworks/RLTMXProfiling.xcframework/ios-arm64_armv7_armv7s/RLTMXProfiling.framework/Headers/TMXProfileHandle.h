/*!
  @header RLTMXProfileHandle.h

  @author by Samin Pour
  @copyright 2020 ThreatMetrix. All rights reserved.
*/

#ifndef __TMXPROFILEHANDLE__
#define __TMXPROFILEHANDLE__

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif


#ifndef TMX_PREFIX_NAME
#define NO_COMPAT_CLASS_NAME
#endif



@interface RLTMXProfileHandle : NSObject

/*! @abstract Session ID used for profiling. */
@property(nonatomic, readonly) NSString *sessionID;

-(instancetype) init NS_UNAVAILABLE;
+(instancetype) allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+(instancetype) new NS_UNAVAILABLE;

/*!
 * @abstract Cancels profiling if running, if profiling is finished just returns.
 */
-(void) cancel;

@end

#endif

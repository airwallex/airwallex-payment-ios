/*!
  @header RLTMXProfilingConnections.h

  @author Samin Pour
  @copyright 2020 ThreatMetrix. All rights reserved.

 ThreatMetrix Profiling Connections module for iOS. This header is the main framework header, and is required to make use of the RLTMXProfilingConnections with iOS SDK.
 */
#ifndef __TMXPROFILINGCONNECTIONS__
#define __TMXPROFILINGCONNECTIONS__

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
@import CoreData;
#else
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#endif

#import "TMXProfilingConnectionsProtocol.h"

#ifdef __cplusplus
#define EXTERN        extern "C" __attribute__((visibility ("default")))
#else
#define EXTERN        extern __attribute__((visibility ("default")))
#endif


#ifndef TMX_PREFIX_NAME
#define NO_COMPAT_CLASS_NAME
#endif


__attribute__((visibility("default")))
/*!
 * @interface RLTMXProfilingConnections
 * @abstract Default implementation of TMXProfilingConnectionProtocol
 * @discussion This module is designed for transferring ThreatMetrix profiling data and is not a general
 * purpose networking module.
 */
@interface RLTMXProfilingConnections : NSObject <RLTMXProfilingConnectionsProtocol>

/*!
 * @abstract List of SHA256 hash of public keys used for public key pinning.
 * @discussion If array includes SHA1 or malformed values NSInvalidArgumentException will be thrown.
 * Default is nil (public key pinning is disabled).
 */
@property(nonatomic, readwrite, strong) NSArray * _Nullable publicKeyHashArray;

/*!
 * @abstract List of SAH256 hash of certificate fingerprints used for certificate pinning.
 * @discussion If array includes SHA1 or malformed values NSInvalidArgumentException will be thrown.
 * Default is nil (certificate pinning is disabled).
 */
@property(nonatomic, readwrite, strong) NSArray * _Nullable certificateHashArray;

/*!
 * @abstract RLTMXProfilingConnections version (for debugging purposes only).
 */
@property(nonatomic, readonly, strong) NSString * _Nonnull version;

/*!
 * @abstract Connection timeout interval for each profiling connection.
 * @discussion Default value is 10 seconds.
 */
@property(nonatomic, readwrite) NSTimeInterval connectionTimeout;

/*!
 * @abstract Number of retries per connection.
 * @discussion When connection fails due to unrecoverable reason (e.g. certificate mismatch) this
 * value will be ignored. Default value is 0 (connection retry is disabled).
 */
@property(nonatomic, readwrite) int connectionRetryCount;

- (instancetype _Nullable)allocWithZone:(struct _NSZone * _Nullable) zone NS_UNAVAILABLE;
- (instancetype _Nullable)new NS_UNAVAILABLE;

@end

#endif /* __PROFILINGCONNECTIONS__ */

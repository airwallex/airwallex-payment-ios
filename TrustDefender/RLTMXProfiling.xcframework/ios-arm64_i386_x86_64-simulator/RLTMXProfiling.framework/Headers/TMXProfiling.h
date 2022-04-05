/*!
 @header RLTMXProfiling.h

 @author Nick Blievers
 @copyright 2020 ThreatMetrix. All rights reserved.

 ThreatMetrix SDK for iOS. This header is the main framework header, and is required to make use of the mobile SDK.
 */
#ifndef _TMXPROFILING_H_
#define _TMXPROFILING_H_

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
@import CoreLocation;
#else
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#endif

#import "TMXStatusCode.h"
#import "TMXProfileHandle.h"

#ifdef __cplusplus
#define EXTERN		extern "C" __attribute__((visibility ("default")))
#else
#define EXTERN	    extern __attribute__((visibility ("default")))
#endif


#ifndef TMX_PREFIX_NAME
#define NO_COMPAT_CLASS_NAME
#endif


/*
 * For this to work, all exported symbols must be included here
 */
#ifdef TMX_PREFIX_NAME
#if (!TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR) //macOS Only
#endif

#if (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR) //iOS only
#endif

//Profiling attributes

#endif

NS_ASSUME_NONNULL_BEGIN
// Configure specific options - valid for application lifecycle
/*!
 * @const RLTMXOrgID
 * @abstract NSDictionary key for specifying the org id.
 * @discussion Valid at init time to set the org id.
 * This is mandatory.
 */
EXTERN NSString *const RLTMXOrgID;

/*!
 * @const RLTMXFingerprintServer
 * @abstract NSDictionary key for setting a fingerprint server
 * @discussion Valid at [configure:] time setting an alternative fingerprint server
 */
EXTERN NSString *const RLTMXFingerprintServer;

/*!
 * @const RLTMXApiKey
 * @abstract NSDictionary key for specifying the API key, if one is required.
 * @discussion Valid at [configure:] time to set a key for profiling (different than session query API key)
 * @remark This key is NOT the same as the API key used for session query. Please do not
 * set unless directed by ThreatMetrix services or support, as an incorrectly configured
 * key can result in blocked profiling requests
 *
 */
EXTERN NSString *const RLTMXApiKey;

/*!
 * @const RLTMXLocationServices
 * @abstract NSDictionary key for enabling the location services.
 * @discussion Valid at [configure:] time to enable location services. Note that this will never cause UI
 * interaction -- if the application does not have permissions, no prompt will be made, and no location will be acquired.
 * Default value is \@NO (note use of NSNumber to store BOOL)
 */
EXTERN NSString *const RLTMXLocationServices;

/*!
 * @const RLTMXLocationServicesOnMainThread
 * @abstract NSDictionary key to specify if location services should be enabled on the main thread.
 * @discussion Valid at [configure:] time to enable location services on the main thread. Note that this should
 * be used in combination with RLTMXLocationServices.
 * @remark Using this causes location updates to happen on the main thread therefore it can block / be blocked by
 * other activities on the main thread.
 * Default value is \@NO (note use of NSNumber to store BOOL)
 */
EXTERN NSString *const RLTMXLocationServicesOnMainThread;

/*!
 * @const RLTMXDesiredLocationAccuracy
 * @abstract NSDictionary key for enabling the location services.
 * @discussion Valid at [configure:] time and configures the desired location accuracy.
 * Default value is \@1000.0 (note use of NSNumber to store float) which is equivalent to kCLLocationAccuracyKilometer
 */
EXTERN NSString *const RLTMXDesiredLocationAccuracy;

/*!
 * @const RLTMXKeychainAccessGroup
 * @abstract NSDictionary key for making use of the keychain access group.
 * @discussion Valid at [configure:] time to enable the sharing of data across applications with the same keychain access group.
 * This allows matching device ID across applications from the same vendor.
 */
EXTERN NSString *const RLTMXKeychainAccessGroup;

/*!
 * @const TMXEnableOption
 * @abstract NSDictionary key for setting specific options
 * @discussion Valid at [configure:] time for fine grained control over profiling.
 * @remark Please do NOT set unless directed by ThreatMetrix support or
 * services as it has direct impact on profiling behaviour.
 */
EXTERN NSString *const RLTMXEnableOptions;

/*!
 * @const RLTMXDisableOptions
 * @abstract NSDictionary key for setting specific options
 * @discussion Valid at [configure:] time for fine grained control over profiling.
 * @remark Please do NOT set unless directed by ThreatMetrix support or
 * services as it has direct impact on profiling behaviour.
 */
EXTERN NSString *const RLTMXDisableOptions;

/*!
 * @const RLTMXDisableNonFatalLog
 * @abstract NSDictionary key for disabling non-fatal SDK logs.
 * @discussion Valid at [configure:] time for fine grained control over printing non-fatal logs.
 */
EXTERN NSString *const RLTMXDisableNonFatalLog;


#if (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR)
/*!
 * @const RLTMXDisableAuthenticationModule
 * @abstract NSDictionary key to allow SDK to grab an Apple Push Notification token
 * @discussion Valid at init time to disable TMXAuthentication module
 */
EXTERN NSString *const RLTMXDisableAuthenticationModule;

/*!
 * @const RLTMXPushTokenSwizzling
 * @abstract NSDictionary key to allow method swizzling in Strong Authentication.
 * @discussion Valid at init time for allowing method swizzling to get push token
 * automatically. Should be @NO in case integrity protection tools are used in the
 * final application.
 * @remark When method swizzling is enabled, configure method MUST be called
 * on the main thread and host application should NOT block the main thread. By
 * default the host application is responsible for passing push token to the
 * push token to SDK
 * Default value is \@NO (note use of NSNumber to store BOOL)
 */
EXTERN NSString *const RLTMXPushTokenSwizzling;
#endif

#if (!TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR)
/*!
 * @const TMXKeychainAccessPrompt
 * @abstract NSDictionary key for disabling keychain access
 * @discussion By default TMX SDK accesses the keychain which will cause a user prompt, setting this option to YES will disable accessing keychain.
 * @remark This option is only valid for TMX SDK for macOS
 * Default value is \@NO (note use of NSNumber to store BOOL)
 */
EXTERN NSString *const RLTMXDisableKeychainAccess;
#endif

/*!
 * @const RLTMXProfileTimeout
 * @abstract NSDictionary key for specifying the entire profiling timeout.
 * @discussion Valid at init time to set the entire profiling timeout, defaults to 0s.
 * Default is 0, no time limit on profiling (note use of NSNumber to store int)
 */
EXTERN NSString *const RLTMXProfileTimeout;

/*!
 * @const RLTMXProfilingConnectionsInstance
 * @abstract NSDictionary key for specifying an instance implementing TMXProfilingConnectionsProtocol.
 * @discussion Valid at [configure:] time to set the an instance complying with TMXProfilingConnectionsProtocol.
 * @remark When this key is not included in configure dictionary, ThreatMetrix SDK will try to use the default TMXProfilingConnections module. In this case TMXProfilingConnections framework must be linked to the application.
 */
EXTERN NSString *const  RLTMXProfilingConnectionsInstance;

// Profile specific options - valid during profiling process
/*!
 * @const RLTMXSessionID
 * @abstract NSDictionary key for Session ID.
 * @discussion Valid at profile time, and result time for setting/retrieving the session ID.
 */
EXTERN NSString *const RLTMXSessionID;

/*!
 * @const RLTMXCustomAttributes
 * @abstract NSDictionary key for Custom Attributes. Value should be kind of NSArray class
 * @discussion Valid at profile time for setting the any custom attributes to be included in the profiling data.
 * @remark Only first 5 entries in NSArray will be passed to fingerprint server
 */
EXTERN NSString *const RLTMXCustomAttributes;

/*!
 * @const RLTMXLocation
 * @abstract NSDictionary key for setting location.
 * @discussion Valid at profile time for setting the location to be included in the profiling data.
 * @remark This should only be used if location services are not enabled.
 */
EXTERN NSString *const RLTMXLocation;

// Profile result options (RLTMXSessionID is shared)

/*!
 * @const RLTMXProfileStatus
 * @abstract NSDictionary key for retrieving the profiling status
 * @discussion Valid at results time for getting the status of the current profiling request.
 */
EXTERN NSString *const RLTMXProfileStatus;

// NOTE: headerdoc2html gets confused if this __attribute__ is after the comment
__attribute__((visibility("default")))
/*!
 * @interface RLTMXProfiling
 */
@interface RLTMXProfiling : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone * _Nullable)zone NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 * @abstract Initialise a shared instance of RLTMXProfiling object.
 * @discussion Only 1 instance of RLTMXProfiling is created per application lifecycle.
 * @code
 * RLTMXProfiling *TMX = [RLTMXProfiling sharedInstance];
 * @endcode
 *
 * @return instance of RLTMXProfiling
 */
+ (instancetype _Nullable)sharedInstance NS_SWIFT_NAME(sharedInstance());

/*!
 * @abstract Configures the shared instance of RLTMXProfiling object with the supplied configuration dictionary.
 * @discussion Only the first call to configure will use configuration dictionary, subsequent calls will be ignored
 * @code
 * [RLTMXProfiling sharedInstance] configure:@{
 *                                           RLTMXOrgID: @"my-orgid",
 *                                           RLTMXFingerprintServer: @"enhanced-profiling-domain"
 *                                          }]];
 * @endcode
 *
 * @remark This method runs only once, any following calls has no effect.
 * @param config NSDictionary including all required information to configure RLTMXProfiling instance. List of valid keys for this dictionary can be found in this header.
 * @throws An exception of type NSInvalidArgumentException if config dictionary contains invalid keys or malformed values
 *
 */
- (void)configure:(NSDictionary *)config NS_SWIFT_NAME(configure(configData:));

/*!
 * @abstract Performs profiling process.
 * @discussion Passing null to callback block means the caller won't be notified when profiling process is finished
 * @param callbackBlock A block interface which is fired when profiling request is completed.
 * @return RLTMXProfileHandle which can be used to cancel current profiling and retrieve the session id
 */
- (RLTMXProfileHandle *)profileDeviceWithCallback:(void (^ _Nullable)(NSDictionary * _Nullable))callbackBlock NS_SWIFT_NAME(profileDevice(callbackBlock:));

/*!
 * @abstract Performs profiling process.
 * @discussion Passing null to callback block means the caller won't be notified when profiling process is finished
 * @param profileOptions NSDictionary including all extra information passed to profiling. List of valid keys for this dictionary can be found in this header.
 * @param callbackBlock A block interface which is fired when profiling request is completed.
 * @return RLTMXProfileHandle which can be used to cancel current profiling and retrieve the session id
 */
- (RLTMXProfileHandle *)profileDeviceUsing:(NSDictionary * _Nullable)profileOptions callbackBlock:(void (^ _Nullable)(NSDictionary * _Nullable))callbackBlock NS_SWIFT_NAME(profileDevice(profileOptions:callbackBlock:));

/*!
 * @discussion Perform a registration request.
 * @param userContext the username to register this device to
 * @param prompt a message to display to the user
 * @param completionCallback a callback block to be invoked with the result of the registration request
 * @return the Session ID of registration request or nil if registration request failed to send.
 */
- (NSString * _Nullable)registerUserContext:(NSString *)userContext prompt:(NSString *)prompt completionCallback:(void (^ _Nullable)(NSDictionary * _Nullable))completionCallback NS_SWIFT_NAME(registerUserContext(userContext:prompt:completionCallback:));

/*!
 * @discussion Perform a de-registration request.
 * @param userContext the username to de-register from this device
 * @param completionCallback a callback block to be invoked with the result of the de-registration request
 */
-(void) deregisterUserContext:(NSString *)userContext completionCallback:(void (^)(NSDictionary *))completionCallback NS_SWIFT_NAME(deregisterUserContext(userContext:completionCallback:));

/*!
 * @discussion Perform a stepup request.
 * @param prompt APN message dictionary
 * @param completionCallback A block interface which is fired when step up processing is finished
 * @return the Session ID of registration/step up request or nil if failed.
 */
- (NSString * _Nullable)processStrongAuthPrompt:(NSDictionary * _Nullable)prompt completionCallback:(void (^ _Nullable)(NSDictionary * _Nullable))completionCallback NS_SWIFT_NAME(processStrongAuthPrompt(prompt:completionCallback:));

/*!
 * @discussion Perform a stepup request.
 * @param prompt APN message dictionary
 * @return the Session ID of registration/step up request or nil if failed.
 */
-(NSString * _Nullable)processStrongAuthPrompt:(NSDictionary * _Nullable)prompt NS_SWIFT_NAME(processStrongAuthPrompt(prompt:));

/*!
 * @discussion Set a stepup token, if one wishes to use push messaging without swizzling methods.
 * @param token is a NSData object returned by Application:didRegisterForRemoteNotificationsWithDeviceToken.
 */
- (void)setStepupToken:(NSData * _Nullable)token NS_SWIFT_NAME(setStepupToken(token:));

/*!
 * @abstract Pauses or resumes location services
 * @param pause YES to pause, NO to resume
 */
- (void)pauseLocationServices:(BOOL)pause NS_SWIFT_NAME(pauseLocationServices(shouldPause:));

/*!
 * @abstract Query the build number, for debugging purposes only.
 */
- (NSString *)version NS_SWIFT_NAME(version());

@end

NS_ASSUME_NONNULL_END

#endif /* _TMXPROFILING_H_ */

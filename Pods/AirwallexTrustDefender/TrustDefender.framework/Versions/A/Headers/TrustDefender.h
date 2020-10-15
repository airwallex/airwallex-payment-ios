/*!
 @header TrustDefender.h

 TrustDefender Mobile SDK for iOS. This header is the main framework header, and is required to make use of the mobile SDK.

 @author Nick Blievers
 @copyright 2017 ThreatMetrix. All rights reserved.
 */
#ifndef _TRUSTDEFENDERMOBILE_H_
#define _TRUSTDEFENDERMOBILE_H_

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
@import CoreLocation;
#else
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#endif

#import "THMStatusCode.h"
#import "THMProfileHandle.h"

#ifdef __cplusplus
#define EXTERN		extern "C" __attribute__((visibility ("default")))
#else
#define EXTERN	    extern __attribute__((visibility ("default")))
#endif

#define THM_NAME_PASTE2( a, b) a##b
#define THM_NAME_PASTE( a, b) THM_NAME_PASTE2( a, b)

#ifndef THM_PREFIX_NAME
#define NO_COMPAT_CLASS_NAME
#define THM_PREFIX_NAME
#endif

#define THMTrustDefender                THM_NAME_PASTE(THM_PREFIX_NAME, THMTrustDefender)

/*
 * For this to work, all exported symbols must be included here
 */
#ifdef THM_PREFIX_NAME
#define THMOrgID                        THM_NAME_PASTE(THM_PREFIX_NAME, THMOrgID)
#define THMApiKey                       THM_NAME_PASTE(THM_PREFIX_NAME, THMApiKey)
#define THMDelegate                     THM_NAME_PASTE(THM_PREFIX_NAME, THMDelegate)
#define THMTimeout                      THM_NAME_PASTE(THM_PREFIX_NAME, THMTimeout)
#define THMLocationServices             THM_NAME_PASTE(THM_PREFIX_NAME, THMLocationServices)
#define THMLocationServicesWithPrompt   THM_NAME_PASTE(THM_PREFIX_NAME, THMLocationServicesWithPrompt)
#define THMDesiredLocationAccuracy      THM_NAME_PASTE(THM_PREFIX_NAME, THMDesiredLocationAccuracy)
#define THMKeychainAccessGroup          THM_NAME_PASTE(THM_PREFIX_NAME, THMKeychainAccessGroup)
#define THMOptions                      THM_NAME_PASTE(THM_PREFIX_NAME, THMOptions)
#define THMEnableOptions                THM_NAME_PASTE(THM_PREFIX_NAME, THMEnableOptions)
#define THMDisableOptions               THM_NAME_PASTE(THM_PREFIX_NAME, THMDisableOptions)
#define THMFingerprintServer            THM_NAME_PASTE(THM_PREFIX_NAME, THMFingerprintServer)
#define THMProfileSourceURL             THM_NAME_PASTE(THM_PREFIX_NAME, THMProfileSourceURL)
#define THMRegisterForPush              THM_NAME_PASTE(THM_PREFIX_NAME, THMRegisterForPush)
#define THMCertificateHashes            THM_NAME_PASTE(THM_PREFIX_NAME, THMCertificateHashes)
#define THMUseNSURLSession              THM_NAME_PASTE(THM_PREFIX_NAME, THMUseNSURLSession)
#define THMUseUIWebView                 THM_NAME_PASTE(THM_PREFIX_NAME, THMUseUIWebView)
#define THMUseAlternateID               THM_NAME_PASTE(THM_PREFIX_NAME, THMUseAlternateID)
#if (!TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR)
#define THMDisableKeychainAccess        THM_NAME_PASTE(THM_PREFIX_NAME, THMDisableKeychainAccess)
#endif
//Profiling attributes
#define THMSessionID                    THM_NAME_PASTE(THM_PREFIX_NAME, THMSessionID)
#define THMCustomAttributes             THM_NAME_PASTE(THM_PREFIX_NAME, THMCustomAttributes)
#define THMLocation                     THM_NAME_PASTE(THM_PREFIX_NAME, THMLocation)
#define THMProfileStatus                THM_NAME_PASTE(THM_PREFIX_NAME, THMProfileStatus)
#endif

/*!
 * @abstract Return value for Strong Auth prompt
 * @see StrongAuthPromptCallback
 */
typedef enum
{
    STRONG_AUTH_OK = 0, /*!< Stepup was performed successfully. */
    STRONG_AUTH_FAILED = 1, /*!< System has rejected a stepup attempt. */
    STRONG_AUTH_CANCELLED = 2 /*!< User has chosen to abandon or reject stepup attempt. */
} StrongAuthPromptResult;


/*!
 * @abstract A callback for Strong Auth to allow app developers to supply their own prompt.
 * @param title The title of the stepup message.
 * @param auth_context The user account name, etc that the stepup is being sent to.
 * @param prompt The transaction description that the user is being prompted to consent to.
 * @return STRONG_AUTH_OK if user has hit "OK", STRONG_AUTH_CANCELLED if user has opted out and STRONG_AUTH_FAILED if the app has rejected them.
 * @discussion  This function will be called on a background thread during step-up.
 */
typedef StrongAuthPromptResult (^StrongAuthPromptCallback)(NSString * title, NSString * auth_context, NSString * prompt);

// Instance wide options
/*!
 * @const THMOrgID
 * @abstract NSDictionary key for specifying the org id.
 * @discussion Valid at init time to set the org id.
 * This is mandatory.
 */
EXTERN NSString *const THMOrgID;
/*!
 * @const THMApiKey
 * @abstract NSDictionary key for specifying the API key, if one is required.
 * @discussion Valid at init time to set the API key. Do not set unless instructed by
 * Threatmetrix.
 */
EXTERN NSString *const THMApiKey;
/*!
 * @const THMDelegate
 * @abstract NSDictionary key for specifying the delegate.
 * @discussion Valid at init time to set the delegate, which must comply to
 * TrustDefenderMobileDelegate.
 */
EXTERN NSString *const THMDelegate;
/*!
 * @const THMTimeout
 * @abstract NSDictionary key for specifying the network timeout.
 * @discussion Valid at init time to set the network timeout, defaults to 10s.
 * Default is \@10 (note use of NSNumber to store int)
 */
EXTERN NSString *const THMTimeout;
/*!
 * @const THMLocationServices
 * @abstract NSDictionary key for enabling the location services.
 * @discussion Valid at init time to enable location services. Note that this will never cause UI
 * interaction -- if the application does not have permissions, no prompt will be made, and no location will be acquired.
 * Default value is \@NO (note use of NSNumber to store BOOL)
 */
EXTERN NSString *const THMLocationServices;
/*!
 * @const THMLocationServicesWithPrompt
 * @abstract NSDictionary key for enabling the location services.
 * @discussion Valid at init time to enable location services. Note that this can cause user
 * interaction -- if the application does not have permissions, they will be prompted.
 * @remark Only one of THMLocationServices or THMLocationServicesWithPrompt should be set.
 * Default value is \@NO (note use of NSNumber to store BOOL)
 */
EXTERN NSString *const THMLocationServicesWithPrompt;

/*!
 * @const THMDesiredLocationAccuracy
 * @abstract NSDictionary key for enabling the location services.
 * @discussion Valid at init time and configures the desired location accuracy.
 * Default value is \@1000.0 (note use of NSNumber to store float) which is equivilent to kCLLocationAccuracyKilometer
 */
EXTERN NSString *const THMDesiredLocationAccuracy;

/*!
 * @const THMKeychainAccessGroup
 * @abstract NSDictionary key for making use of the keychain access group.
 * @discussion Valid at init time to enable the sharing of data across applications with the same keychain access group.
 * This allows matching device ID across applications from the same vendor.
 */
EXTERN NSString *const THMKeychainAccessGroup;

/*!
 * @const THMOptions
 * @abstract NSDictionary key for setting specific options
 * @discussion Valid at init time for fine grained control over profiling.
 * @remark Used internally. Do not set unless specified by ThreatMetrix.
 */
EXTERN NSString *const THMOptions;

/*!
 * @const THMEnableOption
 * @abstract NSDictionary key for setting specific options
 * @discussion Valid at init time for fine grained control over profiling.
 * @remark Used internally. Do not set unless specified by ThreatMetrix.
 */
EXTERN NSString *const THMEnableOptions;

/*!
 * @const THMDisableOptions
 * @abstract NSDictionary key for setting specific options
 * @discussion Valid at init time for fine grained control over profiling.
 * @remark Used internally. Do not set unless specified by ThreatMetrix.
 */
EXTERN NSString *const THMDisableOptions;
/*!
 * @const THMFingerprintServer
 * @abstract NSDictionary key for setting a fingerprint server
 * @discussion Valid at init time setting an alternative fingerprint server
 * Defaults to \@"h-sdk.online-metrix.net"
 */
EXTERN NSString *const THMFingerprintServer;
/*!
 * @const THMProfileSourceURL
 * @abstract NSDictionary key for setting a custom url.
 * @discussion Valid at init time for setting a custom referrer url
 */
EXTERN NSString *const THMProfileSourceURL;
/*!
 * @const THMRegisterForPush
 * @abstract NSDictionary key to allow SDK to grab an Apple Push Notification token
 * @discussion Valid at init time to allow SDK to grab an Apple Push Notification token
 */
EXTERN NSString *const THMRegisterForPush;

/*!
 * @const THMCertificateHashes
 * @abstract NSDictionary key for setting a SHA1/SHA256 of certificate of fingerprint server.
 * @discussion Valid at init time for setting a SHA1 of certificate of fingerprint server
 */
EXTERN NSString *const THMCertificateHashes;

/*!
 * @const THMUseNSURLSession
 * @abstract NSDictionary key for using NSURLSession when available. NSURLSession is recommended
 * by Apple and is available in iOS 7+. By default TrustDefender SDK is using NSURLConnection for
 * backward compatibility, using this option TrustDefender SDK will use NSURLSession in iOS 7+.
 * @discussion Valid at init time for using NSURLSession API when availble.
 * Default value is \@NO (note use of NSNumber to store BOOL)
 */
EXTERN NSString *const THMUseNSURLSession;

/*!
 * @const THMUseUIWebKit
 * @abstract NSDictionary key for using UIWebKit. UIWebKit is deprecated in iOS 8+ and Apple recommended
 * WKWebKit. TrustDefender SDK uses WKWebKit in iOS 9+ (there are some minor issues in iOS 8 using WKWebKit).
 * @discussion Valid at init time for using UIWebKit instead of WKWebKit.
 * Default value is \@NO (note use of NSNumber to store BOOL)
 */
EXTERN NSString *const THMUseUIWebView;

/*!
 * @const THMUseAlternateID
 * @using threatmetrix ID instead of OpenUDID, threatmetrix ID is md5 of OpenUDID generated ID
 */
EXTERN NSString *const THMUseAlternateID;

#if (!TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR)
/*!
 * @const THMKeychainAccessPrompt
 * @abstract NSDictionary key for disabling keychain access
 * @discussion By default THM SDK accesses the keychain which will cause a user prompt, setting this option to YES will disable accessing keychain.
 * @remark This option is only valid for THM SDK for macOS
 * Default value is \@NO (note use of NSNumber to store BOOL)
 */
EXTERN NSString *const THMDisableKeychainAccess;
#endif

// Profile specific options.
/*!
 * @const THMSessionID
 * @abstract NSDictionary key for Session ID.
 * @discussion Valid at profile time, and result time for setting/retrieving the session ID.
 */
EXTERN NSString *const THMSessionID;

/*!
 * @const THMCustomAttributes
 * @abstract NSDictionary key for Custom Attributes.
 * @discussion Valid at profile time for setting the any custom attributes to be included in the profiling data.
 */
EXTERN NSString *const THMCustomAttributes;

/*!
 * @const THMLocation
 * @abstract NSDictionary key for setting location.
 * @discussion Valid at profile time for setting the location to be included in the profiling data.
 * @remark This should only be used if location services are not enabled.
 */
EXTERN NSString *const THMLocation;

// Profile result options (THMSessionID is shared)

/*!
 * @const THMProfileStatus
 * @abstract NSDictionary key for retrieving the profiling status
 * @discussion Valid at results time for getting the status of the current profiling request.
 */
EXTERN NSString *const THMProfileStatus;


// NOTE: headerdoc2html gets confused if this __attribute__ is after the comment
__attribute__((visibility("default")))
/*!
 * @interface TrustDefenderMobile
 * @discussion TrustDefender Mobile SDK
 */
@interface THMTrustDefender : NSObject

-(instancetype) init NS_UNAVAILABLE;
+(instancetype) allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+(instancetype) new NS_UNAVAILABLE;

/*!
 * @discussion Initialise a shared instance of TrustDefenderMobile object.
 * @code
 * TrustDefenderMobile *THM = [TrustDefenderMobile sharedInstance];
 * @endcode
 *
 * @return instance of THMTrustDefender
 */
+(instancetype) sharedInstance;

/*!
 * @discussion Configure the shared instance of TrustDefenderMobile object with the supplied configuration dictionary.
 * @code
 * [THM configure:@{ THMOrgID: @"my orgid" }];
 * @endcode
 *
 * @remark This method runs only once, any following calls has no effect.
 * @param config NSDictionary including all required information to configure THMTrustDefender instance. List of valid keys for this dictionary can be found in this header.
 * @throws An exception of type NSInvalidArgumentException if config dictionary contains invlid keys or malformed values
 *
 */
-(void) configure:(NSDictionary *)config;

/*!
 * @discussion Performs profiling request. The profileComplete method (if declared) will be called when profiling is finished
 * @return THMProfileHandle which can be used to cancel current profiling and retrieve the session id
 */
-(THMProfileHandle *) doProfileRequest;

/*!
 * @discussion Performs profiling request. The profileComplete method (if declared) will be called when profiling is finished.
 * @param options NSDictionary including all extra information passed to profiling. List of valid keys for this dictionary can be found in this header.
 * @return THMProfileHandle which can be used to cancel current profiling and retrieve the session id
 */
-(THMProfileHandle *) doProfileRequest: (NSDictionary *)options;

/*!
 * @discussion Performs profiling request. Note that if a block is passed in, the delegate callback will not be fired.
 * @param callbackBlock A block interface which is fired when profiling request is completed.
 * @return THMProfileHandle which can be used to cancel current profiling and retrieve the session id
 */
-(THMProfileHandle *) doProfileRequestWithCallback: (void (^)(NSDictionary *))callbackBlock;

/*!
 * @discussion Performs profiling request. Note that if a block is passed in, the delegate callback will not be fired.
 * @param profileOptions NSDictionary including all extra information passed to profiling. List of valid keys for this dictionary can be found in this header.
 * @param callbackBlock A block interface which is fired when profiling request is completed.
 * @return THMProfileHandle which can be used to cancel current profiling and retrieve the session id
 */
-(THMProfileHandle *) doProfileRequestWithOptions: (NSDictionary *)profileOptions andCallbackBlock: (void (^)(NSDictionary *))callbackBlock;

/*!
 * @discussion Perform a stepup request.
 * @param authMessage APN message dictionary
 * @param promptCallback A block that may be used to present the user with a stepup UI
 * @param callbackBlock A block interface which is fired when step up processing is finished
 * @return the Session ID of registration/step up request or nil if failed.
 */
-(NSString *) processStrongAuthMessage: (NSDictionary *)authMessage withPromptCallback:(StrongAuthPromptCallback)promptCallback andCallbackBlock:(void (^)(NSDictionary *))callbackBlock;

/*!
 * @discussion Perform a stepup request.
 * @param authMessage APN message dictionary
 * @param promptCallback A block that may be used to present the user with a stepup UI
 * @return the Session ID of registration/step up request or nil if failed.
 */
-(NSString *) processStrongAuthMessage: (NSDictionary *)authMessage withPromptCallback:(StrongAuthPromptCallback)promptCallback;

/*!
 * @discussion Perform a stepup request.
 * @param authMessage APN message dictionary
 * @param callbackBlock A block interface which is fired when step up processing is finished
 * @return the Session ID of registration/step up request or nil if failed.
 */
-(NSString *) processStrongAuthMessage: (NSDictionary *)authMessage withCallbackBlock:(void (^)(NSDictionary *))callbackBlock;

/*!
 * @discussion Set a stepup token, if one wishes to use push messaging without swizzling methods.
 * @param token is a NSData object returned by Application:didRegisterForRemoteNotificationsWithDeviceToken.
 */
-(void) setStepupToken: (NSData *)token;

/*!
 * @discussion Pause or resume location services
 * @param pause YES to pause, NO to unpause
 */
-(void) pauseLocationServices: (BOOL) pause;

/*!
 * @discussion Query the build number, for debugging purposes only.
 */
-(NSString *)version;

@end

/*!
 * @discussion The delegate should implement this protocol to receive completion notification. Only one of the methods should be implemented.
 */
@protocol THMTrustDefenderDelegate

/*!
 * @discussion Once profiling is complete, this method is called.
 * @param profileResults describes the profiling status.
 */
-(void) profileComplete: (NSDictionary *) profileResults;

/*!
 * @discussion Once stepup is complete, this method is called.
 * @param result A dictionary including THMStatus code of of the process and session id used for the process.
 * Please note that dictionary keys to access the result is same as the keys used for accessing profiling result.
 */
-(void) strongAuthDidCompleteWithResult: (NSDictionary *) result;
@end
#endif

/*!
 @header RLTMXStatusCode.h

 @author Nick Blievers
 @copyright 2020 ThreatMetrix. All rights reserved.

 The statuses that are used as indicators of profiling state.
 */

#ifndef __TMXSTATUSCODE__
#define __TMXSTATUSCODE__

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

/*!
 @typedef RLTMXStatusCode

 Possible return codes
 @constant RLTMXStatusCodeNotYet                   Another profiling is running.
 @constant RLTMXStatusCodeOk                       Completed, No errors.
 @constant RLTMXStatusCodeConnectionError          There was connection issue, profiling incomplete.
 @constant RLTMXStatusCodeHostNotFoundError        Unable to resolve the host name of the fingerprint server.
 @constant RLTMXStatusCodeNetworkTimeoutError      Network timed out.
 @constant RLTMXStatusCodeHostVerificationError    Certificate verification or other SSL failure! Potential Man In The Middle attack.
 @constant RLTMXStatusCodeInternalError            Internal Error, profiling incomplete or interrupted.
 @constant RLTMXStatusCodeInterruptedError         Request was cancelled.
 @constant RLTMXStatusCodePartialProfile           Connection error, only partial profile completed.
 @constant RLTMXStatusCodeInvalidOrgID             Request contained an invalid org id. (Internal use only)
 @constant RLTMXStatusCodeNotConfigured            Configure has not been called or failed.
 @constant RLTMXStatusCodeCertificateMismatch      Certificate hash or public key hash provided to networking module does not match with what server uses.
 @constant RLTMXStatusCodeInvalidParameter         A parameter was supplied that is not recognised by this version of the SDK.
 @constant RLTMXStatusCodeProfilingTimeoutError    Profiling process timed out, profiling incomplete
 */
typedef NS_ENUM(NSInteger, RLTMXStatusCode)
{
    RLTMXStatusCodeNotYet = 0,
    RLTMXStatusCodeOk,
    RLTMXStatusCodeConnectionError,
    RLTMXStatusCodeHostNotFoundError,
    RLTMXStatusCodeNetworkTimeoutError,
    RLTMXStatusCodeHostVerificationError,
    RLTMXStatusCodeInternalError,
    RLTMXStatusCodeInterruptedError,
    RLTMXStatusCodePartialProfile,
    RLTMXStatusCodeInvalidOrgID,
    RLTMXStatusCodeNotConfigured,
    RLTMXStatusCodeCertificateMismatch,
    RLTMXStatusCodeInvalidParameter,
    RLTMXStatusCodeProfilingTimeoutError,
};

#endif
